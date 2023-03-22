import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';

class StageL1 extends StatefulWidget {
  const StageL1({super.key});

  @override
  State<StageL1> createState() => _Stage1State();
}

class _Stage1State extends State<StageL1> {
  String _batteryStatus = "CurrentStatus";
  BatteryState? _batteryState;
  final Battery _battery = Battery();
  late Timer timer;
  StreamSubscription<BatteryState>? _batteryStateSubscription;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
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
          _batteryStatus = "full";
          break;
        case BatteryState.charging:
          _batteryStatus = "isCharging";
          break;
        case BatteryState.discharging:
          _batteryStatus = "discharging";
          break;
        case BatteryState.unknown:
          _batteryStatus = "unknown";
          break;
        default:
          _batteryStatus = "default";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("배터리상태 예제"),
      ),
      body: Column(
        children: [
          Text(_batteryStatus),
          SizedBox(
            height: 50,
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.backspace_outlined),
          ),
        ],
      ),
    );
  }
}
