import 'dart:convert';

import 'package:driver_evakuator/firebase_api.dart';
import 'package:driver_evakuator/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'dart:math';

import '../screens/otp/otp_screen.dart';
final random = Random();

class ApiController {
  var baseUrl = "http://94.241.168.135:3000/api/v1/mobile";
  var box = Hive.box('users');
  var isLoad = false.obs;
  var userFound = false.obs;
  var codeTrue = false.obs;
  var loginTrue = false.obs;



  Future<int?> checkCode(String code) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var kod = box.get('code');
    if(kod == code){
      var name = box.get('temp_name');
      var id = box.get('temp_id');
      var phone = box.get('temp_phone');
      var region_name = box.get('temp_region_name');
      var region_id = box.get('temp_region_id');
      var data = box.get('temp_driverdata');
      var carnumber = box.get('temp_carnumber');
      var request_fcm = http.Request(
          'POST', Uri.parse('http://94.241.168.135:9000/api/v1/mobile'));
      var fcm;
      fcm = await FirebaseApi().getFCMToken();
      request_fcm.body = json.encode({
        "jsonrpc": "2.0",
        "apiversion": "1.0",
        "params": {
          "method": "FcmUpdate",
          "body": {
            "phonenumber": phone,
            "fcmtoken": fcm
          }
        }
      });
      request_fcm.headers.addAll(headers);

      http.StreamedResponse response = await request_fcm.send();

      var res = await response.stream.bytesToString();
      Map valueMap2 = json.decode(res);
      if (valueMap2['success'] == true) {
        box.put('phone', phone);
        box.put('id', id);
        box.put('name', name);
        box.put('region_name', region_name);
        box.put('region_id', region_id);
        box.put('data', data);
        box.put('carnumber', carnumber);
        return 1;
      }
      else{
        return 0;
      }
    }
    else{
      return 0;
    }
  }

  Future<int?> Login(String phone, String password) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var loginRequest = http.Request('POST', Uri.parse('http://94.241.168.135:9000/api/v1/mobile'));
    loginRequest.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "Login",
        "body": {
          "phonenumber": "${phone}",
          "password": "${password}"
        }
      }
    });
    loginRequest.headers.addAll(headers);

    http.StreamedResponse loginResponse = await loginRequest.send();
    if(loginResponse.statusCode == 200) {
      var res = await loginResponse.stream.bytesToString();
      Map valueMap = json.decode(res);
      if (valueMap['success'] == true) {
        print("55555555555555555555555");
        print(valueMap['message']['_id']);
        final fourDigitNumber = random.nextInt(9000) + 1000;
        box.put("code","${fourDigitNumber}");
        // print(valueMap);
        box.put('temp_phone', valueMap['message']['phonenumber']);
        box.put('temp_id', valueMap['message']['_id']);
        box.put('temp_name', valueMap['message']['username']);
        box.put('temp_region_name', valueMap['message']['location']);
        box.put('temp_region_id', valueMap['message']['location_id']);
        box.put('temp_carnumber', valueMap['message']['carnumber']);
        box.put('temp_driverdata', valueMap['message']['driverdata']);
        var request = http.Request('POST', Uri.parse("http://94.241.168.135:3000/api/v1/mobile"));
        request.body = json.encode({
          "jsonrpc": "2.0",
          "apiversion": "1.0",
          "params": {
            "method": "SendSms",
            "body": {
              "phonenumber": phone,
              "smscode": fourDigitNumber
            }
          }
        });
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();
        if (response.statusCode == 200) {
          return 1;
        }
        else{
          return 0;
        }
      }
      else {
        return 0;
      }
    }
    else{
      return 0;
    }
  }


  Future<int> sendCodeSms({required String phone}) async {
    final fourDigitNumber = random.nextInt(9000) + 1000;
    box.put("code","${fourDigitNumber}");
    box.put("temp_phone",phone);
    print(fourDigitNumber);
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request('POST', Uri.parse("http://94.241.168.135:3000/api/v1/mobile"));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "SendSms",
        "body": {
          "phonenumber": phone,
          "smscode": fourDigitNumber
        }
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      return 1;
    }
    else{
      return 0;
    }
  }

  Future<int> newOrder({
    required String category,
    required String lat,
    required String long,
    required String description,
  }) async {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var request = http.Request('POST', Uri.parse('http://94.241.168.135:6000/ypx/api/v1/mobile'));
    request.body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {
        "method": "GetOrder",
        "body": {
          "category": category,
          "userphone": "${box.get('phone')}",
          "driverphone": 1,
          "lat": lat,
          "long": long,
          "regionid": "${box.get('region_id')}",
          "region": "${box.get('region_name')}",
          "description": description
        }
      }
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      var res = await response.stream.bytesToString();
      Map valueMap = json.decode(res);
      if (valueMap['success'] == true){
        return 1;
      }
      else if(valueMap['success'] == false){
        return -1;
      }
    }
    else {
      return 0;
    }
    return 0;
  }


  Future<void> send() async {
    final jwt = JWT(
      // Payload
        {
          'id': 123,
          'server': {
            'id': '3e4fc296',
            'loc': 'euw-2',
          }
        },
        issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
        header: {"test": "ypx"});
    final token = jwt.sign(SecretKey('ypx'));
    var headers = {'Content-Type': 'application/json'};
    var request = http.Request(
        'POST', Uri.parse('https://mytok.uz/flutterapi/request.php'));
    request.body = json.encode({"request": "${token}"});
    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      print(await response.stream.bytesToString());
    } else {
      print(response.reasonPhrase);
    }
  }
}


