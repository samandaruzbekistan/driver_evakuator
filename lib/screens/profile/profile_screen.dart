import 'package:get/get.dart';
import 'package:driver_evakuator/components/bottomNavigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../contact/contact_screen.dart';
import 'components/profile_menu.dart';
import 'my_profile.dart';

class ProfileScreen extends StatelessWidget {
  static String routeName = "/profile";

  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    Size mediaSize;
    mediaSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Image.asset("assets/images/logo.png", width: mediaSize.width*0.4,),
            const Text(
              "SIRDARYO YOSHLAR TEXNOPARKI",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ProfileMenu(
              text: "Mening profilim",
              icon: "assets/icons/User Icon.svg",
              press: () => {
                Get.to(MyProfile())
              },
            ),
            // ProfileMenu(
            //   text: "Bildirishnomalar",
            //   icon: "assets/icons/Bell.svg",
            //   press: () {},
            // ),
            // ProfileMenu(
            //   text: "Sozlamalar",
            //   icon: "assets/icons/Settings.svg",
            //   press: () {},
            // ),
            ProfileMenu(
              text: "Bog'lanish",
              icon: "assets/icons/Call.svg",
              press: () {
                Get.to(Contact());
              },
            ),
            ProfileMenu(
              text: "Hisobni to'ldirish",
              icon: "assets/icons/Cash.svg",
              press: () {
                final url = Uri.parse('https://ypx-evakuator.uz/payment');
                launchUrl(url, mode: LaunchMode.externalApplication);
              },
            ),
            ProfileMenu(
              text: "Chiqish",
              icon: "assets/icons/Log out.svg",
              press: () {
                var box = Hive.box('users');
                box.clear();
                SystemNavigator.pop();
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationCustom(screenId: 2,),
    );
  }
}
