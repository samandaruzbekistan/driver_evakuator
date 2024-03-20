import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../constants.dart';

class UpdateBalance extends StatefulWidget {
  const UpdateBalance({Key? key}) : super(key: key);

  @override
  State<UpdateBalance> createState() => _UpdateBalanceState();
}

class _UpdateBalanceState extends State<UpdateBalance> {
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  var box = Hive.box('users');

  @override
  Widget build(BuildContext context) {
    Size mediaSize;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Balansni to\'ldirish'),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Container(
          width: mediaSize.width,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/logo.png", width: mediaSize.width*0.4,),
              Text("Summani kiriting:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),),
              Container(
                width: MediaQuery.of(context).size.width*0.9,
                margin: EdgeInsets.only(
                  top: 8,
                ),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  controller: _phoneController,
                  onTap: () {},
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                        Icons.account_balance_wallet_outlined,
                        color: Colors.green),
                    border: OutlineInputBorder(
                        // borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10.0),
                    ),
                    fillColor: Colors.white,
                    filled: true,
                    focusColor: kPrimaryColor,
                    // contentPadding: EdgeInsets.only(
                    //   left: ScreenUtil().setWidth(19),
                    // ),
                    hintText: '0.00',
                  ),
                ),
              ),
              SizedBox(height: 15,),
              Container(
                width: mediaSize.width*0.5,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: StadiumBorder(),
                    elevation: 20,
                    backgroundColor: kPrimaryColor,
                    minimumSize: const Size.fromHeight(60),
                  ),
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    var userId = box.get('id');
                    final connectivityResult = await (Connectivity().checkConnectivity());
                    var headers = {
                      'Content-Type': 'application/json',
                      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ=',
                      'Cookie': 'connect.sid=s%3AuZJf5KF--xmSVXoPQR625520RjhQ0J1J.fMVdms2ySRpEy1o08DFRPwFHwsF0KEQggh6BVIq7eqQ'
                    };
                    var request = http.Request('POST', Uri.parse('https://ypx-evakuator.uz/api/order'));
                    request.body = json.encode({
                      "jsonrpc": "2.0",
                      "apiversion": "1.0",
                      "params": {
                        "method": "CreateOrder",
                        "body": {
                          "_id": "${userId}",
                          "amount": "${_phoneController.text}"
                        }
                      }
                    });
                    request.headers.addAll(headers);

                    http.StreamedResponse response = await request.send();

                    if (response.statusCode == 200) {
                      setState(() {
                        _isLoading = false;
                      });
                      // print("https://my.click.uz/services/pay?amount=${_phoneController.text}&merchant_id=23738&merchant_user_id=${userId}&service_id=31307&transaction_param=${userId}&return_url=https://ypx-evakuator.uz&card_type=humo");
                      launchUrl(Uri.parse("https://my.click.uz/services/pay?amount=${_phoneController.text}&merchant_id=23738&merchant_user_id=37935&service_id=31307&transaction_param=${userId}&return_url=https://ypx-evakuator.uz&card_type=humo"));
                      // SystemNavigator.pop();
                    }
                    else {
                      print(response.reasonPhrase);
                    }
                  },
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "TO\'LDIRISH",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
