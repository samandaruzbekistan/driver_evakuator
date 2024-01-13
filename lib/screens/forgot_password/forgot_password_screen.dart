import 'package:flutter/material.dart';

import 'components/forgot_pass_form.dart';

class ForgotPasswordScreen extends StatelessWidget {

  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parolni tiklash"),
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
                  "Telefon raqam tasdiqlash",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Parolingizni tiklash uchun\nro'yhatdan o'tgan telefon raqamingizni kiriting",
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ForgotPassForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
