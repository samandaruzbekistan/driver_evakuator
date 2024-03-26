

import 'package:driver_evakuator/constants.dart';
import 'package:driver_evakuator/main.dart';
import 'package:driver_evakuator/screens/home/home_screen.dart';
import 'package:driver_evakuator/screens/job_detail/test.dart';
import 'package:driver_evakuator/screens/my_orders/my_orders_screen.dart';
import 'package:driver_evakuator/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

class BottomNavigationCustom extends StatefulWidget {
  const BottomNavigationCustom({Key? key, required this.screenId}) : super(key: key);
  final int screenId;
  @override
  State<BottomNavigationCustom> createState() => _BottomNavigationCustomState();

}

class _BottomNavigationCustomState extends State<BottomNavigationCustom> {
  late int selectedIndex;

  @override
  Widget build(BuildContext context) {

    selectedIndex = widget.screenId;
    return SlidingClippedNavBar.colorful(
      backgroundColor: Colors.white,
      onButtonPressed: (index) {
        setState(() {
          selectedIndex = index;
        });
        if(index == 2){
          Get.to(ProfileScreen());
        }
        else if(index == 0){
          Get.offAll(HomeScreen());
        }
        else if(index == 1){
          Get.to((MyApp3()));
          // Get.to(MyOrders());
        }
      },
      iconSize: 30,
      selectedIndex: selectedIndex,
      barItems: [
        BarItem(
          icon: Icons.home,
          title: 'Bosh menu',
          activeColor: kPrimaryColor,
          inactiveColor: Colors.grey,
        ),
        BarItem(
          icon: Icons.history_edu_rounded,
          title: 'Buyurtmalarim',
          activeColor: kPrimaryColor,
          inactiveColor: Colors.grey,
        ),
        BarItem(
          icon: Icons.settings,
          title: 'Sozlamalar',
          activeColor: kPrimaryColor,
          inactiveColor: Colors.grey,
        ),
      ],
    );
  }
}
