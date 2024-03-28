import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LocationController extends GetxController{
  var count = 0.obs;
  increment() => count++;
  var locationBox = Hive.box('users');


  void addLocation(double lat, double long){

    print('---------${lat}');
    print(lat);
    locationBox.put('lat', lat);
    locationBox.put('long', long);
    print("in box ${locationBox}");
  }

}
