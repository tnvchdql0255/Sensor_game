import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';

class StageL5 extends StatefulWidget {
  const StageL5({super.key});

  @override
  State<StageL5> createState() => _StageL5State();
}

class _StageL5State extends State<StageL5> {
  PopUps popUps = const PopUps(
      startMessage: "스테이지 5",
      quest: "밤, 낮을 바꿔라!",
      hints: ["시간과 크게 관련은 없습니다", "밝은걸 싫어하는 유저들은\n 처음에 밤일겁니다", "상태바 어딘가에.."]);
  DBHelper dbHelper = DBHelper();
  static const methodChannel = MethodChannel("com.sensorIO.method");
  int themeState = 2;
  int anchorThemeState = 2;
  late Timer timer;
  // ignore: prefer_const_constructors
  Icon themeIcon = Icon(Icons.error);
  int iconSize = 300;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context).then((value) async {
        initStage();
        anchorThemeState = await methodChannel.invokeMethod("getConfigData");
      });
    });
  }

  void initStage() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      getTest();
    });
  }

  void getTest() async {
    themeState = await methodChannel.invokeMethod("getConfigData");
    print(themeState);
    getConfig();
    checkCondition();
  }

  void checkCondition() {
    if (anchorThemeState != themeState) {
      timer.cancel();
      popUps.showClearedMessage(context).then(
        (value) {
          if (value == 1) {
            resetStage();
          }
        },
      );
    }
  }

  void resetStage() {
    anchorThemeState = themeState;
    initStage();
  }

  void getConfig() {
    switch (themeState) {
      case 0:
        themeIcon = const Icon(Icons.nightlight_round, size: 300);
        break;
      case 1:
        themeIcon = const Icon(Icons.wb_sunny, size: 300);
        break;
      case 2:
        themeIcon = const Icon(Icons.replay_outlined, size: 300);
        break;
      default:
        themeIcon = const Icon(Icons.error);
    }
    setState(() {});
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("밤낮을 바꿔라!"),
        elevation: 0,
        backgroundColor: Colors.lightBlue,
      ),
      backgroundColor: Colors.lightBlue,
      body: Center(
        child: themeIcon,
      ),
      floatingActionButton: FloatingActionButton(
          tooltip: "힌트",
          onPressed: () {
            popUps.showHintTabBar(context);
          },
          child: const Icon(Icons.question_mark)),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}
