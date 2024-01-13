import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:geolocator/geolocator.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;
import 'package:driver_evakuator/screens/login_success/login_success_screen.dart';

import '../../constants.dart';
import '../../controllers/api_controller.dart';

class NewOrder extends StatefulWidget {
  const NewOrder({Key? key, required this.category, required this.avatar}) : super(key: key);

  final String category;
  final String avatar;
  @override
  State<NewOrder> createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  var box = Hive.box('users');
  bool _isLoading = false;
  late TextEditingController _descriptionController;
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController();
    _nameController = TextEditingController(text: "${box.get('name')}");
    _phoneController = TextEditingController(text: "${box.get('phone')}");
  }

  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    late String lat;
    late String long;
    final ApiController apiController = Get.put(ApiController());


    Future<Position> _getCurrentLocation() async {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        await _locationError(context);
        throw Exception("Location service is not enabled");
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        setState(() {
          _isLoading = false;
        });
        await _locationError(context);
        throw Exception("Location permission denied");
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        await _locationError(context);
        throw Exception("Location permission denied forever");
      }

      return await Geolocator.getCurrentPosition();
    }


    return Scaffold(
      appBar: AppBar(title: Text('Yangi chaqiruv'),),
      body: SingleChildScrollView(
        child:Container(
          padding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: h * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image.asset("assets/icons/${widget.avatar}.png", width: (MediaQuery.of(context).size.width*0.3)),
                  SizedBox(width: 20,),
                  Text(
                    "${widget.category}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 25, color: kPrimaryColor),
                  )
                ],
              ),
              SizedBox(
                height: h * 0.04,
              ),
              _nameInput(_nameController),
              SizedBox(
                height: h * 0.02,
              ),
              _phoneInput(_phoneController),
              SizedBox(
                height: h * 0.02,
              ),
              _descriptionInput(_descriptionController),
              SizedBox(
                height: h * 0.02,
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  final connectivityResult =
                  await (Connectivity().checkConnectivity());
                  if(_descriptionController.text.length > 0){
                    if (connectivityResult != ConnectivityResult.none) {
                      final position = await _getCurrentLocation();
                      setState(() {
                        lat = '${position.latitude}';
                        long = '${position.longitude}';
                      });
                      var result = await apiController.newOrder(category: widget.category, lat: lat, long: long, description: _descriptionController.text);
                      if(result == 1){
                        Get.to(LoginSuccessScreen());
                        setState(() {
                          _isLoading = false;
                        });
                      }
                      else if(result == -1){
                        _orderFound(context);
                        setState(() {
                          _isLoading = false;
                        });
                      }
                      else{
                        _internetError(context);
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                    else {
                      _internetError(context);
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                  else{
                    _validateError(context);
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: StadiumBorder(),
                  // elevation: 20,
                  backgroundColor: kPrimaryColor,
                  minimumSize: const Size.fromHeight(60),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  "Chaqirish",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 25),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
  Widget _descriptionInput(TextEditingController controller) {
    return TextField(
      controller: controller,
      maxLength: 30,
      maxLines: 3,
      decoration: const InputDecoration(
        // hintText: "Manzil haqida qisqacha",
          labelText: "Manzil haqida qisqacha",
          suffixIcon: Icon(Icons.location_on_outlined),
          border: OutlineInputBorder(),
          helperMaxLines: 3
      ),
    );
  }

  Widget _nameInput(TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: const InputDecoration(
          labelText: "Ism Familya",
          suffixIcon: Icon(Icons.person_outline),
          border: OutlineInputBorder(),
          helperMaxLines: 3
      ),
    );
  }

  Widget _phoneInput(TextEditingController controller) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: const InputDecoration(
          labelText: "Telefon",
          suffixIcon: Icon(Icons.phone),
          border: OutlineInputBorder(),
          helperMaxLines: 3
      ),
    );
  }
}



_internetError(context) {
  Alert(
    context: context,
    type: AlertType.error,
    title: "Xatolik!",
    desc: "Internetga ulanmagansiz",
    buttons: [
      DialogButton(
        child:  Text(
          "OK",
          style:  TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Navigator.pop(context),
        color: Colors.black,
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}

_validateError(context) {
  Alert(
    context: context,
    type: AlertType.error,
    title: "Xatolik!",
    desc: "Qisqacha manzil haqida yozmagansiz",
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Navigator.pop(context),
        color: Colors.black,
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}


Future<void> _locationError(context) async {
  await Alert(
    context: context,
    type: AlertType.warning,
    title: "Xatolik!",
    desc: "Joylashuvni olish uchun ilovaga ruhsat zarur. Qayta urinib ko'ring",
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Navigator.pop(context),
        color: Colors.black,
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}

_orderFound(context) {
  Alert(
    context: context,
    type: AlertType.warning,
    title: "Ogoxlantirish!",
    desc: "Sizda faol chaqiruvlar mavjud",
    buttons: [
      DialogButton(
        child: Text(
          "OK",
          style: TextStyle(color: Colors.white, fontSize: 14),
        ),
        onPressed: () => Navigator.pop(context),
        color: Colors.black,
        radius: BorderRadius.circular(0.0),
      ),
    ],
  ).show();
}
