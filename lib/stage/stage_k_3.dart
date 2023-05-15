import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';

class StageK3 extends StatefulWidget {
  const StageK3({Key? key}) : super(key: key);

  @override
  State<StageK3> createState() => _StageK3State();
}

class _StageK3State extends State<StageK3> {
  PopUps popUps = const PopUps(
      startMessage: "스테이지 3",
      quest: "바닥의 쓰레기를 치워라!",
      hints: ["힌트1", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;
  double dx = 0, dy = 0;
  List<Color> circleColors = [Colors.red, Colors.blue, Colors.green];
  List<Offset> circleOffsets = [
    const Offset(0, 0),
    const Offset(0, 0),
    const Offset(0, 0)
  ];
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;

  void initStage() {
    var appBarHeight = AppBar().preferredSize.height;
    var screenHeight = MediaQuery.of(context).size.height;
    dx = MediaQuery.of(context).size.width / 2;
    dy = (screenHeight - appBarHeight) / 2;
  }

  void deleteCircle(int index) {
    setState(() {
      circleColors[index] = Colors.transparent;
    });
  }

  //충돌감지 함수
  void checkCollisions() {
    for (int i = 0; i < circleOffsets.length; i++) {
      if (circleColors[i] != Colors.transparent &&
          distance(circleOffsets[i], Offset(dx, dy)) < 35) {
        deleteCircle(i);
        break;
      }
    }
  }

  //모든 원이 사라지면 클리어 함수 호출
  void checkClear() {
    if (circleColors.every((color) => color == Colors.transparent)) {
      popUps.showClearedMessage(context).then((value) {
        if (value == 1) {
          //다시하기 버튼 코드
          initStage();
          setState(() {});
        }
        if (value == 2) {
          //메뉴 버튼 코드
        }
      });
      print("clear");
    }
  }

  void checkBorder() {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    if (dx <= 0) {
      dx = 0;
    }
    if (dx >= width) {
      dx = width;
    }
    if (dy <= 0) {
      dy = 0;
    }
    if (dy >= height) {
      dy = height;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
      initStage();
    });

    setInitialCircleOffsets();
    _gyroscopeSubscription =
        SensorsPlatform.instance.gyroscopeEvents.listen((event) {
      setState(() {
        dx += event.y * 60;
        dy += event.x * 60;
        checkBorder();
        checkCollisions();
      });
    });
  }

  @override
  void dispose() {
    _gyroscopeSubscription.cancel();
    super.dispose();
  }

  void setInitialCircleOffsets() {
    Random random = Random();
    circleOffsets[0] =
        Offset(random.nextDouble() * 300, random.nextDouble() * 500);
    circleOffsets[1] =
        Offset(random.nextDouble() * 300, random.nextDouble() * 500);
    circleOffsets[2] =
        Offset(random.nextDouble() * 300, random.nextDouble() * 500);
  }

  double distance(Offset a, Offset b) {
    return (a - b).distance;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StageK3'),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            ...circleOffsets.asMap().entries.map((entry) {
              int index = entry.key;
              Offset offset = entry.value;
              return Positioned(
                left: offset.dx,
                top: offset.dy,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColors[index],
                  ),
                ),
              );
            }).toList(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 1000),
              transform: Matrix4.translationValues(dx, dy, 0),
              child: const CircleAvatar(
                backgroundColor: Colors.black,
                radius: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
