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
      startMessage: "스테이지 12",
      quest: "3개의 원을 없애라!",
      hints: ["검은 원으로 다른 원과 부딪혀보세요", "없음", "없음"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;
  double dx = 180, dy = 400;
  bool isCleared = false;
  List<Color> circleColors = [
    Colors.red,
    Colors.blue,
    Colors.green
  ]; // 원의 색상 목록
  List<Offset> circleOffsets = [
    const Offset(0, 0),
    const Offset(0, 0),
    const Offset(0, 0)
  ]; // 원의 오프셋 목록
  late StreamSubscription<GyroscopeEvent> _gyroscopeSubscription;

  void initStage() {
    isCleared = false;
    var appBarHeight = AppBar().preferredSize.height;
    var screenHeight = MediaQuery.of(context).size.height;
    dx = MediaQuery.of(context).size.width / 2; // x 좌표 계산
    dy = (screenHeight - appBarHeight) / 2; // y 좌표 계산

    setInitialCircleOffsets(); // 초기 원의 오프셋 설정

    setState(() {
      circleColors = [Colors.red, Colors.blue, Colors.green];
    });
  }

  void deleteCircle(int index) {
    setState(() {
      circleColors[index] = Colors.transparent; // 해당 인덱스의 원을 투명하게 처리하여 삭제
    });
  }

  // 충돌 감지 함수
  void checkCollisions() {
    for (int i = 0; i < circleOffsets.length; i++) {
      if (circleColors[i] != Colors.transparent &&
          distance(circleOffsets[i], Offset(dx, dy)) < 35) {
        deleteCircle(i); // 원과 충돌 시 해당 인덱스의 원을 삭제
        break;
      }
    }
    // 모든 원이 없어지면 클리어
    if (circleColors.every((color) => color == Colors.transparent) &&
        !isCleared) {
      isCleared = true;
      Future.delayed(const Duration(milliseconds: 800), () {
        popUps.showClearedMessage(context).then((value) {
          if (value == 1) {
            // 다시하기 버튼 코드
            initStage();
            setState(() {});
          }
          if (value == 2) {
            // 메뉴 버튼 코드
          }
        });
      });
      dbHelper.changeIsAccessible(13, true);
      dbHelper.changeIsCleared(12, true);
    }
  }

  // 모든 원이 사라지면 클리어 함수 호출
  void checkClear() {
    if (circleColors.every((color) => color == Colors.transparent)) {
      popUps.showClearedMessage(context).then((value) {
        if (value == 1) {
          // 다시하기 버튼 코드
          initStage();
          setState(() {});
        }
        if (value == 2) {
          // 메뉴 버튼 코드
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
    if (dx >= width - 25) {
      // 원의 너비(50)를 고려하여 제한
      dx = width - 25;
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
      initStage(); // 스테이지 초기화
    });
    _gyroscopeSubscription =
        SensorsPlatform.instance.gyroscopeEvents.listen((event) {
      setState(() {
        dx += event.y * 60; // 기울기에 따라 x 좌표 조정
        dy += event.x * 60; // 기울기에 따라 y 좌표 조정
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
    circleOffsets[0] = Offset(random.nextDouble() * 300,
        random.nextDouble() * 500); // 첫 번째 원의 초기 오프셋 설정
    circleOffsets[1] = Offset(random.nextDouble() * 300,
        random.nextDouble() * 500); // 두 번째 원의 초기 오프셋 설정
    circleOffsets[2] = Offset(random.nextDouble() * 300,
        random.nextDouble() * 500); // 세 번째 원의 초기 오프셋 설정
  }

  double distance(Offset a, Offset b) {
    return (a - b).distance; // 두 점 사이의 거리 계산
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        width: 57,
        height: 57,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color.fromARGB(255, 209, 223, 243),
            width: 5,
            style: BorderStyle.solid,
          ),
        ),
        margin: const EdgeInsets.fromLTRB(0, 70, 0, 0),
        child: FloatingActionButton(
          focusColor: Colors.white54,
          backgroundColor: const Color.fromARGB(255, 67, 107, 175),
          onPressed: () {
            popUps.showHintTabBar(context); // 힌트 탭바 보여주기
          },
          child: const Icon(
            Icons.tips_and_updates,
            color: Color.fromARGB(255, 240, 240, 240),
            size: 33,
          ),
        ),
      ),
      // 힌트를 보여주는 탭바는 화면의 오른쪽 상단에 위치한다
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      appBar: AppBar(
        title: const Text(
          '3개의 원을 없애라!',
          style: TextStyle(
              color: Color.fromARGB(255, 67, 107, 175),
              fontSize: 28,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: const Color(0xfffafafa),
        elevation: 0.0,
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
