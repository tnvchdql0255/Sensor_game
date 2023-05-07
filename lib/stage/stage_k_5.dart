import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

class StageK5 extends StatefulWidget {
  const StageK5({super.key});

  @override
  State<StageK5> createState() => _StageK5State();
}

class _StageK5State extends State<StageK5> {
  PopUps popUps = const PopUps(
      startMessage: "스테이지 5",
      quest: "소리가 너무 작아!",
      hints: ["힌트1", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;
  static const platform = MethodChannel('com.sensorIO.method');
  int count = 0;

  void _onVolumeButtonEvent(String event) {
    print('볼륨 $event 감지');
    if (event == "다운") {
      setState(() {
        count = count > 0 ? count - 1 : count;
        print(count);
      });
    } else if (event == "업") {
      count = count < 5 ? count + 1 : count;
      print(count);
      if (count == 5) {
        popUps.showClearedMessage(context).then((value) {
          if (value == 1) {
            //다시하기 버튼 코드
            setState(() {});
          }
          if (value == 2) {
            //메뉴 버튼 코드
          }
        });
        dbHelper.changeIsAccessible(8, true);
        dbHelper.changeIsCleared(7, true);

        initStage();
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    platform.setMethodCallHandler(null);
  }

  void initStage() {
    count = 0;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      popUps.showStartMessage(context).then((value) => {});
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage K5'),
      ),
      body: const Center(
        child: Text('볼륨 버튼을 눌러서 카운트를 10까지 올려보세요.'),
      ),
    );
  }
}
