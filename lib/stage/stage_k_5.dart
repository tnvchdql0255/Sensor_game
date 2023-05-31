import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StageK5 extends StatefulWidget {
  const StageK5({super.key});

  @override
  State<StageK5> createState() => _StageK5State();
}

class _StageK5State extends State<StageK5> {
  PopUps popUps = const PopUps(
      startMessage: "스테이지 14",
      quest: "소리가 너무 작아!",
      hints: ["힌트1", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;
  static const platform = MethodChannel('com.sensorIO.method');
  int count = 0;
  late String _playerImage;
  Timer? imageTimer;

  void _onVolumeButtonEvent(String event) {
    if (event == "다운") {
      count = count > 0 ? count - 1 : count;
    } else if (event == "업") {
      count = count < 5 ? count + 1 : count;
      setState(() {
        if (count == 5) {
          imageTimer?.cancel();
          platform.setMethodCallHandler(null);
          _playerImage = 'assets/images/clear_player.svg';

          Future.delayed(const Duration(milliseconds: 500), () {
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
          dbHelper.changeIsAccessible(15, true);
          dbHelper.changeIsCleared(14, true);
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    imageTimer?.cancel();
    platform.setMethodCallHandler(null);
  }

  void initStage() {
    count = 0;
    _playerImage = 'assets/images/initial_player.svg';
    startImageTimer();
    platform.setMethodCallHandler((call) {
      if (call.method == 'volumeButtonEventDown') {
        _onVolumeButtonEvent("다운");
      }
      if (call.method == 'volumeButtonEventUp') {
        _onVolumeButtonEvent("업");
      }
      return Future.value(null);
    });
  }

  void startImageTimer() {
    const duration = Duration(seconds: 1);
    bool isInitialPlayer = true;

    imageTimer = Timer.periodic(duration, (timer) {
      setState(() {
        _playerImage = isInitialPlayer
            ? 'assets/images/initial_player2.svg'
            : 'assets/images/initial_player.svg';
        isInitialPlayer = !isInitialPlayer;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    initStage();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      popUps.showStartMessage(context).then((value) => {});
    });
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
        title: const Text(
          '소리가 너무 작아!',
          style: TextStyle(
              color: Color.fromARGB(255, 67, 107, 175),
              fontSize: 28,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: const Color(0xfffafafa),
        elevation: 0.0,
      ),
      body: Center(
        child: SvgPicture.asset(_playerImage),
      ),
    );
  }
}
