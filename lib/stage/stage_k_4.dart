import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_player/video_player.dart';

class StageK4 extends StatefulWidget {
  final String videoUrl;

  const StageK4({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<StageK4> createState() => _StageK4State();
}

class _StageK4State extends State<StageK4> {
  PopUps popUps = const PopUps(
      startMessage: "스테이지 4",
      quest: "도미노를 쓰러뜨려라!",
      hints: ["힌트1", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;
  String _prevDirection = '';
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  late VideoPlayerController _videoController;
  late Future<void> _initializedController;

  @override
  void initState() {
    super.initState();
    initStage();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      popUps.showStartMessage(context).then((value) => {});
    });

    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        double x = event.x;
        double y = event.y;
        double z = event.z;
        double g = 9.81;

        // 현재 방향을 결정
        String direction = '';
        if (y.abs() > x.abs() && y.abs() > z.abs()) {
          if (y > g / 2) {
            direction = '세로로 서있음';
          } else if (y < -g / 2) {
            direction = '거꾸로 세로로 서있음';
          }
        } else if (z.abs() > x.abs() && z.abs() > y.abs()) {
          if (z > g / 2) {
            direction = '화면을 위로 두었음';
          } else if (z < -g / 2) {
            direction = '화면을 아래로 두었음';
          }
        }

        // 이전 방향과 현재 방향을 비교하여 클리어 여부를 결정
        if (_prevDirection == '세로로 서있음' &&
            direction != '세로로 서있음' &&
            (direction == '화면을 위로 두었음' || direction == '화면을 아래로 두었음')) {
          _videoController.play();

          Future.delayed(const Duration(milliseconds: 5000), () {
            popUps.showClearedMessage(context).then((value) {
              if (value == 1) {
                _videoController.seekTo(Duration.zero);
                setState(() {});
              }
              if (value == 2) {
                //메뉴 버튼 코드
              }
            });
          });
          dbHelper.changeIsAccessible(7, true);
          dbHelper.changeIsCleared(6, true);
        }
        _prevDirection = direction;
      });
    });
  }

  void initStage() {
    _prevDirection = '';
    _videoController = VideoPlayerController.asset('assets/videos/domino.mp4');
    _initializedController = _videoController.initialize();
  }

  @override
  void dispose() {
    super.dispose();
    _videoController.dispose();
    accelerometerEvents.drain();
    _accelerometerSubscription?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 171, 171, 171),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 171, 171, 171),
        elevation: 0,
        title: const Text('Stage K4'),
      ),
      body: FutureBuilder(
        future: _initializedController,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
