import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_svg/flutter_svg.dart';

class StageL1 extends StatefulWidget {
  const StageL1({super.key});

  @override
  State<StageL1> createState() => _Stage1State();
}

class _Stage1State extends State<StageL1> {
  static const String carCharging = "assets/icons/car_charging.svg";
  static const String carIdle = "assets/icons/car_idle.svg";
  PopUps popUps = const PopUps(
      startMessage: "스테이지 1",
      quest: "자동차를 충전시켜라!",
      hints: ["힌트1", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;
  void getDB() async {
    db = await dbHelper.db;
  }

  SvgPicture currentValue = SvgPicture.asset(carIdle);
  BatteryState? _batteryState;
  final Battery _battery = Battery();
  late Timer timer;
  // ignore: unused_field
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  int persentage = 0;

  @override
  void initState() {
    super.initState();
    initStage();
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((status) {
      _batteryState = status;
    });
    //해당 메서드 안에 팝업 메서드를 넣어야 정상적으로 실행됨 (위젯트리 로딩 이후에 실행되어야 하기 때문)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
  }

  void initStage() {
    persentage = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getBatteryStatus();
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  void getBatteryStatus() async {
    setState(() {
      switch (_batteryState) {
        case BatteryState.full:
          currentValue = SvgPicture.asset(carCharging);
          persentage = persentage + 5;
          break;
        case BatteryState.charging:
          currentValue = SvgPicture.asset(carCharging);
          persentage = persentage + 5;
          break;
        case BatteryState.discharging:
          currentValue = SvgPicture.asset(carIdle);
          break;
        case BatteryState.unknown:
          currentValue = SvgPicture.asset(carIdle);
          break;
        default:
          currentValue = SvgPicture.asset(carIdle);
          break;
      }
      if (persentage == 100) {
        timer.cancel();
        popUps.showClearedMessage(context).then((value) {
          if (value == 1) {
            //다시하기 버튼 코드
            initStage();
            setState(() {});
          }
          if (value == 2) {
            //메뉴 버튼 코드
          }
          dbHelper.changeIsAccessible(2, true);
          dbHelper.changeIsCleared(1, true);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.lightBlue,
        title: const Text("배터리상태 예제"),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              currentValue,
              Text(
                "$persentage %",
                style: const TextStyle(fontSize: 100),
              ),
              IconButton(
                  onPressed: () async {
                    dbHelper.changeIsAccessible(2, false);
                  },
                  icon: const Icon(Icons.remove, color: Colors.red)),
              IconButton(
                  onPressed: () {
                    popUps.showHintTabBar(context);
                  },
                  icon: const Icon(Icons.question_mark))
            ],
          )
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


// IconButton(
//               onPressed: () async {
//                 dbHelper.changeIsCleared(1, true);
//               },
//               icon: const Icon(Icons.add)),
//           IconButton(
//               onPressed: () async {
//                 dbHelper.changeIsCleared(1, false);
//               },
//               icon: const Icon(Icons.remove)),
//           IconButton(
//               onPressed: () async {
//                 dbHelper.changeIsAccessible(2, true);
//               },
//               icon: const Icon(
//                 Icons.add,
//                 color: Colors.red,
//               )),
//           IconButton(
//               onPressed: () async {
//                 dbHelper.changeIsAccessible(2, false);
//               },
//               icon: const Icon(
//                 Icons.remove,
//                 color: Colors.red,
//               )),