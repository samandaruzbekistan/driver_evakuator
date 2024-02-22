import 'package:flutter/material.dart';

class OldJobDetail extends StatefulWidget {
  const OldJobDetail({
    Key? key,
    required this.category,
    required this.username,
    required this.userphone,
    required this.region,
    required this.description,
    required this.lat,
    required this.long,
  }) : super(key: key);

  final String category;
  final String username;
  final String userphone;
  final String region;
  final String description;
  final String lat;
  final String long;

  @override
  State<OldJobDetail> createState() => _OldJobDetailState();
}

class _OldJobDetailState extends State<OldJobDetail> {
  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
