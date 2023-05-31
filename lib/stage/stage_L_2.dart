// ignore_for_file: file_names

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
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
      quest: "엘리베이터 문을 열어라!",
      hints: ["배경이 초록으로 바뀌면 버튼을 눌러 열수 있습니다", "실제로 가보는건 어때요?", "고도와 관련이 있습니다"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;
  void getDB() async {
    db = await dbHelper.db;
  }

  static const String elevatorClosed = "assets/images/elevator_closed.svg";
  static const String elevatorOpened = "assets/images/elevator_opened.svg";
  static const String elevatorOpenable = "assets/images/elevator_openable.svg";
  String currentElevatorState = elevatorClosed;
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
      currentElevatorState = elevatorOpenable;
      return true; //앵커값보다 일정범위 이상 작거나 크면?
    } else {
      currentElevatorState = elevatorClosed;
      return false; //앵커값과 비슷하면?
    }
  }

  void initStage() {
    anchorPressure = 0;
  }

  @override
  void dispose() {
    pressureSubscription
        ?.cancel(); //스트림을 해제하지 않고 페이지에서 벗어날시 setState가 스트림채널에 물려 지속적으로 호출되어 에러가 발생한다.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColorState ? Colors.green : Colors.red,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: bgColorState ? Colors.green : Colors.red,
        title: const Text("엘리베이터 문을 열어라!"),
      ),
      body: GestureDetector(
        onTap: () {
          if (bgColorState) {
            currentElevatorState = elevatorOpened;
            pressureSubscription?.cancel();
            setState(() {});
            Future.delayed(const Duration(milliseconds: 1700), () {
              popUps.showClearedMessage(context).then((value) {
                if (value == 1) {
                  initStage();
                  _startReading();
                }
                if (value == 2) {}
              });
            });

            dbHelper.changeIsAccessible(3, true);
            dbHelper.changeIsCleared(2, true);
          }
        },
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width, // 최대 너비
              child: SvgPicture.asset(
                currentElevatorState,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 57,
        height: 57,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color.fromARGB(255, 209, 223, 243),
                width: 5,
                style: BorderStyle.solid)),
        margin: const EdgeInsets.fromLTRB(0, 70, 0, 0),
        child: FloatingActionButton(
          focusColor: Colors.white54,
          backgroundColor: const Color.fromARGB(255, 67, 107, 175),
          onPressed: () {
            popUps.showHintTabBar(context);
          },
          child: const Icon(
            Icons.tips_and_updates,
            color: Color.fromARGB(255, 240, 240, 240),
            size: 33,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
