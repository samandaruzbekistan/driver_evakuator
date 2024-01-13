import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:driver_evakuator/screens/my_orders/my_orders_screen.dart';
import '../../constants.dart';
import '../init_screen.dart';

class LoginSuccessScreen extends StatelessWidget {
  static String routeName = "/login_success";

  const LoginSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const SizedBox(),
        // title: const Text("Login Success"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 25),
          Center(
            child: Image.asset(
              "assets/images/sc.png",
              height: MediaQuery.of(context).size.width * 0.8, //40%
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            "Chaqiruv qabul qilindi",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: StadiumBorder(),
                // elevation: 20,
                backgroundColor: kPrimaryColor,
                minimumSize: const Size.fromHeight(60),
              ),
              onPressed: () {
                Get.off(MyOrders());
              },
              child: const Text("OK", style: TextStyle(color: Colors.white, fontSize: 20),),
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
