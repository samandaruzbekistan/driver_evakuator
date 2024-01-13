import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../constants.dart';
import '../screens/sign_in/sign_in_screen.dart';
import '../screens/sign_up/sign_up_screen.dart';

class NoAccountText extends StatelessWidget {
  const NoAccountText({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Akkauntizgiz yo'qmi? ",
          style: TextStyle(fontSize: 16),
        ),
        GestureDetector(
          onTap: () {
            Get.to(SignUpScreen());
          },
          child: const Text(
            "Ro'yhatdan o'tish",
            style: TextStyle(fontSize: 16, color: kPrimaryColor),
          ),
        ),
      ],
    );
  }
}
