// ignore_for_file: file_names, camel_case_types

import 'dart:async';
import 'package:flutter/material.dart';
import '../common_ui/start.dart';
import '../service/db_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';

class StageL4 extends StatefulWidget {
  const StageL4({super.key});

  @override
  State<StageL4> createState() => _StageL4State();
}

//Y축값이 event[1]에 존재함. 값이 음수
class _StageL4State extends State<StageL4> {
  double vector = 0;
  static const double GRAVITY = 9.81;
  bool isCleared = false;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  late Matrix4 ballLocationState, ballLocationStateTrue;
  late double screenHeight;
  bool bgColorState = false;
  PopUps popUps = const PopUps(
      startMessage: "스테이지 4",
      quest: "공을 꺼내라!",
      hints: ["어렵게 생각하면 안됩니다", "없음", "없음"]);
  DBHelper dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    startReading();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
  }

  void startReading() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      double x = event.x;
      double y = event.y;
      double z = event.z;
      if (y.abs() > x.abs() && y.abs() > z.abs()) {
        if (y < -GRAVITY / 2) {
          isCleared = true;
          setState(() {});
          _accelerometerSubscription?.cancel();
          dbHelper.changeIsAccessible(5, true);
          dbHelper.changeIsCleared(4, true);
          Future.delayed(const Duration(seconds: 1), () {
            popUps.showClearedMessage(context).then((value) {
              if (value == 1) {
                isCleared = false;
                setState(() {});
                startReading();
              }
            });
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _accelerometerSubscription
        ?.cancel(); //스트림을 해제하지 않고 페이지에서 벗어날시 setState가 스트림채널에 물려 지속적으로 호출되어 에러가 발생한다.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    ballLocationState =
        Matrix4.translationValues(0, MediaQuery.of(context).size.height / 3, 0);
    ballLocationStateTrue = Matrix4.translationValues(
        0, -MediaQuery.of(context).size.height / 2, 0);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        title: const Text(
          "공을 꺼내라!",
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      // ignore: sized_box_for_whitespace
      body: Stack(
          // ignore: sized_box_for_whitespace
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 2.5,
                  width: MediaQuery.of(context).size.width,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(20),
                          topEnd: Radius.circular(20)),
                      color: Colors.amber,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: AnimatedContainer(
                transform:
                    isCleared ? ballLocationStateTrue : ballLocationState,
                duration: const Duration(milliseconds: 1000),
                child: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  maxRadius: 10,
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height / 3,
                  width: MediaQuery.of(context).size.width,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(20),
                          topEnd: Radius.circular(20)),
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ]),
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
