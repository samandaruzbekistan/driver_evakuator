import 'dart:async';
import 'dart:convert';
import 'dart:math' show asin, atan2, cos, pi, sin, sqrt;
import 'package:driver_evakuator/constants.dart';
import 'package:driver_evakuator/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:maps_launcher/maps_launcher.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

class JonDetail extends StatefulWidget {
  const JonDetail({Key? key, required this.id, required this.balans})
      : super(key: key);

  final String id;
  final int balans;

  @override
  State<JonDetail> createState() => _JonDetailState();
}

class _JonDetailState extends State<JonDetail> with TickerProviderStateMixin {
  var box = Hive.box('users');
  bool getData = false;
  bool progress = false;
  bool isLoading = false;
  late AnimationController _controller;
  int _secondsRemaining = 1800;
  int _counter = 0;
  bool _isResendButtonVisible = false;
  Map<String, dynamic> ordersData = {};
  bool _start = false;
  late geo.Position _currentPosition;
  late geo.Position _previousPosition;
  double _totalDistance = 0;
  double _totalDistanceKm = 0;
  double _metr = 0;
  String _orderId = "";
  List<geo.Position> locations = [];
  double minMoney = 0;
  double minKm = 0;
  double kmMoney = 0;
  double amount = 0;


  late StreamSubscription<geo.Position> _positionStream;

  @override
  void initState() {
    super.initState();
    getOrder();
  }

  complateOrder(String orderId) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request(
        'POST', Uri.parse('http://94.241.168.135:3000/api/v1/mobile'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "SaveDataKm",
        "body": {
          "orderid": "${_orderId}",
          "money": "${amount.toInt()}",
          "km": "${double.parse(_totalDistanceKm.toStringAsFixed(2))}"
        }
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      Get.to(HomeScreen());
    } else {
      _jobError(context);
    }
  }




  countdown(){
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..addStatusListener((status) {
    });

    // Update the countdown value using a listener
    _controller.addListener(() {
      setState(() {
        _secondsRemaining = (_controller.duration!.inSeconds - _controller.value * _controller.duration!.inSeconds).round();
      });
    });

    _controller.forward();
  }

  void startLocationUpdates() async {
    setState(() {
      _start = true;
    });
    _positionStream = geo.Geolocator.getPositionStream(
      distanceFilter: 5,
      desiredAccuracy: geo.LocationAccuracy.best,
      // timeLimit: Duration(seconds: 5),
      // forceAndroidLocationManager: true,
    ).listen((geo.Position position) async {
      if (await geo.Geolocator.isLocationServiceEnabled()) {
        _currentPosition = position; // Initialize here
        setState(() {
          _counter++;
        });
        _updateLocationData(position);
      } else {
        _showGpsOffDialog();
      }
    });
  }

