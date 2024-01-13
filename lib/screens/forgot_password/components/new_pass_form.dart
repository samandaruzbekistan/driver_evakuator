import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver_evakuator/screens/sign_in/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../components/no_account_text.dart';
import '../../../constants.dart';
import '../../../controllers/api_controller.dart';

class NewPassForm extends StatefulWidget {
  const NewPassForm({super.key});

  @override
  _NewPassFormState createState() => _NewPassFormState();
}

class _NewPassFormState extends State<NewPassForm> {
  late Size mediaSize;
  final _formKey = GlobalKey<FormState>();
  TextEditingController passwordController = TextEditingController();
  List<String> errors = [];
  String? email;
  bool isLoading = false;
  bool isObscure = false;

  void _toggle() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.put(ApiController());
    mediaSize = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildPasswordInputField(passwordController,isObscure),
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
              if (passwordController.text.length > 7) {
                if (connectivityResult != ConnectivityResult.none){
                  setState(() {
                    isLoading = true;
                  });
                  if(8 == 2){
                  // shunchaki charchagandan yozildi
                  }
                  else{
                    setState(() {
                      isLoading = false;
                    });
                    var box = Hive.box('users');
                    print("${passwordController.text}");
                    var updatePassword = await apiController.UpdatePassword(phone:"${box.get("temp_phone")}", password: "${passwordController.text}");
                    if(updatePassword == 1){
                      setState(() {
                        isLoading = false;
                      });
                      _successfulyUpdated(context);
                    }
                    else{
                      setState(() {
                        isLoading = false;
                      });
                      _internetError(context);
                    }
                  }
                }
                else{
                  setState(() {
                    isLoading = false;
                  });
                  _internetError(context);
                }
              }
              else{
                setState(() {
                  isLoading = false;
                });
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

  Widget _buildPasswordInputField(TextEditingController controller, isObscure) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "Parol",
        suffixIcon: IconButton(
          icon: Icon(
            isObscure ? Icons.remove_red_eye : Icons.visibility_off,
            color: Colors.grey,
          ),
          onPressed: () {
            setState(() {
              _toggle();
            });
          },
        ),
      ),
      obscureText: isObscure,
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


_successfulyUpdated(context) {
  Alert(
    context: context,
    type: AlertType.success,
    title: "Xabar!",
    desc: "Sizning parolingiz yangilandi",
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Get.offAll(SignInScreen()),
        color: Colors.black,
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}