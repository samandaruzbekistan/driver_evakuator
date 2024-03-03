import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../constants.dart';

import 'components/otp_form.dart';

class OtpScreen extends StatelessWidget {
  static String routeName = "/otp";

  const OtpScreen({super.key, });
  @override
  Widget build(BuildContext context) {
    var box = Hive.box('users');
    var phone = "${box.get('temp_phone')}";
    var kod = "${box.get('code')}";
    return Scaffold(
      appBar: AppBar(
        title: const Text("OTP tasdiqlash"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "Kod yuborildi",
                  style: headingStyle,
                ),
                Text("Telefon raqam +998 ** *** ${phone.substring(phone.length - 4)}", style: TextStyle(fontSize: 20),),
                Text("Telefon raqam +998 ** *** ${kod}", style: TextStyle(fontSize: 20),),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     const Text("This code will expired in "),
                //     TweenAnimationBuilder(
                //       tween: Tween(begin: 60.0, end: 0.0),
                //       duration: const Duration(seconds: 30),
                //       builder: (_, dynamic value, child) => Text(
                //         "00:${value.toInt()}",
                //         style: const TextStyle(color: kPrimaryColor),
                //       ),
                //     ),
                //   ],
                // ),
                const OtpForm(),
                const SizedBox(height: 20),
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
