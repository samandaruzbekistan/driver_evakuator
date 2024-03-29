import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:isolate';
import 'dart:math' show asin, atan2, cos, pi, sin, sqrt;
import 'dart:ui';

import 'package:driver_evakuator/background_locator/background_locator.dart';
import 'package:driver_evakuator/background_locator/db.dart';
import 'package:driver_evakuator/background_locator/models.dart';
import 'package:driver_evakuator/constants.dart';
import 'package:driver_evakuator/screens/home/home_screen.dart';
import 'package:driver_evakuator/screens/my_orders/my_orders_screen.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

import 'package:maps_launcher/maps_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../controllers/location_controller.dart';


class JonDetail extends StatefulWidget {
  const JonDetail({Key? key, required this.id, required this.balans, required this.is_process,this.order_data})
      : super(key: key);

  final String id;
  final int balans;
  final int is_process;
  final Map<String, dynamic>? order_data;

  @override
  State<JonDetail> createState() => _JonDetailState();
}

enum LocationStatus { UNKNOWN, INITIALIZED, RUNNING, STOPPED }

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
  late Timer _timer;
  bool _permissionStatus = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
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
      await LocationManager().stop();
      await LocalDatabase().completeJob(_orderId);
      _stopTimer();
      Get.to(HomeScreen());
    } else {
      _jobError(context);
    }
  }



  void startLocationUpdates() async {
    var jobCount = await LocalDatabase().getPendingJobCount();
    var r = await LocalDatabase().getJobById(_orderId);
    if(jobCount == 0){
      if(r == null){
        await LocalDatabase().addJob(
            JobModel(
              job_id: _orderId,
              minMoney: minMoney,
              minKm: minKm,
              kmMoney: kmMoney,
              amount: minMoney,
              totalDistanceKm: 0,
              status: 'false',
              lat: 0.0,
              long: 0.0
            ),
          minMoney
        );
      }
      setState(() {
        _start = true;
      });
      await LocationManager().start();
    }
    else if(r?['job_id'] == _orderId){
      setState(() {
        _start = true;
      });
      await LocationManager().start();
    }
    else{
      _jobError2(context);
    }
  }

  void _startTimer() {
    // Start a timer that runs every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
     await getDbData(_orderId);
    });
  }

  Future<void> getDbData(String id)async{
    var row = await LocalDatabase().getJobById(id);
    setState(() {
      _totalDistanceKm = row?['totalDistanceKm'];
      amount = row?['amount'];
    });
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

  Future<void> _checkPermissionStatus() async {
    final status = await Permission.locationAlways.status;
    if (status.isGranted) {
      setState(() {
        _permissionStatus = true;
      });
    }
    else{
      print(status);

      final status2 = await Permission.locationAlways.request();
      if (status2.isGranted) {
        setState(() {
          _permissionStatus = true;
        });
      }
    }
  }

  getOrder() async {
    if(widget.is_process == 1){
      var job = await LocalDatabase().getJobById(widget.order_data?['_id']);
      print(job);
      if(job != null){
        await getDbData(widget.order_data?['_id']);
        setState(() {
          _start = true;
        });
        _startTimer();
      }
      setState(() {
        _orderId = "${widget.order_data?['_id']}";
        minKm = double.parse(widget.order_data?['minkm']);
        kmMoney = double.parse(widget.order_data?['kmmoney']);
        minMoney = double.parse(widget.order_data?['minmoney']);
        getData = true;
        // amount = double.parse(widget.order_data?['minmoney']);
        amount = double.parse(widget.order_data?['minmoney']);
        ordersData = widget.order_data!;
      });
    }
    else{
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
  }

  void _stopTimer() {
    // Cancel the timer to stop it
    _timer.cancel();
  }

  @override
  void dispose() {
    // Stop the timer when the screen is closed
    _stopTimer();
    super.dispose();
  }
  //
  // @override
  // void dispose() => super.dispose();

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
              _start ?
                Text(
                  "Summa: ${amount.toInt()}",
                  style: const TextStyle(color: Colors.deepPurple, fontSize: 20),
                )
                : Container(),
              _start ? Text(
                "KM: ${double.parse(_totalDistanceKm.toStringAsFixed(2))}",
                style: const TextStyle(color: Colors.deepPurple, fontSize: 20),
              )
              : Container(),
              SizedBox(
                height: h * 0.02,
              ),
              Container(
                width: w * 0.8,
                child: ElevatedButton(
                  onPressed: () async {
                    _permissionStatus
                      ?  _start
                            ? _completeOrderAlert(context, "${double.parse(_totalDistanceKm.toStringAsFixed(2))}","${amount.toInt()}", "${_orderId}")
                            : startLocationUpdates()
                      : await _checkPermissionStatus();

                  },
                  child: isLoading
                      ?  CircularProgressIndicator(
                      color: Colors.white)
                      :  Text(
                    _permissionStatus ? _start ? "Yakunlash" : "Ishni boshlash" : "Joylashuvga ruxsat bering",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    // elevation: 20,
                    backgroundColor: _start ? Colors.red : kPrimaryColor,
                    // minimumSize: Size.fromHeight(60),
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

  _completeOrderAlert(context, String km, String amount, String id) async {
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

_jobError2(context) {
  Alert(
    context: context,
    type: AlertType.info,
    title: "Xatolik!",
    desc: "Buyurtma tugallanmagan ish mavjud",
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Get.offAll(MyOrders()),
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