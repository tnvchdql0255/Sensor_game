import 'package:sensor_game/stage_selection.dart';
import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    var textStyle = const TextStyle(
        color: Colors.white, fontSize: 40, fontWeight: FontWeight.w600);
    return Scaffold(
      backgroundColor: const Color(0xFF64B0F6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 60.0, 8.0, 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    "Sensor IO",
                    style: TextStyle(
                        fontSize: 65,
                        color: Colors.white60,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              TextButton(
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const StageSelectionMenu()),
                      ),
                  child: Text(
                    "게임 시작",
                    style: textStyle.copyWith(color: const Color(0xFF2196F3)),
                  )),
              TextButton(
                  onPressed: () {},
                  child: Text(
                    "설정",
                    style: textStyle.copyWith(color: const Color(0xFFBBDEFB)),
                  )),
              TextButton(
                onPressed: () {},
                child: Text(
                  "기여자",
                  style: textStyle.copyWith(color: const Color(0xFFBBDEFB)),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  "나가기",
                  style: textStyle.copyWith(color: const Color(0xFFBBDEFB)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
