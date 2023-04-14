import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vibration/vibration.dart';

class StageK2 extends StatefulWidget {
  const StageK2({super.key});

  @override
  State<StageK2> createState() => _StageK2State();
}

class _StageK2State extends State<StageK2> {
  PopUps popUps = const PopUps(
      startMessage: "스테이지 3",
      quest: "나무의 사과를 떨어뜨려라!",
      hints: ["힌트1", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;
  late int _count;
  late Image _image;
  AccelerometerEvent? _event;
  StreamSubscription<AccelerometerEvent>? _streamSubscription;

  void getDB() async {
    db = await dbHelper.db;
  }

  void startListening() {
    _streamSubscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        setState(() {
          _event = event;
          if (_isShaking(event)) {
            // 흔들림을 감지한 경우 진동 효과를 주고 실행할 작업
            Vibration.vibrate(duration: 10); // 0.01초간 진동
            _count++;
            if (_count == 5) {
              // 흔들림 5번 감지되면 클리어
              _image = Image.asset('assets/icons/drop_apple.png');
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
              dbHelper.changeIsAccessible(5, true);
              dbHelper.changeIsCleared(4, true);
            }
          }
        });
      },
    );
  }

  void stopListening() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
  }

  @override
  void initState() {
    super.initState();
    initStage();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      popUps.showStartMessage(context).then((value) => {});
    });
    startListening();
  }

  void initStage() {
    _count = 0;
    _image = Image.asset('assets/icons/apple.png');
  }

  bool _isShaking(AccelerometerEvent event) {
    const double shakeThreshold = 15.0; // 흔들림 감지 임계값
    return (event.x.abs() > shakeThreshold ||
        event.y.abs() > shakeThreshold ||
        event.z.abs() > shakeThreshold);
  }

  @override
  void dispose() {
    stopListening();
    accelerometerEvents.drain();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage 3'),
      ),
      body: Center(
        child: _image,
        // child: Text(
        //   // "$_count",
        //   // style: const TextStyle(fontSize: 100),
        // ),
        // child: Text(
        //   _event != null
        //       ? 'Accelerometer: ${_event!.x.toStringAsFixed(2)}, ${_event!.y.toStringAsFixed(2)}, ${_event!.z.toStringAsFixed(2)}'
        //       : 'Accelerometer not available',
        // ),
      ),
    );
  }
}
