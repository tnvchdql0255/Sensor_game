import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';

class StageL3 extends StatefulWidget {
  const StageL3({super.key});

  @override
  State<StageL3> createState() => _StageL3State();
}

class _StageL3State extends State<StageL3> {
  int temperature = 0;
  int anchorTemperature = 0;
  static const methodChannel = MethodChannel("com.sensorIO.method");
  late Timer timer;
  int r = 255;
  int b = 0;

  DBHelper dbHelper = DBHelper();
  PopUps popUps = const PopUps(
      startMessage: "스테이지 3",
      quest: "시원하게 만들어라!",
      hints: ["힌트1", "힌트2", "힌트3"]);

  @override
  void initState() {
    super.initState();
    //setDefaultState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context).then(
            (value) => startTimer(),
          );
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      temperature = await methodChannel.invokeMethod("callTemperatureSensor");
      if ((temperature - 70) < anchorTemperature) {
        r = r - 25;
        b = b + 25;
        print('r: $r, b: $b');
        checkIsCooled();
      }

      setState(() {});
    });
  }

  void setDefaultState() async {
    r = 255;
    b = 0;
    anchorTemperature =
        await methodChannel.invokeMethod("callTemperatureSensor");
  }

  bool checkIsCooled() {
    if (b >= 250) {
      popUps.showClearedMessage(context);
      timer.cancel();
      return true;
    } else {
      return false;
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
        title: const Text("Stage L3"),
        elevation: 0,
        backgroundColor: Color.fromARGB(255, r, 0, b),
      ),
      backgroundColor: Color.fromARGB(255, r, 0, b),
      body: Center(
        child: Column(children: [
          TextButton(onPressed: setDefaultState, child: const Text("call?")),
          Text("currtemp: $temperature",
              style: const TextStyle(color: Colors.white)),
          Text("anchorTemp: $anchorTemperature",
              style: const TextStyle(color: Colors.white)),
        ]),
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
