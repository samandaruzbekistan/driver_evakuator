import 'package:driver_evakuator/components/bottomNavigation.dart';
import 'package:driver_evakuator/constants.dart';
import 'package:driver_evakuator/firebase_api.dart';
import 'package:driver_evakuator/screens/new_order/new_order.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sliding_clipped_nav_bar/sliding_clipped_nav_bar.dart';

import 'components/categories.dart';
import 'components/discount_banner.dart';
import 'components/home_header.dart';



class HomeScreen extends StatefulWidget {
  static String routeName = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              HomeHeader(),
              DiscountBanner(),
              // Categories(),
              InkWell(
                onTap: () async {
                  Get.to(NewOrder(category: "YTH", avatar: "eva_call",));
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width*0.9),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFFF5F6F9),),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset("assets/icons/eva_call.png", width: (MediaQuery.of(context).size.width*0.3)),
                      SizedBox(width: 20,),
                      Text(
                        "YTX",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25, color: kPrimaryColor),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  Get.to(NewOrder(category: "Qoida buzarlik", avatar: "rule",));
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width*0.9),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFFF5F6F9),),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset("assets/icons/rule.png", width: (MediaQuery.of(context).size.width*0.3)),
                      SizedBox(width: 20,),
                      Text(
                        "Qoida buzarlik",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25, color: kPrimaryColor),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  Get.to(NewOrder(category: "Mast holatda", avatar: "alcahol",));
                },
                child: Container(
                  width: (MediaQuery.of(context).size.width*0.9),
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xFFF5F6F9),),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset("assets/icons/alcahol.png", width: (MediaQuery.of(context).size.width*0.3)),
                      SizedBox(width: 20,),
                      Text(
                        "Mast holatda",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 25, color: kPrimaryColor),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationCustom(screenId:0),
    );
  }
}
