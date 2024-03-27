import 'package:get/get.dart';
import 'package:hive/hive.dart';

class LocationController extends GetxController{
  var count = 0.obs;
  increment() => count++;

  var locationBox = Hive.box('distanceBox');

  void addLocation(double lat, double long){
    locationBox.add(LocationModel(lat: lat, long: long));
    print("in box ${locationBox}");
  }

}

@HiveType(typeId: 0)
class LocationModel extends HiveObject {
  @HiveField(0)
  double lat;

  @HiveField(1)
  double long;

  LocationModel({required this.lat, required this.long});
}