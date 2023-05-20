import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

class StageS3 extends StatefulWidget {
  const StageS3({super.key});

  @override
  State<StageS3> createState() => _StageS3State();
}

class _StageS3State extends State<StageS3> with SingleTickerProviderStateMixin {
  //스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps = const PopUps(
    startMessage: "스테이지 4",
    quest: "그대로 멈춰라",
    hints: ["움직이지 안돼!", "터치도 하면 안돼!!", "핸드폰을 그대로 두고 3초간 기다려봐"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;

  //DB를 불러오는 getDB 함수 생성
  void getDB() async {
    db = await dbHelper.db;
  }

  bool _isCleared = false;
  Timer? _timer;
  bool _isTilted = false;  
  bool _isTouchFailed = false;  
  bool _isGravityFailed = false;

  final double sensitivity = 0.1; // 원하는 감도 값으로 수정해주세요. 숫자를 올리면 감도가 떨어지고, 내리면 감도가 올라갑니다.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
    _startTimer();
    _startListening();
  }

  void _startTimer() {  // 3초 타이머 시작
    _timer = Timer(const Duration(seconds: 3), () {  //
      if (_isTilted && !_isGravityFailed) {   
        setState(() {
          _isCleared = true;
        });
        popUps.showClearedMessage(context).then((value) {
          if (value == 1) {
            initStage();
            //initState();
          }
          if (value == 2) {}
        });
        dbHelper.changeIsAccessible(4, true);
        dbHelper.changeIsCleared(5, true);
      } /*else if (_isTouchFailed && !_isTouchFailed) {
        popUps.showFailedMessage(context).then((value) {
          if (value == 1) {
            initStage();
          }
          if (value == 2) {

          }
        });
      }*/
    });
  }

  void _startListening() { // 기울기 센서 시작
    gyroscopeEvents.listen((event) {   //자이로스코프 센서 사용
      final x = event.x;
      final y = event.y;
      final z = event.z;

    // 여기에 허용할 각도 범위를 설정할 수 있습니다.
    if (x >= -sensitivity && x <= sensitivity &&
        y >= -sensitivity && y <= sensitivity &&
        z >= -sensitivity && z <= sensitivity) {
        _isTilted = true;
    } else {
        _isTilted = false;
      }
    });
  }

  void _stopListening() {  // 센서 종료
    _timer?.cancel();
    gyroscopeEvents.drain();
  }

  void initStage() {  //스테이지 초기화
    _isCleared = false;
    _isTouchFailed = false;
    _isGravityFailed = false;
    _isTilted = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('stage4'),
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isTouchFailed = true;
            _stopListening();
          });
          popUps.showFailedMessage(context).then((value) {
            if (value == 1) {
              initStage();
            }
            if (value == 2) {
              
            }
          });
        },
        behavior: HitTestBehavior.opaque, // 화면 전체 영역에 대한 터치 이벤트 처리
        child: Center(
          child: _isCleared
              ? const Text(
                  '성공',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                )
              : _isTilted
                  ? const Text(
                      '스테이지 선택으로 나가!',
                      style: TextStyle(fontSize: 18),
                    )
                  : const Text(
                      '그대로 유지해!',
                      style: TextStyle(fontSize: 18),
                    ),
        ),
      ),
    );
  }
}