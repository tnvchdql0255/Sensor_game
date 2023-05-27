import 'package:sensor_game/stage_selection_svg.dart';
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
      appBar: AppBar(title: const Text("스테이지 선택")),
      backgroundColor: Colors.lightBlue,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const SizedBox(
              height: 30,
            ),
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
      ),
    );
  }
}