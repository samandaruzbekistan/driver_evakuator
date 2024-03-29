import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:driver_evakuator/background_locator/db.dart';
import 'package:driver_evakuator/background_locator/models.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../controllers/api_controller.dart';
import '../controllers/location_controller.dart';
import 'android_settings.dart';
import 'auto_stop_handler.dart';
import 'callback_dispatcher.dart';
import 'ios_settings.dart';
import 'keys.dart';
import 'location_dto.dart';
import 'locator_settings.dart';

class BackgroundLocator {
  static const MethodChannel _channel = const MethodChannel(Keys.CHANNEL_ID);

  static Future<void> initialize() async {
    final CallbackHandle callback =
    PluginUtilities.getCallbackHandle(callbackDispatcher)!;
    await _channel.invokeMethod(Keys.METHOD_PLUGIN_INITIALIZE_SERVICE,
        {Keys.ARG_CALLBACK_DISPATCHER: callback.toRawHandle()});
  }

  static WidgetsBinding? get _widgetsBinding => WidgetsBinding.instance;

  static Future<void> registerLocationUpdate(
      void Function(LocationDto) callback,
      {void Function(Map<String, dynamic>)? initCallback,
        Map<String, dynamic> initDataCallback = const {},
        void Function()? disposeCallback,
        bool autoStop = false,
        AndroidSettings androidSettings = const AndroidSettings(),
        IOSSettings iosSettings = const IOSSettings()}) async {
    if (autoStop) {
      _widgetsBinding!.addObserver(AutoStopHandler());
    }

    final args = SettingsUtil.getArgumentsMap(
        callback: callback,
        initCallback: initCallback,
        initDataCallback: initDataCallback,
        disposeCallback: disposeCallback,
        androidSettings: androidSettings,
        iosSettings: iosSettings);

    await _channel.invokeMethod(
        Keys.METHOD_PLUGIN_REGISTER_LOCATION_UPDATE, args);
  }

  static Future<void> unRegisterLocationUpdate() async {
    await _channel.invokeMethod(Keys.METHOD_PLUGIN_UN_REGISTER_LOCATION_UPDATE);
  }

  static Future<bool> isRegisterLocationUpdate() async {
    return (await _channel
        .invokeMethod<bool>(Keys.METHOD_PLUGIN_IS_REGISTER_LOCATION_UPDATE))!;
  }

  static Future<bool> isServiceRunning() async {
    return (await _channel
        .invokeMethod<bool>(Keys.METHOD_PLUGIN_IS_SERVICE_RUNNING))!;
  }

  static Future<void> updateNotificationText(
      {String? title, String? msg, String? bigMsg}) async {
    final Map<String, dynamic> arg = {};

    if (title != null) {
      arg[Keys.SETTINGS_ANDROID_NOTIFICATION_TITLE] = title;
    }

    if (msg != null) {
      arg[Keys.SETTINGS_ANDROID_NOTIFICATION_MSG] = msg;
    }

    if (bigMsg != null) {
      arg[Keys.SETTINGS_ANDROID_NOTIFICATION_BIG_MSG] = bigMsg;
    }

    await _channel.invokeMethod(Keys.METHOD_PLUGIN_UPDATE_NOTIFICATION, arg);
  }
}



class LocationServiceRepository {

  static const String isolateName = 'LocatorIsolate';
  static LocationServiceRepository _instance = LocationServiceRepository._();
  LocationServiceRepository._();
  factory LocationServiceRepository() => _instance;

  Future<void> init(Map<dynamic, dynamic> params) async =>
      IsolateNameServer.lookupPortByName(isolateName)?.send(null);

  Future<void> dispose() async =>
      IsolateNameServer.lookupPortByName(isolateName)?.send(null);

