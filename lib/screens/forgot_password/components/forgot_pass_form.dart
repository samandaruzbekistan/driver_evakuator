import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver_evakuator/screens/forgot_password/new_password.dart';
import 'package:driver_evakuator/screens/otp/reset_password_otp.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../components/no_account_text.dart';
import '../../../constants.dart';
import '../../../controllers/api_controller.dart';

class ForgotPassForm extends StatefulWidget {
  const ForgotPassForm({super.key});

  @override
  _ForgotPassFormState createState() => _ForgotPassFormState();
}

class _ForgotPassFormState extends State<ForgotPassForm> {
  late Size mediaSize;
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  List<String> errors = [];
  String? email;
  bool isLoading = false;


  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.put(ApiController());
    mediaSize = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _phoneInput(phoneController),
          const SizedBox(height: 8),
          FormError(errors: errors),
          const SizedBox(height: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: StadiumBorder(),
              // elevation: 20,
              backgroundColor: kPrimaryColor,
              minimumSize: const Size.fromHeight(60),
            ),
            onPressed: () async {
              final connectivityResult =
              await (Connectivity().checkConnectivity());
              if (phoneController.text.length == 9) {
                if (connectivityResult != ConnectivityResult.none){
                  setState(() {
                    isLoading = true;
                  });
                  var checkUser = await apiController.CheckUser(phone: "${phoneController.text}");
                  if(checkUser == 0){
                    setState(() {
                      isLoading = true;
                    });
                    _userError(context);
                  }
                  else{
                    setState(() {
                      isLoading = true;
                    });
                    var sendSms = await apiController.sendCodeSms(phone:"${phoneController.text}");
                    if(sendSms == 1){
                      Get.to(ResetOtp());
                    }
                    else{
                      _internetError(context);
                    }
                  }
                }
                else{
                  setState(() {
                    isLoading = true;
                  });
                  _internetError(context);
                }
              }
              else{
                _onBasicAlertPressedValidate(context);
              }
            },
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "TEKSHIRISH",
                style: TextStyle(color: Colors.white),
              ),
          ),
          const SizedBox(height: 16),
          const NoAccountText(),
        ],
      ),
    );
  }

  Widget _phoneInput(TextEditingController controller) {
    final prefixText = "+998";

    final prefixStyle = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: mediaSize.width * 0.04,
        color: Colors.black);

    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      maxLength: 9,
      decoration: InputDecoration(
        labelText: "Telefon",
        prefixText: prefixText,
        prefixStyle: prefixStyle,
        suffixIcon: Icon(Icons.phone),
      ),
    );
  }
}


_internetError(context) {
  Alert(
    context: context,
    type: AlertType.error,
    title: "Xatolik!",
    desc: "Internetga ulanmagansiz",
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

_userError(context) {
  Alert(
    context: context,
    type: AlertType.error,
    title: "Xatolik!",
    desc: "Foydalanuvchi topilmadi",
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

_onBasicAlertPressedValidate(context) {
  Alert(
    context: context,
    type: AlertType.info,
    title: "Xatolik!",
    desc: "Telefon raqamni quidagicha kiriting:\nXX XXX XX XX",
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
