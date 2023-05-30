import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

class StageS3 extends StatefulWidget {
  const StageS3({super.key});

  @override
  State<StageS3> createState() => _StageS3State();
}

class _StageS3State extends State<StageS3> {
  //스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps = const PopUps(
    startMessage: "스테이지 4",
    quest: "그대로 멈춰라",
    hints: ["움직이지 않아야 합니다!", "터치도 하면 안돼요!!", "핸드폰을 그대로 두고 5초간 기다려보세요."],
  );
  DBHelper dbHelper = DBHelper();
  late final Database db;

  //DB를 불러오는 getDB 함수 생성
  void getDB() async {
    db = await dbHelper.db;
  }

  bool _isFailed = false;
  Timer? _timer;
  bool _isTilted = false;
  bool _isGravityFailed = false;

  final double sensitivity = 0.1;                           //원하는 감도 값. 숫자를 올리면 감도가 떨어짐

  @override
  void initState() {
    super.initState();
    //해당 스테이지가 처음 시작되면, 스테이지 설명을 출력
    WidgetsBinding.instance.addPostFrameCallback((_) {    
      popUps.showStartMessage(context);
    });
    _startTimer();
    _startListening();
  }

  void _startTimer() {
    _timer = Timer(const Duration(seconds: 5), _startTimerCallback);    //5초 후에 _startTimerCallback 함수 실행
  }

  void _startTimerCallback() {
    if (_isTilted && !_isGravityFailed) {
      setState(() {
        _isFailed = true;                                               //5초 후에 기울임이 감지되면 실패
      });
      popUps.showfailedMessage(context).then((value) {
        if (value == 1) {
          initStage();
        }
        if (value == 2) {}
      });
    } else if (!_isTilted && !_isGravityFailed) {                       //5초 후에 기울임이 감지되지 않으면 성공
      popUps.showClearedMessage(context).then((value) {
        if (value == 1) {
          initStage();
        }
        if (value == 2) {}
      });
      dbHelper.changeIsAccessible(4, true);
      dbHelper.changeIsCleared(3, true);
    }
  }

  void _startListening() {
    gyroscopeEvents.listen((event) {
      final x = event.x;
      final y = event.y;
      final z = event.z;

      if (x >= -sensitivity &&
          x <= sensitivity &&
          y >= -sensitivity &&
          y <= sensitivity &&
          z >= -sensitivity &&
          z <= sensitivity) {
        _isTilted = false;   //
      } else {
        _isTilted = true;
      }
    });
  }

  void _stopListening() {
    _timer?.cancel();
    gyroscopeEvents.drain();
  }

  void initStage() {
    setState(() {
      _isFailed = false;
      _isGravityFailed = false;
      _isTilted = false;
    });
    _startListening();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
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
      //힌트를 보여주는 탭바는 화면의 오른쪽 상단에 위치한다
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      appBar: AppBar(
        title: const Text('그대로 멈춰라!'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          setState(() {
            _isGravityFailed = true;
            _stopListening();
          });
          popUps.showfailedMessage(context).then((value) {
            if (value == 1) {
              initStage();
            }
            if (value == 2) {}
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: SvgPicture.asset(
            'assets/images/button.svg',
              width: 500,
              height: 500,
          )
        ),
      ),
    );
  }
}

