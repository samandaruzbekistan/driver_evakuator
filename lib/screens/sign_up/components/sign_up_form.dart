import 'dart:convert';
import 'dart:math';

import 'package:driver_evakuator/controllers/api_controller.dart';
import 'package:driver_evakuator/screens/otp/otp_screen.dart';
import 'package:driver_evakuator/screens/sign_in/sign_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../../../components/form_error.dart';
import '../../../constants.dart';
import '../../complete_profile/complete_profile_screen.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  String? email;
  String? password;
  String? conform_password;
  bool isObscure = true;
  bool remember = false;
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  late Size mediaSize;
  final List<String?> errors = [];
  List<Map<String, dynamic>> regions = [];
  List<DropdownMenuItem<String>> dropdownItems = [];
  String? selectedValue = null;
  String? selectedRegionName = null;
  bool isLoading = false;

  void fetchDataFromApi() {
    var headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer eXB4ZXZha3VhdG9ycGFzc3dvcmQ='
    };
    var body = json.encode({
      "jsonrpc": "2.0",
      "apiversion": "1.0",
      "params": {"method": "GetLocation"}
    });

    http
        .post(Uri.parse('http://94.241.168.135:3000/api/v1/mobile'),
        headers: headers, body: body)
        .then((response) {
      if (response.statusCode == 200) {
        var temp = json.decode(response.body);
        final List<Map<String, dynamic>> data =
        List<Map<String, dynamic>>.from(temp['messages']);
        setState(() {
          regions = data;
          dropdownItems = data.map((item) {
            return DropdownMenuItem<String>(
              child: Text(item['location']),
              value: item['_id'].toString(),
            );
          }).toList();
        });
      } else {
        _internetError(context);
      }
    }).catchError((error) {
      _internetError(context);
    });
  }

  Map<String, dynamic> findRegionById(String id) {
    Map<String, dynamic> region = regions.firstWhere(
            (region) => region['_id'] == id,
        orElse: () => Map<String, dynamic>.from({}));
    return region;
  }

  void _toggle() {
    setState(() {
      isObscure = !isObscure;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromApi();
  }

  @override
  Widget build(BuildContext context) {
    final ApiController apiController = Get.put(ApiController());
    mediaSize = MediaQuery.of(context).size;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildNameInputField(nameController),
          const SizedBox(height: 20),
          _phoneInput(phoneController),
          const SizedBox(height: 20),
          _buildPasswordInputField(passwordController, isObscure),
          const SizedBox(height: 20),
          DropdownButtonFormField(
              hint: Text("Hududni tanlang"),
              validator: (value) => value == null ? "Select a country" : null,
              // dropdownColor: Colors.blueAccent,
              value: selectedValue,
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                  selectedRegionName = dropdownItems
                      .firstWhere((item) => item.value == newValue)
                      .child
                      .toString();
                });
              },
              items: dropdownItems),
          const SizedBox(height: 20),
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
                if (selectedValue == null) {
                  _regionError(context);
                } else {
                  if (passwordController.text.length > 7) {
                    if (connectivityResult != ConnectivityResult.none) {
                      var region_ = findRegionById(selectedValue!);
                      setState(() {
                        isLoading = true;
                      });
                      var result = await apiController.TempSaveUserData(
                          name: nameController.text,
                          phone: phoneController.text,
                          password: passwordController.text,
                          location_id: "${selectedValue}",
                          location_name: "${region_['location']}");
                      setState(() {
                        isLoading = false;
                      });
                      if(result == 0){
                        _userError(context);
                      }
                      else if(result == -1){
                        _internetError(context);
                      }
                      else if(result == 1){
                        Get.to(OtpScreen());
                      }
                    } else {
                      _internetError(context);
                    }
                  } else {
                    _passwordError(context);
                  }
                }
              } else {
                _onBasicAlertPressedValidate(context);
              }
            },
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
              "RO'YHATDAN O'TISH",
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

  Widget _buildNameInputField(TextEditingController controller,
      {isPassword = false}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "Ism Familya",
        suffixIcon: isPassword
            ? Icon(Icons.remove_red_eye)
            : Icon(Icons.account_circle_outlined),
      ),
      obscureText: isPassword,
    );
  }

  _alert(context) {
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

_userError(context) {
  Alert(
    context: context,
    type: AlertType.error,
    title: "Xatolik!",
    desc: "Foydalanuvchi mavjud",
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Get.to(SignInScreen()),
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

_regionError(context) {
  Alert(
    context: context,
    type: AlertType.warning,
    title: "Xatolik!",
    desc: "Hudud tanlanmagan",
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
