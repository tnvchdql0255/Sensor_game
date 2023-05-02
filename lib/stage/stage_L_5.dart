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
  late int? themeState;
  late int anchorThemeState;
  late Timer timer;
  // ignore: prefer_const_constructors
  Icon themeIcon = Icon(Icons.error);

  @override
  void initState() {
    super.initState();
    getThemeState();
    // timer = Timer(const Duration(seconds: 1), () {
    //   getThemeState();
    // });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
  }

  void getThemeState() async {
    if (themeState == 2) {
      anchorThemeState = await methodChannel.invokeMethod("getConfigData");
    } else {
      themeState = await methodChannel.invokeMethod("getConfigData");
    }
    themeIcon = getConfig();
    setState(() {});
    checkCondition();
  }

  void checkCondition() {
    if (themeState != anchorThemeState && themeState != 2) {
      popUps.showClearedMessage(context).then(
        (value) async {
          if (value == 1) {
            await methodChannel.invokeMethod("resetThemeState");
          } else {
            await methodChannel
                .invokeMethod("resetThemeState"); //뭘 누르든간에 초기화는 해야함...아닐지도
          }
        },
      );
    }
  }

  void resetStage() async {
    themeState = 2;
    await methodChannel.invokeMethod("resetThemeState");
    timer.cancel();
  }

  Icon getConfig() {
    switch (themeState) {
      case 0:
        return const Icon(Icons.nightlight_round, size: 100);
      case 1:
        return const Icon(Icons.wb_sunny, size: 100);
      case 2:
        return const Icon(Icons.replay_outlined, size: 100);
      default:
        return const Icon(Icons.error);
    }
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
