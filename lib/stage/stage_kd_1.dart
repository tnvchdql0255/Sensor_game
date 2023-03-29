import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class StageK1 extends StatefulWidget {
  const StageK1({super.key});

  @override
  State<StageK1> createState() => _StageK1State();
}

class _StageK1State extends State<StageK1> {
  List accelerometer = [];
  List gyroscope = [];

  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((AccelerometerEvent e) {
      setState(() {
        accelerometer = <double>[e.x, e.y, e.z];
      });
    });
    gyroscopeEvents.listen((GyroscopeEvent e) {
      setState(() {
        gyroscope = <double>[e.x, e.y, e.z];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              accelerometer.toString(),
            ),
            Text(
              gyroscope.toString(),
            )
          ],
        ),
      ),
    );
  }
}
