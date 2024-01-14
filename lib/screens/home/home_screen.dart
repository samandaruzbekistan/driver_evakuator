import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver_evakuator/components/bottomNavigation.dart';
import 'package:driver_evakuator/constants.dart';
import 'package:driver_evakuator/firebase_api.dart';
import 'package:driver_evakuator/screens/new_order/new_order.dart';
import 'package:driver_evakuator/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';
import 'package:http/http.dart' as http;
import '../job_detail/job_detail.dart';
import 'components/categories.dart';
import 'components/discount_banner.dart';
import 'components/home_header.dart';

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> ordersData = [];
  bool isWebSocketConnected = false;
  late int status = 0;
  late bool is_loading = false;
  var box = Hive.box('users');

  @override
  void initState() {
    super.initState();
    getBalans();
    fetchData();
  }

  Future<void> getBalans() async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request(
        'POST', Uri.parse('http://94.241.168.135:9000/api/v1/mobile'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "GetBalance",
        "body": {"phonenumber": "${box.get('phone')}"}
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    var balans_new = await response.stream.bytesToString();
    final data_balans = json.decode(balans_new);
    box.put('balans', "${data_balans['balance']}");
  }

  Future<void> fetchData() async {
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
        "method": "AllOrdes",
        "body": {"regionid": "${box.get('region_id')}"}
      }
    });
    request.headers.addAll(headers);

    final connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult != ConnectivityResult.none) {
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        var res = await response.stream.bytesToString();
        final data = json.decode(res);
        // print(data['messages']);
        if (data.isEmpty) {
          setState(() {
            status = -5;
          });
        } else {
          setState(() {
            status = 1;
            ordersData = List<Map<String, dynamic>>.from(data['messages']);
          });
        }
      } else {
        setState(() {
          status = -1;
        });
      }
    } else {
      setState(() {
        status = -2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    var region_name = box.get('region_name');
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HomeHeader(),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF4A3298),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text.rich(
                TextSpan(
                  style: TextStyle(color: Colors.white),
                  children: [
                    TextSpan(text: "Balans:\n"),
                    TextSpan(
                      text: "${box.get('balans')} so'm",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  // vertical: 16,
                ),
                child: Text(
                  "Buyurtmalar:",
                  style: TextStyle(fontSize: w * 0.05),
                )),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: FutureBuilder<dynamic>(
                future: fetchData(),
                builder: (context, snapshot) {
                  if (status == 0) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (status == -5) {
                    return Center(
                      child: Text('Buyurtmalar mavjud emas'),
                    );
                  } else if (status == -1) {
                    return Center(
                      child: Text('Buyurtmalar mavjud emas'),
                    );
                  } else if (status == -2) {
                    return Center(
                      child: Text('Internetga ulanmagansiz'),
                    );
                  } else {
                    final data = ordersData;
                    return ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return GestureDetector(
                          onTap: () async {
                            if (item['price'] <=
                                int.parse(box.get('balans'))) {
                              _buildForm(context, item['_id'], item['price']);
                            } else {
                              _balansError(context);
                            }
                          },
                          child: Card(
                            color: Colors.white,
                            child: ListTile(
                              leading: _buildLeadingIcon(item['category']),
                              title: Text(
                                item['category'] ?? '',
                                style: TextStyle(
                                    color: kPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: w * 0.06),
                              ),
                              subtitle: Text(item['description'] ?? ''),
                              trailing: CircleAvatar(
                                backgroundColor: kPrimaryColor,
                                child: Icon(
                                  Icons.check,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationCustom(screenId: 0),
    );
  }

  void _buildForm(BuildContext context, String id, int balans) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Xabar!",
      desc: "Ishni qabul qilasizmi?\nNarxi: ${balans}",
      buttons: [
        DialogButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => JonDetail(id: id, balans: balans,)));
          },
          child: Text(
            "Qabul qilish",
            style: TextStyle(color: Colors.white, fontSize: 14),
          ),
          color: Colors.black,
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }
}

_buildLeadingIcon(String category) {
  if (category == "YPX") {
    return CircleAvatar(
      child: Image.asset("assets/icons/eva_call.png"),
    );
  } else if (category == "Shit ishlari") {
    return CircleAvatar(
      child: Image.asset("assets/images/shit.png"),
    );
  } else {
    return CircleAvatar(
      child: Image.asset("assets/icons/eva_call.png"),
    );
  }
}

_balansError(context) {
  Alert(
    context: context,
    type: AlertType.info,
    title: "Xatolik!",
    desc: "Balans yetarli emas",
    buttons: [
      DialogButton(
        child: Text(
          "To'ldirish",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfileScreen(),
          ),
        ),
        color: Colors.black,
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}
