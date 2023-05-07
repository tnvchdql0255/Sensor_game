import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class StageK3 extends StatefulWidget {
  const StageK3({Key? key}) : super(key: key);

  @override
  State<StageK3> createState() => _StageK3State();
}

class _StageK3State extends State<StageK3> {
  double dx = 0, dy = 0;
  List<Color> circleColors = [Colors.red, Colors.red, Colors.red];
  List<Offset> circleOffsets = [
    const Offset(0, 0),
    const Offset(0, 0),
    const Offset(0, 0)
  ];

  @override
  void initState() {
    super.initState();
    _setInitialCircleOffsets();
  }

  void _setInitialCircleOffsets() {
    Random random = Random();
    circleOffsets[0] =
        Offset(random.nextDouble() * 300, random.nextDouble() * 500);
    circleOffsets[1] =
        Offset(random.nextDouble() * 300, random.nextDouble() * 500);
    circleOffsets[2] =
        Offset(random.nextDouble() * 300, random.nextDouble() * 500);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('StageK3'),
      ),
      body: Stack(
        children: [
          ...circleOffsets.asMap().entries.map((entry) {
            int index = entry.key;
            Offset offset = entry.value;
            return Positioned(
              left: offset.dx,
              top: offset.dy,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    circleColors[index] = Colors.green;
                  });
                },
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColors[index],
                  ),
                ),
              ),
            );
          }).toList(),
          StreamBuilder<GyroscopeEvent>(
            stream: SensorsPlatform.instance.gyroscopeEvents,
            builder: (_, snapshot) {
              if (snapshot.hasData) {
                dx += snapshot.data!.y * 60;
                dy += snapshot.data!.x * 60;
              }
              return Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 1000),
                  transform: Matrix4.translationValues(dx, dy, 0),
                  child: const CircleAvatar(
                    radius: 20,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
