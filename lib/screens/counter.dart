import 'package:driver_evakuator/controllers/counter_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Counter extends StatelessWidget {
  const Counter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CounterController controller = Get.put(CounterController());
    return Scaffold(
      appBar: AppBar(
        title: Text('Temp'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Center(
        child: Column(
          children: [
            Obx(() => Text(
                  controller.count.toString(),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                )),
            FloatingActionButton(
                onPressed: () {
                  Get.changeTheme(ThemeData.light());
                },
                child: Text('+')),
            FloatingActionButton(
                onPressed: () {
                  Get.changeTheme(Get.isDarkMode? ThemeData.light(): ThemeData.dark());
                },
                child: Text('-')),
          ],
        ),
      ),
    );
  }
}
