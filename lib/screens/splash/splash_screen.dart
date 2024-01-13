import 'package:driver_evakuator/firebase_api.dart';
import 'package:flutter/material.dart';
import 'package:driver_evakuator/controllers/api_controller.dart';
import 'package:get/get.dart';
import '../../constants.dart';

import '../sign_in/sign_in_screen.dart';
import 'components/splash_content.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentPage = 0;
  List<Map<String, String>> splashData = [
    {
      "text": "Dasturiga xush kelibsiz! Qani boshladik!",
      "image": "assets/images/intro1.png"
    },
    {
      "text":
          "Yurtimiz bo'ylab! \nIstalgan joyda chaqiring",
      "image": "assets/images/intro2.png"
    },
    {
      "text": "Sodda interfeys. \nBitta tugmani bosish orqali chaqiruv",
      "image": "assets/images/intro3.png"
    },
  ];
  @override
  Widget build(BuildContext context) {
    final ApiController api_controller = Get.put(ApiController());
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: PageView.builder(
                  onPageChanged: (value) {
                    setState(() {
                      currentPage = value;
                    });
                  },
                  itemCount: splashData.length,
                  itemBuilder: (context, index) => SplashContent(
                    image: splashData[index]["image"],
                    text: splashData[index]['text'],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: <Widget>[
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          splashData.length,
                          (index) => AnimatedContainer(
                            duration: kAnimationDuration,
                            margin: const EdgeInsets.only(right: 5),
                            height: 6,
                            width: currentPage == index ? 20 : 6,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? kPrimaryColor
                                  : const Color(0xFFD8D8D8),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(flex: 3),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: StadiumBorder(),
                          // elevation: 20,
                          backgroundColor: kPrimaryColor,
                          minimumSize: const Size.fromHeight(60),
                        ),
                        onPressed: () async {
                          Get.to(SignInScreen());
                          // var fcm = await FirebaseApi().getFCMToken();
                          // print(fcm);
                        },
                        child: const Text("KIRISH", style: TextStyle(color: Colors.white, fontSize: 18),),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
