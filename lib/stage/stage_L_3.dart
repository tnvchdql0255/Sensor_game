import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';

class StageL3 extends StatefulWidget {
  const StageL3({super.key});

  @override
  State<StageL3> createState() => _StageL3State();
}

class _StageL3State extends State<StageL3> {
  int temperature = 1000;
  int anchorTemperature = 0;
  static const methodChannel = MethodChannel("com.sensorIO.method");
  late Timer timer;
  int r = 255;
  int b = 0;
  String currentSoupState = "assets/images/soup_hot.svg";
  static const String soupHot = "assets/images/soup_hot.svg";
  static const String soupCooled = "assets/images/soup_cooled.svg";

  DBHelper dbHelper = DBHelper();
  PopUps popUps = const PopUps(
      startMessage: "스테이지 3",
      quest: "시원하게 만들어라!",
      hints: [
        "온도를 낮추는게 관건 입니다",
        "스테이지 진입 시점의 스마트폰 온도보다 낮아야 합니다.",
        "스마트폰 뒷면에 찬물을 묻혀 보세요"
      ]);

  @override
  void initState() {
    super.initState();
    setDefaultState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context).then(
            (value) => startTimer(),
          );
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      temperature = await methodChannel.invokeMethod("callTemperatureSensor");
      if ((anchorTemperature - temperature) >= 2) {
        r = r - 25;
        b = b + 25;
        checkIsCooled();
      }

      setState(() {});
    });
  }

  void setDefaultState() async {
    r = 255;
    b = 0;
    temperature = await methodChannel.invokeMethod("callTemperatureSensor");
    anchorTemperature =
        await methodChannel.invokeMethod("callTemperatureSensor");
  }

  bool checkIsCooled() {
    if (b >= 250) {
      currentSoupState = soupCooled;
      setState(() {});
      popUps.showClearedMessage(context).then((value) => resetStage());
      timer.cancel();
      return true;
    } else {
      return false;
    }
  }

  resetStage() {
    setState(() {
      r = 255;
      b = 0;
      currentSoupState = soupHot;
    });
    startTimer();
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
        title: const Text("Stage L3"),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, r, 0, b),
      ),
      backgroundColor: Color.fromARGB(255, r, 0, b),
      body: Stack(
        children: [
          Center(
            child: Column(children: [
              SizedBox(
                width: MediaQuery.of(context).size.width, // 최대 너비
                child: SvgPicture.asset(
                  currentSoupState,
                  fit: BoxFit.contain,
                ),
              ),
            ]),
          ),
        ],
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