  void _updateLocationData(geo.Position newPosition) {
    // if (_currentPosition == null || locations.isEmpty) return;
    var distanceBetweenLastTwoLocations;
    _currentPosition = newPosition;
    locations.add(_currentPosition);
    _previousPosition = locations.last;

    if (locations.length > 1) {
      _previousPosition = locations[locations.length - 2];

      distanceBetweenLastTwoLocations = calculateDistance(_previousPosition.latitude, _previousPosition.longitude, _currentPosition.latitude, _currentPosition.longitude);

      distanceBetweenLastTwoLocations;

      if(_counter > 5 && distanceBetweenLastTwoLocations > 5){

        setState(() {
          _metr = distanceBetweenLastTwoLocations;
          _currentPosition = newPosition;
          locations.add(_currentPosition);
          _totalDistance += distanceBetweenLastTwoLocations;
          _totalDistanceKm = _totalDistance/1000;
          if(_totalDistanceKm > minKm){
            var km = _totalDistanceKm - minKm;
            amount = minMoney + (km * kmMoney);
          }
        });

      }
    }
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

  void _showGpsOffDialog() {
    print("GPS is off.");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Make sure your GPS is on in Settings !'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        );
      },
    );
  }


  getOrder() async {
    var balans = int.parse(box.get('balans')) - widget.balans;
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request(
        'POST', Uri.parse('http://94.241.168.135:3000/api/v1/mobile'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "BuyOrder",
        "body": {"orderid": "${widget.id}", "driverid": "${box.get('id')}", 'balans':"${balans }"}
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    box.put('balans', "${balans}");
    var res = await response.stream.bytesToString();
    final data = json.decode(res);
    print(data);
    if (data['success'] == true) {
      setState(() {
        _orderId = "${data['messages']['id']}";
        minKm = double.parse(data['messages']['minkm']);
        kmMoney = double.parse(data['messages']['kmmoney']);
        minMoney = double.parse(data['messages']['minmoney']);
        getData = true;
        amount = double.parse(data['messages']['minmoney']);
        ordersData = Map<String, dynamic>.from(data['messages']);
      });
    } else {
      setState(() {
        progress = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Ish tavsilotlari",
          style: TextStyle(fontWeight: FontWeight.bold, color: kPrimaryColor),
        ),
      ),
      body: Container(
          child: getData
              ? Column(
                  children: [
                    ListTile(
                      title: Text(
                        "Ish turi:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: w * 0.05),
                      ),
                      subtitle: Text(
                        "${ordersData['category']}",
                        style:
                            TextStyle(color: Colors.grey, fontSize: w * 0.04),
                      ),
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.workspaces_outline,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Buyurtmachi:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: w * 0.05),
                      ),
                      subtitle: Text(
                        "${ordersData['username']}",
                        style:
                            TextStyle(color: Colors.grey, fontSize: w * 0.04),
                      ),
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.person_outline,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Telefon:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: w * 0.05),
                      ),
                      subtitle: Text(
                        "${ordersData['userphone']}",
                        style:
                            TextStyle(color: Colors.grey, fontSize: w * 0.04),
                      ),
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Joylashuv:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: w * 0.05),
                      ),
                      subtitle: Text(
                        "${ordersData['region']}",
                        style:
                            TextStyle(color: Colors.grey, fontSize: w * 0.04),
                      ),
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                    ),
                    ListTile(
                      title: Text(
                        "Qisqa tarif:",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: w * 0.05),
                      ),
                      subtitle: Text(
                        "${ordersData['description']}",
                        style:
                            TextStyle(color: Colors.grey, fontSize: w * 0.04),
                      ),
                      leading: CircleAvatar(
                        child: Icon(
                          Icons.phone,
                          color: Colors.white,
                        ),
                        backgroundColor: Colors.deepPurpleAccent,
                      ),
                    ),
                    SizedBox(
                      height: h * 0.1,
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green,
                            radius: 30,
                            child: IconButton(
                              icon: Icon(
                                Icons.phone,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                launchUrl(Uri.parse('tel:' + "+998${ordersData['userphone']}"));
                              },
                            ),
                          ),
                          SizedBox(
                            width: w * 0.04,
                          ),
                          CircleAvatar(
                            backgroundColor: Colors.pink,
                            radius: 30,
                            child: IconButton(
                              icon: Icon(
                                Icons.location_on_outlined,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // openMaps(ordersData['lat'], ordersData['lang']);
                                MapsLauncher.launchCoordinates(
                                    ordersData['lat'],
                                    ordersData['long'],
                                    'Ish joylashuvi');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Text(
                      "Summa: ${amount.toInt()}",
                      style: const TextStyle(color: Colors.deepPurple, fontSize: 20),
                    ),
                    Text(
                      "KM: ${double.parse(_totalDistanceKm.toStringAsFixed(2))}",
                      style: const TextStyle(color: Colors.deepPurple, fontSize: 20),
                    ),
                    SizedBox(
                      height: h * 0.02,
                    ),
                    Container(
                      width: w * 0.8,
                      child: ElevatedButton(
                        onPressed: () {
                          _start ? _completeOrderAlert(context, "${double.parse(_totalDistanceKm.toStringAsFixed(2))}","${amount.toInt()}", "${_orderId}") : startLocationUpdates();
                        },
                        child: isLoading
                            ?  CircularProgressIndicator(
                                color: Colors.white)
                            :  Text(
                                _start ? "Yakunlash" : "Ishni boshlash",
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          // elevation: 20,
                          backgroundColor: _start ? Colors.red : kPrimaryColor,
                          minimumSize: const Size.fromHeight(60),
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: progress
                      ? _jobError(context)
                      : CircularProgressIndicator(),
                )),
    );
  }

  _completeOrderAlert(context, String km, String amount, String id) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Diqqat!",
      desc: "Ishni yakunlaysizmi?\nKM: ${km}\nSumma: ${amount}",
      buttons: [
        DialogButton(
          child: Text(
            "Yakunlash",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          onPressed: () => complateOrder(id),
          color: Colors.black,
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }
}

_jobError(context) {
  Alert(
    context: context,
    type: AlertType.info,
    title: "Xatolik!",
    desc: "Buyurtma mavjud emas",
    buttons: [
      DialogButton(
        child: Text(
          "To'ldirish",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Get.offAll(HomeScreen()),
        color: Colors.black,
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}



_jobComplete(context) {
  Alert(
    context: context,
    type: AlertType.info,
    title: "Xabar!",
    desc: "Umumiy masofa:",
    buttons: [
      DialogButton(
        child: Text(
          "To'ldirish",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Get.offAll(HomeScreen()),
        color: Colors.black,
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}