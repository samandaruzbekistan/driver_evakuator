import 'dart:convert';

import 'package:driver_evakuator/constants.dart';
import 'package:driver_evakuator/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
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

class _JonDetailState extends State<JonDetail> {
  var box = Hive.box('users');
  bool getData = false;
  bool progress = false;
  bool isLoading = false;

  Map<String, dynamic> ordersData = {};

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
        "method": "UpdateProsecc",
        "body": {"orderid": orderId}
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
        getData = true;
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
                                launchUrl(Uri.parse('tel:' + "+998orderId"));
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
                      height: h * 0.1,
                    ),
                    Container(
                      width: w * 0.8,
                      child: ElevatedButton(
                        onPressed: () {
                          complateOrder("${widget.id}");
                        },
                        child: isLoading
                            ?  CircularProgressIndicator(
                                color: Colors.white)
                            :  Text(
                                "Ishni yakunlash",
                                style: TextStyle(color: Colors.white, fontSize: 20),
                              ),
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          // elevation: 20,
                          backgroundColor: kPrimaryColor,
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
