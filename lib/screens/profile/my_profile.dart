import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:driver_evakuator/constants.dart';

class MyProfile extends StatefulWidget {
  const MyProfile({Key? key}) : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  @override
  Widget build(BuildContext context) {
    var w = MediaQuery.of(context).size.width;
    var h = MediaQuery.of(context).size.height;
    var box = Hive.box('users');
    TextEditingController nameController = TextEditingController()
      ..text = "${box.get('name')}";
    TextEditingController phoneController = TextEditingController()
      ..text = "+998${box.get('phone')}";

    TextEditingController descriptionController = TextEditingController()
      ..text = "${box.get('data')}";

    return Scaffold(
      appBar: AppBar(
        // backgroundColor: kPrimaryColor,
        centerTitle: true,
        // automaticallyImplyLeading: false,
        title: const Text(
          "Profil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.all(w * 0.1),
          child: Column(
            // crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/icons/User Icon.svg",
                color: kPrimaryColor,
                width: w*0.2,
              ),
              // Image.asset("assets/images/profile.png", width: w * 0.4),
              const SizedBox(
                height: 25,
              ),
              TextFormField(
                readOnly: true,
                controller: nameController,
                decoration:const InputDecoration(
                  label:  Text("F.I.Sh"),
                  suffixIcon: Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                readOnly: true,
                controller: phoneController,
                decoration:const InputDecoration(
                  label:  Text("Phone"),
                  suffixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                readOnly: true,
                maxLines: 5,
                controller: descriptionController,
                decoration:const InputDecoration(
                  label:  Text("Hodim haqida"),
                  suffixIcon: Icon(Icons.info_outline),
                  border: OutlineInputBorder(),
                ),
              ),


              const SizedBox(
                height: 25,
              ),
              const SizedBox(
                height: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
