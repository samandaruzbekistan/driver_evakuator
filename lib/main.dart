
import 'firebase_api.dart';
import 'package:driver_evakuator/screens/home/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:driver_evakuator/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'firebase_options.dart';



Future<void> main() async {
// Ensure Flutter is initialized.
  await Hive.initFlutter();
  await Hive.openBox('users');
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(const MyApp());
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // await Firebase.initializeApp();
  await FirebaseApi().initNotification();


}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    var users = Hive.box('users');
    var user = users.get("name");
    bool isReg = false;
    if(user != null){
      isReg = true;
    }
    print(users.values);
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF7643)),
        useMaterial3: true,
      ),
      home: isReg ? HomeScreen() : SplashScreen(),
    );
  }
}


