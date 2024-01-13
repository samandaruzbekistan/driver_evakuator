import 'package:driver_evakuator/screens/forgot_password/components/new_pass_form.dart';
import 'package:flutter/material.dart';

import 'components/forgot_pass_form.dart';

class NewPassword extends StatelessWidget {
  static String routeName = "/forgot_password";

  const NewPassword({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yangi parol"),
      ),
      body: const SizedBox(
        width: double.infinity,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                SizedBox(height: 16),
                Text(
                  "Yangi parol kiriting",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 32),
                NewPassForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
