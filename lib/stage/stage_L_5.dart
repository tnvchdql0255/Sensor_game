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
      hints: ["시간과 크게 관련은 없습니다", "밝은걸 싫어하는 유저들은 처음에 밤일겁니다", "상태바 어딘가에.."]);
  DBHelper dbHelper = DBHelper();
  static const methodChannel = MethodChannel("com.sensorIO.method");
  int themeState = 2;
  late int? anchorThemeState;
  int vStack = 0;
  late Timer timer;
  // ignore: prefer_const_constructors
  Icon themeIcon = Icon(Icons.error);

  @override
  void initState() {
    super.initState();
    initStage();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
  }

  void initStage() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getTest();
    });
  }

  void getTest() async {
    themeState = await methodChannel.invokeMethod("getConfigData");
    print(themeState);
    getConfig();
    checkCondition();
  }

  // void getThemeState() async {
  //   if (themeState == 2) {
  //     anchorThemeState = await methodChannel.invokeMethod("getConfigData");
  //   } else {
  //     themeState = await methodChannel.invokeMethod("getConfigData");
  //   }
  //
  //   checkCondition();
  // }

  void checkCondition() {
    if (themeState != 2 && vStack == 0) {
      anchorThemeState = themeState;
      vStack++;
    }
    if (themeState != anchorThemeState && vStack != 0) {
      resetStage();
      popUps.showClearedMessage(context).then((value) {
        if (value == 1) {}
      });
    }
  }

  void resetStage() async {
    themeState = 2;
    anchorThemeState = null;
    vStack = 0;
    await methodChannel.invokeMethod("resetThemeState");
    timer.cancel();
  }

  void getConfig() {
    switch (themeState) {
      case 0:
        themeIcon = const Icon(Icons.nightlight_round, size: 100);

        break;
      case 1:
        themeIcon = const Icon(Icons.wb_sunny, size: 100);
        break;
      case 2:
        themeIcon = const Icon(Icons.replay_outlined, size: 100);
        break;
      default:
        themeIcon = const Icon(Icons.error);
    }
    setState(() {});
  }

  @override
  void dispose() {
    timer.cancel();
    methodChannel.invokeListMethod("resetConfigData");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Temp")),
        backgroundColor: Colors.lightBlue,
        body: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
                onPressed: () {
                  popUps.showHintTabBar(context);
                },
                icon: const Icon(Icons.question_mark)),
            Center(
              child: themeIcon,
            )
          ],
        ));
  }
}
