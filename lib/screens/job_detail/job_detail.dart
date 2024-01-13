import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class JonDetail extends StatefulWidget {
  const JonDetail({Key? key, required this.id, required this.balans}) : super(key: key);

  final String id;
  final int balans;

  @override
  State<JonDetail> createState() => _JonDetailState();
}

class _JonDetailState extends State<JonDetail> {
  var box = Hive.box('users');
  bool getData = false;

  Map<String, dynamic> ordersData = {};

  @override
  void initState() {
    super.initState();
    getOrder();
  }

  getOrder() async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('https://mytok.uz/flutterapi/getorder.php'));
    request.fields
        .addAll({'workid': '${widget.id}', 'jobid': '${box.get('id')}'});
    http.StreamedResponse response = await request.send();
    var balans = int.parse(box.get('balans')) - int.parse(widget.balans);
    box.put('balans', "${balans}");
    var res = await response.stream.bytesToString();
    final data = json.decode(res);
    setState(() {
      getData = true;
      ordersData = Map<String, dynamic>.from(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
