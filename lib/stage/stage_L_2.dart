// ignore_for_file: file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import '../common_ui/start.dart';
import '../service/db_manager.dart';

class StageL2 extends StatefulWidget {
  const StageL2({super.key});

  @override
  State<StageL2> createState() => _StageL2State();
}

class _StageL2State extends State<StageL2> {
  double pressure = 0;
  double anchorPressure = 0;
  static const pressureChannel = EventChannel('com.sensorIO.sensor');
  static const methodChannel = MethodChannel("com.sensorIO.method");
  StreamSubscription? pressureSubscription;
  bool bgColorState = false;
  PopUps popUps = const PopUps(
      startMessage: "스테이지 2",
      quest: "표시된 층으로 이동해라!",
      hints: ["힌트1", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;
  void getDB() async {
    db = await dbHelper.db;
  }

  @override
  void initState() {
    super.initState();
    setSensorState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
  }

  void setSensorState() async {
    int result = await methodChannel.invokeMethod("callPressureSensor");
    if (result != 1) {
      print("sensor is not available");
    }
    _startReading();
  }

  void _startReading() {
    pressureSubscription =
        pressureChannel.receiveBroadcastStream().listen((event) {
      pressure = event;
      if (anchorPressure == 0) {
        anchorPressure = pressure; //초기 대기압 값을 현재 상태로 초기화
      }
      bgColorState = getCurrentDifference();
      setState(() {});
    });
  }

  bool getCurrentDifference() {
    if (pressure < anchorPressure - 5 || pressure > anchorPressure + 5) {
      return true; //앵커값보다 일정범위 이상 작거나 크면?
    } else {
      return false; //앵커값과 비슷하면?
    }
  }

  void initStage() {
    anchorPressure = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: bgColorState ? Colors.green : Colors.red,
        body: SafeArea(
          child: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text("$pressure"),
                  IconButton(
                    icon: bgColorState
                        ? const Icon(
                            Icons.door_sliding_outlined,
                            color: Colors.blue,
                            size: 60,
                          )
                        : const Icon(
                            Icons.door_sliding_outlined,
                            color: Colors.black,
                            size: 60,
                          ),
                    onPressed: () {
                      if (bgColorState) {
                        popUps.showClearedMessage(context).then((value) {
                          if (value == 1) {
                            initStage();
                          }
                          if (value == 2) {}
                        });
                        dbHelper.changeIsAccessible(3, true);
                        dbHelper.changeIsCleared(2, true);
                      }
                    },
                  ),
                ]),
          ),
        ));
  }
}
