import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class StageL3 extends StatefulWidget {
  const StageL3({super.key});

  @override
  State<StageL3> createState() => _StageL3State();
}

class _StageL3State extends State<StageL3> {
  double temperature = 0;
  double anchorTemperature = 0;
  static const temperatureChannel = EventChannel('com.sensorIO.sensor');
  static const methodChannel = MethodChannel("com.sensorIO.method");
  StreamSubscription? temperatureSubscription;

  @override
  void initState() {
    super.initState();
  }

  void setSensorState() async {
    int result = await methodChannel.invokeMethod("callTemperatureSensor");
    if (result != 1) {
      print("sensor is not available");
    }
    _startReading();
  }

  void _startReading() {
    temperatureSubscription =
        temperatureChannel.receiveBroadcastStream().listen((event) {
      temperature = event;
      if (anchorTemperature == 0) {
        anchorTemperature = temperature; //초기 대기압 값을 현재 상태로 초기화
      }
      //bgColorState = getCurrentDifference();
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Stage L3")),
        body: Center(
          child: Column(children: const []),
        ));
  }
}
