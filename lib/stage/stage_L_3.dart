import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';

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
  DBHelper dbHelper = DBHelper();
  PopUps popUps = const PopUps(
      startMessage: "스테이지 3",
      quest: "시원하게 만들어라!",
      hints: ["힌트1", "힌트2", "힌트3"]);

  @override
  void initState() {
    super.initState();
    setSensorState();
  }

  void setSensorState() async {
    int result = await methodChannel.invokeMethod("callTemperatureSensor");
    if (result != 1) {
      print("sensor is not available");
    }
    _startReading();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
  }

  void _startReading() {
    temperatureSubscription =
        temperatureChannel.receiveBroadcastStream().listen((event) {
      temperature = event;
      if (anchorTemperature == 0) {
        anchorTemperature = temperature; //초기 온도값을 현재 상태로 초기화
      }
      //bgColorState = getCurrentDifference();
      setState(() {});
    });
  }

  @override
  void dispose() {
    temperatureSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Stage L3")),
        body: Center(
          child: Column(children: [
            Text("$temperature"),
          ]),
        ));
  }
}
