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
        color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600);
    return Scaffold(
      appBar: AppBar(title: const Text("Temp")),
      backgroundColor: Colors.lightBlue,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            "Game Title",
            style: TextStyle(fontSize: 40, color: Colors.white60),
          ),
          TextButton(
              onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const StageSelectionMenu()),
                  ),
              child: Text(
                "게임 시작",
                style: textStyle,
              )),
          TextButton(
              onPressed: () {},
              child: Text(
                "설정",
                style: textStyle,
              )),
          TextButton(
            onPressed: () {},
            child: Text(
              "기여자",
              style: textStyle,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              "나가기",
              style: textStyle,
            ),
          ),
        ],
      ),
    );
  }
}