  Future<void> callback(LocationDto locationDto) async {
    IsolateNameServer.lookupPortByName(isolateName)
        ?.send(locationDto.toJson());
    var js = locationDto.toJson();
    var job = await LocalDatabase().getFalseStatusJob();
    print(job);
    if(job?['lat'] != 0.0 && job?['long'] != 0.0){
      var distanceMetr = calculateDistance(job?['lat'], job?['long'], js['latitude'],  js['longitude']);
      var newDistance = job?['totalDistanceKm'] + (distanceMetr/1000);
      if(newDistance > job?['minKm']){
        var km = newDistance - job?['minKm'];
        var amount = job?['minMoney'] + (km * job?['kmMoney']);
        await LocalDatabase().updateLocationAndInfo(js['latitude'], js['longitude'], amount, newDistance);
      }
      else{
        await LocalDatabase().updateLocationAndInfo(js['latitude'], js['longitude'], job?['amount'], newDistance);
      }
    }
    else{
      await LocalDatabase().updateLocation(js['latitude'], js['longitude']);
    }

    // LocalDatabase().printLocationById(1);
    // await LocalDatabase().addLocation(LocationModel(lat: js['latitude'], long: js['longitude']));
    // await apiController.addLocation(js['latitude'], js['latitude']);
    // print("lat: ${js['latitude']}");
    // print("long: ${js['latitude']}");
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000; // Radius of the earth in meters
    var dLat = _toRadians(lat2 - lat1);
    var dLon = _toRadians(lon2 - lon1);
    var a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
            sin(dLon / 2) * sin(dLon / 2);
    var c = 2 * atan2(sqrt(a), sqrt(1 - a));
    var distance = R * c;
    // Convert distance to kilometers
    return distance; // Distance in kilometers
  }

  double _toRadians(double degree) {
    return degree * (pi / 180);
  }

}


@pragma('vm:entry-point')
class LocationCallbackHandler {
  @pragma('vm:entry-point')
  static Future<void> initCallback(Map<dynamic, dynamic> params) async =>
      await LocationServiceRepository().init(params);

  @pragma('vm:entry-point')
  static Future<void> disposeCallback() async =>
      await LocationServiceRepository().dispose();

  @pragma('vm:entry-point')
  static Future<void> callback(LocationDto locationDto) async =>
      await LocationServiceRepository().callback(locationDto);

  @pragma('vm:entry-point')
  static Future<void> notificationCallback() async {}
}


class LocationManager {
  ReceivePort _port = ReceivePort();
  Stream<LocationDto>? _locationStream;
  String _channelName = "BackgroundLocationChannel",
      _notificationTitle = "Background Location",
      _notificationMsg =
          "Background location is on to keep the app up-to-date with your location.",
      _notificationBigMsg =
          "Background location is on to keep the app up-to-date with your location. "
          "This is required for main features to work properly when the app is not running.";

  int _interval = 5;
  double _distanceFilter = 0;
  LocationAccuracy _accuracy = LocationAccuracy.NAVIGATION;

  static final LocationManager _instance = LocationManager._();

  /// Get the singleton [LocationManager] instance
  factory LocationManager() => _instance;

