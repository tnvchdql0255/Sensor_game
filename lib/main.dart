import 'package:sensor_game/stage_selection_svg.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: MyHome());
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  StreamSubscription<AccelerometerEvent>? streamSubscription;
  int count = 0;

  bool isShaking(AccelerometerEvent event) {
    const double shakeThreshold = 15.0; // 흔들림 감지 임계값
    return (event.x.abs() > shakeThreshold ||
        event.y.abs() > shakeThreshold ||
        event.z.abs() > shakeThreshold);
  }

  //흔들림을 감지하면 StageselectionMenu로 이동
  void startListening() {
    streamSubscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        if (isShaking(event)) {
          Vibration.vibrate(duration: 10); // 0.01초간 진동
          count++;
          if (count == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const StageSelectionMenu()),
            );
            count = 0;
          }
        }
      },
    );
  }

  @override
  void initState() {
    startListening();
    super.initState();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var textStyle = const TextStyle(
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Sensor IO",
                    style: TextStyle(
                        fontSize: 70,
                        color: Colors.blue.shade400,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              //아이콘 넣기
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.door_back_door_rounded,
                    size: 150,
                    color: Colors.blue.shade300,
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "흔들어서 시작하기",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue.shade200,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
