// ignore_for_file: file_names, camel_case_types

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common_ui/start.dart';
import '../service/db_manager.dart';

class StageL4 extends StatefulWidget {
  const StageL4({super.key});

  @override
  State<StageL4> createState() => _StageL4State();
}

//Y축값이 event[1]에 존재함. 값이 음수
class _StageL4State extends State<StageL4> {
  double vector = 0;
  static const rotationVectorChannel = EventChannel('com.sensorIO.sensor');
  static const methodChannel = MethodChannel("com.sensorIO.method");
  StreamSubscription? rotationVectorSubscription;
  bool bgColorState = false;
  PopUps popUps = const PopUps(
      startMessage: "스테이지 4", quest: "못도망가게 해라!", hints: ["힌트1", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    setSensorState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
  }

  void setSensorState() async {
    int result = await methodChannel.invokeMethod("callRotationVectorSensor");
    if (result != 1) {
      print("sensor is not available");
    } else {
      _startReading();
    }
  }

  void _startReading() {
    rotationVectorSubscription =
        rotationVectorChannel.receiveBroadcastStream().listen((event) {
      vector = event[1];
      checkClearRule();
      setState(() {});
    });
  }

  void checkClearRule() {
    if (vector < -0.85 || vector > 0.85) {
      rotationVectorSubscription?.cancel();
      vector = 0;
      popUps.showClearedMessage(context).then(
        (value) {
          if (value == 1) {
            setSensorState();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    rotationVectorSubscription
        ?.cancel(); //스트림을 해제하지 않고 페이지에서 벗어날시 setState가 스트림채널에 물려 지속적으로 호출되어 에러가 발생한다.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Stage_L_4")),
      body: Center(child: Text("$vector")),
    );
  }
}
