import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';


class StageS4 extends StatefulWidget {
  const StageS4({super.key});

  @override
  State<StageS4> createState() => _StageS4State();
}

class _StageS4State extends State<StageS4> {
  //스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps = const PopUps(
    startMessage: "스테이지 5",
    quest: "보물이 있는 방향은?!",
    hints: ["나침반을 활용해보세요", "천천히 움직이세요", "동쪽을 바라보고 기다리세요"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;

  //DB를 불러오는 getDB 함수 생성
  void getDB() async {
    db = await dbHelper.db;
  }
  double _heading = 0.0; // 나침반의 현재 방향
  bool _isClear = false;
  int _time = 0;
  static const int _clearThreshold = 3; // 클리어를 위한 동쪽을 바라보는 시간(초)

  late StreamSubscription<CompassEvent> _compassSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
    startCompassListener();

  }

  void startCompassListener() {
    _compassSubscription = FlutterCompass.events!.listen((event) {
      if (_isClear) {
        return; 
      }
      setState(() {
        _heading = event.heading ?? 0.0; // 나침반의 현재 방향 업데이트

        if (_heading >= 75 && _heading <= 105) {
          // 동쪽(0도 기준으로 약간의 여유 범위를 둠)
          _time++;
          if (_time >= _clearThreshold && !_isClear) {
            _isClear = true;

            popUps.showClearedMessage(context).then((value) {
              if (value == 1) {
                initStage();
              }
              if (value == 2) {}
            });
            dbHelper.changeIsAccessible(19, true);
            dbHelper.changeIsCleared(18, true);
          }
        } else {
          _time = 0; // 동쪽을 바라보지 않으면 시간 초기화
          _isClear = false; // 클리어 상태 초기화
        }
      });
    });
  }

  void initStage() {
    setState(() {
    _heading = 0.0;
    _isClear = false;
    _time = 0;
    });
  }

  @override
  void dispose() {
    _compassSubscription.cancel();
    _time = 0; //문제 있으면 지우기
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
        title: const Text('보물이 있는 방향은?!'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if(!_isClear)
              Transform.rotate(
                angle: _heading * (3.141592653589793238 / 180), // 각도를 라디안으로 변환하여 적용
                child: SvgPicture.asset(
                  'assets/images/compass.svg', // 나침반 이미지 경로
                width: 400,
                height: 400,
              ),
            ),
            if(_isClear)
              SvgPicture.asset(
                'assets/images/treasure.svg', // 나침반 이미지 경로
                width: 400,
                height: 400,
              ),
             const SizedBox(height: 20),
            Text(
              _isClear ? '보물을 찾았어요!!' : '보물은 동쪽에 있어요!!',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            Text(
              '클리어 시간: $_time 초',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}