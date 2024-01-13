import 'package:driver_evakuator/screens/forgot_password/new_password.dart';
import 'package:driver_evakuator/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../constants.dart';
import '../../../controllers/api_controller.dart';

class ResetOtpForm extends StatefulWidget {
  const ResetOtpForm({
    Key? key
  }) : super(key: key);

  @override
  _ResetOtpFormState createState() => _ResetOtpFormState();
}

class _ResetOtpFormState extends State<ResetOtpForm> {
  FocusNode? pin2FocusNode;
  FocusNode? pin3FocusNode;
  FocusNode? pin4FocusNode;
  TextEditingController number1 = TextEditingController();
  TextEditingController number2 = TextEditingController();
  TextEditingController number3 = TextEditingController();
  TextEditingController number4 = TextEditingController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    pin2FocusNode = FocusNode();
    pin3FocusNode = FocusNode();
    pin4FocusNode = FocusNode();
  }

  @override
  void dispose() {
    super.dispose();
    pin2FocusNode!.dispose();
    pin3FocusNode!.dispose();
    pin4FocusNode!.dispose();
  }

  void nextField(String value, FocusNode? focusNode) {
    if (value.length == 1) {
      focusNode!.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.put(ApiController());
    return Form(
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                width: 60,
                child: TextFormField(
                  controller: number1,
                  autofocus: true,
                  obscureText: true,
                  style: const TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    nextField(value, pin2FocusNode);
                  },
                ),
              ),
              SizedBox(
                width: 60,
                child: TextFormField(
                  controller: number2,
                  focusNode: pin2FocusNode,
                  obscureText: true,
                  style: const TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) => nextField(value, pin3FocusNode),
                ),
              ),
              SizedBox(
                width: 60,
                child: TextFormField(
                  controller: number3,
                  focusNode: pin3FocusNode,
                  obscureText: true,
                  style: const TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) => nextField(value, pin4FocusNode),
                ),
              ),
              SizedBox(
                width: 60,
                child: TextFormField(
                  controller: number4,
                  focusNode: pin4FocusNode,
                  obscureText: true,
                  style: const TextStyle(fontSize: 24),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: otpInputDecoration,
                  onChanged: (value) {
                    if (value.length == 1) {
                      pin4FocusNode!.unfocus();
                      // Then you need to check is the code is correct or not
                    }
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.15),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
              // elevation: 20,
              backgroundColor: kPrimaryColor,
              minimumSize: const Size.fromHeight(60),
            ),
            onPressed: () {
              setState(() {
                isLoading = true;
              });
              var code = "${number1.text}${number2.text}${number3.text}${number4.text}";
              var box = Hive.box('users');
              if(code == box.get("code")){
                setState(() {
                  isLoading = false;
                });
                Get.to(NewPassword());
              }
              else{
                setState(() {
                  isLoading = false;
                });
                _codeError(context);
              }
            },
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              "TEKSHIRISH",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}


_codeError(context) {
  Alert(
    context: context,
    type: AlertType.warning,
    title: "Xatolik!",
    desc: "Kod noto'g'ri",
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Navigator.pop(context),
        color: Colors.black,
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}