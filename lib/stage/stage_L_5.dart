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
  int? anchorThemeState;
  Color? bg;
  Color? txt;
  late Timer timer;
  // ignore: prefer_const_constructors
  Icon themeIcon = Icon(Icons.error);
  int iconSize = 300;

  @override
  void initState() {
    super.initState();
    getinitTheme();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context).then((value) async {});
    });
  }

  void getinitTheme() async {
    anchorThemeState = await methodChannel.invokeMethod("getTheme");
    themeState = anchorThemeState!;
    timer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      anchorThemeState = await methodChannel.invokeMethod("getTheme");
      getConfig();
    });
  }

  void getConfig() {
    switch (anchorThemeState) {
      case 0:
        themeIcon = const Icon(Icons.wb_sunny, size: 350);
        bg = Colors.white;
        txt = Colors.black;
        break;
      case 1:
        themeIcon = const Icon(
          Icons.nightlight_round,
          size: 350,
          color: Colors.white,
        );
        bg = Colors.black;
        txt = Colors.white;
        break;
      case 2:
        themeIcon = const Icon(Icons.replay_outlined, size: 350);
        break;
      default:
        themeIcon = const Icon(Icons.error);
    }
    setState(() {});
    if (anchorThemeState != themeState) {
      timer.cancel();
      dbHelper.changeIsAccessible(6, true);
      dbHelper.changeIsCleared(5, true);
      popUps.showClearedMessage(context).then(
        (value) {
          if (value == 1) {
            getinitTheme();
          }
        },
      );
    }
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
        iconTheme: IconThemeData(color: txt),
        title: Text("밤낮을 바꿔라!", style: TextStyle(color: txt)),
        elevation: 0,
        backgroundColor: bg,
      ),
      backgroundColor: bg,
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
