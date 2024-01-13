import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver_evakuator/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:driver_evakuator/screens/otp/otp_screen.dart';

import '../../../components/custom_surfix_icon.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';
import '../../../controllers/api_controller.dart';
import '../../../helper/keyboard.dart';
import '../../forgot_password/forgot_password_screen.dart';
import '../../login_success/login_success_screen.dart';

class SignForm extends StatefulWidget {
  const SignForm({super.key});

  @override
  _SignFormState createState() => _SignFormState();
}

class _SignFormState extends State<SignForm> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  late Size mediaSize;
  String? password;
  bool? remember = false;
  final List<String?> errors = [];
  bool isObscure = true;
  bool isLoading = false;

  void _toggle() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    mediaSize = MediaQuery.of(context).size;
    final ApiController apiController = Get.put(ApiController());
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _phoneInput(phoneController),
          const SizedBox(height: 20),
          _buildPasswordInputField(passwordController, isObscure),
          const SizedBox(height: 20),
          // Row(
          //   children: [
          //     const Spacer(),
          //     GestureDetector(
          //       onTap: () {
          //         Get.to(ForgotPasswordScreen());
          //       },
          //       child: const Text(
          //         "Parolni unutdingizmi?",
          //         style: TextStyle(decoration: TextDecoration.underline),
          //       ),
          //     )
          //   ],
          // ),
          FormError(errors: errors),
          const SizedBox(height: 16),
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
              if (phoneController.text.length == 9){
                if (passwordController.text.length > 7){
                  setState(() {
                    isLoading = true;
                  });

                  var login = await apiController.Login(
                      phoneController.text, passwordController.text);
                  if (login == 0) {
                    setState(() {
                      isLoading = false;
                    });
                    _loginError(context);
                  }
                  else if(login == 1){
                    Get.offAll(OtpScreen());
                  }
                }
                else{
                  _passwordError(context);
                }
              }
              else{
                _onBasicAlertPressedValidate(context);
              }
            },
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              "KIRISH",
              style: TextStyle(color: Colors.white),
            ),
          ),
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

  Widget _phoneInput(TextEditingController controller) {
    final prefixText = "+998";

    final prefixStyle = TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: mediaSize.width * 0.04,
        color: Colors.black);

    return TextField(
      controller: controller,
      maxLength: 9,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "Telefon",
        prefixText: prefixText,
        prefixStyle: prefixStyle,
        suffixIcon: Icon(Icons.phone),
      ),
    );
  }
}

_loginError(context) {
  Alert(
    context: context,
    type: AlertType.warning,
    title: "Xatolik!",
    desc: "Login yoki parol xato!",
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

_passwordError(context) {
  Alert(
    context: context,
    type: AlertType.warning,
    title: "Xatolik!",
    desc: "Parol kamida 8 ta belgi bo'lishi kerak",
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