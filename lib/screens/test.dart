import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationPage extends StatefulWidget {
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  late Position _currentPosition;
  late Position _previousPosition;
  double _totalDistance = 0;
  List<Position> locations = [];

  late StreamSubscription<Position> _positionStream;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  void _startLocationUpdates() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
          distanceFilter: 10,
          accuracy: LocationAccuracy.best
      ),
    ).listen((Position position) async {
      if (await Geolocator.isLocationServiceEnabled()) {
        _updateLocationData(position);
      } else {
        _showGpsOffDialog();
      }
    });
  }

  void _updateLocationData(Position newPosition) {
    setState(() {
      _currentPosition = newPosition;
      locations.add(_currentPosition);

      if (locations.length > 1) {
        _previousPosition = locations[locations.length - 2];
        double distanceBetweenLastTwoLocations = Geolocator.distanceBetween(
          _previousPosition.latitude,
          _previousPosition.longitude,
          _currentPosition.latitude,
          _currentPosition.longitude,
        );

        _totalDistance += distanceBetweenLastTwoLocations;
        print('Total Distance: $_totalDistance');
      }
    });
  }

  void _showGpsOffDialog() {
    print("GPS is off.");
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Make sure your GPS is on in Settings !'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _positionStream.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Manager'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Previous Latitude: ${_previousPosition?.latitude ?? '-'} \nPrevious Longitude: ${_previousPosition?.longitude ?? '-'}',
            ),
            SizedBox(height: 50),
            Text(
              'Current Latitude: ${_currentPosition?.latitude ?? '-'} \nCurrent Longitude: ${_currentPosition?.longitude ?? '-'}',
            ),
            SizedBox(height: 50),
            Text(
              'Distance: ${_formatDistance(_totalDistance)}',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDistance(double distance) {
    if (distance != null) {
      return distance > 1000
          ? '${(distance / 1000).toStringAsFixed(2)} KM'
          : '${distance.toStringAsFixed(2)} meters';
    } else {
      return '0';
    }
  }
}
