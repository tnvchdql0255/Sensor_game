import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

class StageL1 extends StatefulWidget {
  const StageL1({super.key});

  @override
  State<StageL1> createState() => _Stage1State();
}

class _Stage1State extends State<StageL1> {
  DBHelper dbHelper = DBHelper();
  late final Database db;
  void getDB() async {
    db = await dbHelper.db;
  }

  String _batteryStatus = "CurrentStatus";
  Icon currentValue = const Icon(Icons.battery_6_bar);
  BatteryState? _batteryState;
  final Battery _battery = Battery();
  late Timer timer;
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  int persentage = 0;
  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getBatteryStatus();
    });
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((status) {
      _batteryState = status;
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
          currentValue = const Icon(Icons.battery_charging_full);
          persentage++;
          break;
        case BatteryState.charging:
          currentValue = const Icon(Icons.battery_charging_full);
          persentage++;
          break;
        case BatteryState.discharging:
          currentValue = const Icon(Icons.battery_0_bar);
          break;
        case BatteryState.unknown:
          _batteryStatus = "unknown";
          break;
        default:
          currentValue = const Icon(Icons.battery_0_bar);
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue,
      appBar: AppBar(
        title: const Text("배터리상태 예제"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          currentValue,
          Text("$persentage"),
          IconButton(
              onPressed: () async {
                dbHelper.changeIsCleared(1, true);
              },
              icon: const Icon(Icons.add)),
          IconButton(
              onPressed: () async {
                dbHelper.changeIsCleared(1, false);
              },
              icon: const Icon(Icons.remove)),
          IconButton(
              onPressed: () async {
                dbHelper.changeIsAccessible(2, true);
              },
              icon: const Icon(
                Icons.add,
                color: Colors.red,
              )),
          IconButton(
              onPressed: () async {
                dbHelper.changeIsAccessible(2, false);
              },
              icon: const Icon(Icons.remove, color: Colors.red)),
        ],
      ),
    );
  }
}
