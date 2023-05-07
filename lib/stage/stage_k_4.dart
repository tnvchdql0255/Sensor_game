import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';

class StageK4 extends StatefulWidget {
  const StageK4({Key? key}) : super(key: key);

  @override
  State<StageK4> createState() => _StageK4State();
}

class _StageK4State extends State<StageK4> {
  PopUps popUps = const PopUps(
      startMessage: "스테이지 4",
      quest: "도미노를 쓰러뜨려라!",
      hints: ["힌트1", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;
  String _direction = '';
  String _prevDirection = '';
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      popUps.showStartMessage(context).then((value) => {});
    });
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        double x = event.x;
        double y = event.y;
        double z = event.z;
        double g = 9.81;

        // 현재 방향을 결정
        String direction = '';
        if (x.abs() > y.abs() && x.abs() > z.abs()) {
          if (x > g / 2) {
            direction = '왼쪽으로 누움';
          } else if (x < -g / 2) {
            direction = '오른쪽으로 누움';
          }
        } else if (y.abs() > x.abs() && y.abs() > z.abs()) {
          if (y > g / 2) {
            direction = '세로로 서있음';
          } else if (y < -g / 2) {
            direction = '거꾸로 세로로 서있음';
          }
        } else if (z.abs() > x.abs() && z.abs() > y.abs()) {
          if (z > g / 2) {
            direction = '화면을 위로 두었음';
          } else if (z < -g / 2) {
            direction = '화면을 아래로 두었음';
          }
        }

        // 이전 방향과 현재 방향을 비교하여 클리어 여부를 결정
        if (_prevDirection == '세로로 서있음' &&
            direction != '세로로 서있음' &&
            (direction == '화면을 위로 두었음' || direction == '화면을 아래로 두었음')) {
          _direction = '클리어';
          popUps.showClearedMessage(context).then((value) {
            if (value == 1) {
              //다시하기 버튼 코드
              setState(() {});
            }
            if (value == 2) {
              //메뉴 버튼 코드
            }
          });
          dbHelper.changeIsAccessible(7, true);
          dbHelper.changeIsCleared(6, true);
        } else {
          _direction = direction;
        }
        _prevDirection = direction;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    accelerometerEvents.drain();
    _accelerometerSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage K4'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.screen_rotation,
              size: 100,
            ),
            const SizedBox(height: 30),
            Text(
              _direction,
              style: const TextStyle(fontSize: 30),
            ),
          ],
        ),
      ),
    );
  }
}