  LocationManager._() {
    // Check if the port is already used
    if (IsolateNameServer.lookupPortByName(
        LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    // Register the service to the port name
    IsolateNameServer.registerPortWithName(
        _port.sendPort, LocationServiceRepository.isolateName);
  }

  /// Get the status of the location manager.
  /// Will return `true` if a location service is currently running.
  Future<bool> get isRunning async =>
      await BackgroundLocator.isServiceRunning();

  /// A stream of location data updates.
  /// Call [start] before using this stream.
  Stream<LocationDto> get locationStream {
    if (_locationStream == null) {
      Stream<dynamic> dataStream = _port.asBroadcastStream();
      _locationStream = dataStream
          .where((event) => event != null)
          .map((json) => LocationDto.fromJson(json));
    }
    return _locationStream!;
  }

  /// Get the current location.
  Future<LocationDto> getCurrentLocation() async {
    if (!await BackgroundLocator.isRegisterLocationUpdate()) {
      await start();
      LocationDto dto = await locationStream.first;
      stop();
      return dto;
    }
    return await locationStream.first;
  }

  /// Start the location manager.
  /// Will have no effect if it is already running.
  Future<bool> start() async {
    bool running = await isRunning;
    if (!running) {
      await BackgroundLocator.initialize();

      await BackgroundLocator.registerLocationUpdate(
        LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        autoStop: false,
        androidSettings: AndroidSettings(
            accuracy: _accuracy,
            interval: _interval,
            distanceFilter: _distanceFilter,
            androidNotificationSettings: AndroidNotificationSettings(
              notificationChannelName: _channelName,
              notificationTitle: _notificationTitle,
              notificationMsg: _notificationMsg,
              notificationBigMsg: _notificationBigMsg,
            )),
        iosSettings: IOSSettings(
          accuracy: _accuracy,
          distanceFilter: _distanceFilter,
        ),
      );
    }
    return running;
  }

  /// Stop the location manager.
  Future<void> stop() async =>
      await BackgroundLocator.unRegisterLocationUpdate();

  /// Set the title of the notification for the background service.
  /// Android only.
  set notificationTitle(value) => _notificationTitle = value;

  /// Set the message of the notification for the background service.
  /// Android only.
  set notificationMsg(value) => _notificationMsg = value;

  /// Set the long message of the notification for the background service.
  /// Android only.
  set notificationBigMsg(value) => _notificationBigMsg = value;

  /// Set the update interval in seconds.
  /// Android only.
  set interval(int value) => _interval = value;

  /// Set the update distance, i.e. the distance the user needs to move
  /// before an update is fired.
  set distanceFilter(double value) => _distanceFilter = value;

  /// Set the update accuracy. See [LocationAccuracy] for options.
  set accuracy(LocationAccuracy value) => _accuracy = value;
}


class SettingsUtil {
  static Map<String, dynamic> getArgumentsMap(
      {required void Function(LocationDto) callback,
        void Function(Map<String, dynamic>)? initCallback,
        Map<String, dynamic>? initDataCallback,
        void Function()? disposeCallback,
        AndroidSettings androidSettings = const AndroidSettings(),
        IOSSettings iosSettings = const IOSSettings()}) {
    final args = _getCommonArgumentsMap(callback: callback,
        initCallback: initCallback,
        initDataCallback: initDataCallback,
        disposeCallback: disposeCallback);

    if (Platform.isAndroid) {
      args.addAll(_getAndroidArgumentsMap(androidSettings));
    } else if (Platform.isIOS) {
      args.addAll(_getIOSArgumentsMap(iosSettings));
    }

    return args;
  }

  static Map<String, dynamic> _getCommonArgumentsMap({
    required void Function(LocationDto) callback,
    void Function(Map<String, dynamic>)? initCallback,
    Map<String, dynamic>? initDataCallback,
    void Function()? disposeCallback
  }) {
    final Map<String, dynamic> args = {
      Keys.ARG_CALLBACK:
      PluginUtilities.getCallbackHandle(callback)!.toRawHandle(),
    };

    if (initCallback != null) {
      args[Keys.ARG_INIT_CALLBACK] =
          PluginUtilities.getCallbackHandle(initCallback)!.toRawHandle();
    }
    if (disposeCallback != null) {
      args[Keys.ARG_DISPOSE_CALLBACK] =
          PluginUtilities.getCallbackHandle(disposeCallback)!.toRawHandle();
    }
    if (initDataCallback != null ){
      args[Keys.ARG_INIT_DATA_CALLBACK] = initDataCallback;

    }

    return args;
  }

  static Map<String, dynamic> _getAndroidArgumentsMap(
      AndroidSettings androidSettings) {
    final Map<String, dynamic> args = {
      Keys.ARG_SETTINGS: androidSettings.toMap()
    };

    if (androidSettings.androidNotificationSettings.notificationTapCallback !=
        null) {
      args[Keys.ARG_NOTIFICATION_CALLBACK] = PluginUtilities.getCallbackHandle(
          androidSettings
              .androidNotificationSettings.notificationTapCallback!)!
          .toRawHandle();
    }

    return args;
  }

  static Map<String, dynamic> _getIOSArgumentsMap(IOSSettings iosSettings) {
    return iosSettings.toMap();
  }
}
