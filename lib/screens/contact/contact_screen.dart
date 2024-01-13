import 'package:flutter/material.dart';
import 'package:driver_evakuator/constants.dart';
import 'package:typicons_flutter/typicons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';



showAlert(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        elevation: 8.0,
        contentPadding: EdgeInsets.all(18.0),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
        content: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () => launchUrl(Uri.parse('tel:' + "+998908631404"!)),
                child: Container(
                  height: 50.0,
                  alignment: Alignment.center,
                  child: Text('Telefon'),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () => launchUrl(Uri.parse('sms:' + "+998908631404"!)),
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  child: Text('SMS'),
                ),
              ),
              Divider(),
              InkWell(
                onTap: () {
                  final url = Uri.parse('https://t.me/Kholboev_uz');
                  launchUrl(url, mode: LaunchMode.externalApplication);
                },
                child: Container(
                  alignment: Alignment.center,
                  height: 50.0,
                  child: Text('Telegram'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}


class Contact extends StatelessWidget {
  const Contact({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var h = MediaQuery.of(context).size.height;
    var w = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: Text("Bog'lanish"), centerTitle: true, ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: h*0.05,),
              Image.asset("assets/images/logo.png", width: w*0.4,),
              const Text(
                "SIRDARYO YOSHLAR TEXNOPARKI",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: h*0.02,),
              Visibility(
                visible: "https://ypx-evakuator.uz" != null,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 25.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(Typicons.link),
                    title: Text(
                      "Website" ?? 'Website',
                      style: TextStyle(
                        color: Colors.teal.shade900,
                        fontFamily: "Sail",
                      ),
                    ),
                    onTap: () => launchUrl(Uri.parse("https://ypx-evakuator.uz"!)),
                  ),
                ),
              ),
              Visibility(
                visible: "+998908631404" != null,
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  margin: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 25.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  color: Colors.white,
                  child: ListTile(
                    leading: Icon(Typicons.phone),
                    title: Text(
                      "Telefon" ?? 'Telefon',
                      style: TextStyle(
                        color: Colors.teal.shade900,
                        fontFamily: "Sail",
                      ),
                    ),
                    onTap: () => showAlert(context),
                  ),
                ),
              ),
              // Visibility(
              //   visible: "https://t.me/" != null,
              //   child: Card(
              //     clipBehavior: Clip.antiAlias,
              //     margin: EdgeInsets.symmetric(
              //       vertical: 10.0,
              //       horizontal: 25.0,
              //     ),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(50.0),
              //     ),
              //     color: Colors.white,
              //     child: ListTile(
              //       leading: Icon(Icons.telegram_outlined),
              //       title: Text(
              //         "Telegram" ?? 'Website',
              //         style: TextStyle(
              //           color: Colors.teal.shade900,
              //           fontFamily: "Sail",
              //         ),
              //       ),
              //       onTap: () => launchUrl(Uri.parse("https://t.me/mytoksupportbot"!)),
              //     ),
              //   ),
              // ),
              // Visibility(
              //   visible: "https://t.me/" != null,
              //   child: Card(
              //     clipBehavior: Clip.antiAlias,
              //     margin: EdgeInsets.symmetric(
              //       vertical: 10.0,
              //       horizontal: 25.0,
              //     ),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(50.0),
              //     ),
              //     color: Colors.white,
              //     child: ListTile(
              //       leading: Icon(Icons.telegram_outlined),
              //       title: Text(
              //         "Telegram kanal" ?? 'Website',
              //         style: TextStyle(
              //           color: Colors.teal.shade900,
              //           fontFamily: "Sail",
              //         ),
              //       ),
              //       onTap: () => launchUrl(Uri.parse("https://t.me/mytokuz"!)),
              //     ),
              //   ),
              // ),
              // Visibility(
              //   visible: "https://t.me/" != null,
              //   child: Card(
              //     clipBehavior: Clip.antiAlias,
              //     margin: EdgeInsets.symmetric(
              //       vertical: 10.0,
              //       horizontal: 25.0,
              //     ),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(50.0),
              //     ),
              //     color: Colors.white,
              //     child: ListTile(
              //       leading: Icon(Icons.telegram_outlined),
              //       title: Text(
              //         "Telegram bot" ?? 'Website',
              //         style: TextStyle(
              //           color: Colors.teal.shade900,
              //           fontFamily: "Sail",
              //         ),
              //       ),
              //       onTap: () => launchUrl(Uri.parse("https://t.me/mytokuzbot"!)),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
