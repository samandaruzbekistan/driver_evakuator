import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LocationController extends GetxController{
  var count = 0.obs;
  var amount = RxDouble(0.0);
  var km = 0.0.obs;
  increment() => count++;


  void updateJobData (amount1, km1) {
    amount = amount1;
    km = km1;
  }

}
