import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:video_player/video_player.dart';

class StageK4 extends StatefulWidget {
  const StageK4({Key? key}) : super(key: key);

  @override
  State<StageK4> createState() => _StageK4State();
}

class _StageK4State extends State<StageK4> {
  PopUps popUps = const PopUps(
      startMessage: "스테이지 13",
      quest: "도미노를 쓰러뜨려라!",
      hints: [
        "실제로 도미노를 쓰러뜨리세요",
        "주변에 도미노같이 생긴 물체를 찾으세요",
        "스마트폰이 도미노라고 생각해보세요"
      ]);
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
          dbHelper.changeIsAccessible(14, true);
          dbHelper.changeIsCleared(13, true);
        }
        _prevDirection = direction;
      });
    });
  }

  // 스테이지 초기화 함수
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
      floatingActionButton: Container(
        width: 57,
        height: 57,
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
                color: const Color.fromARGB(255, 209, 223, 243),
                width: 5,
                style: BorderStyle.solid)),
        margin: const EdgeInsets.fromLTRB(0, 70, 0, 0),
        child: FloatingActionButton(
          focusColor: Colors.white54,
          backgroundColor: const Color.fromARGB(255, 67, 107, 175),
          onPressed: () {
            popUps.showHintTabBar(context);
          },
          child: const Icon(
            Icons.tips_and_updates,
            color: Color.fromARGB(255, 240, 240, 240),
            size: 33,
          ),
        ),
      ),
      //힌트를 보여주는 탭바는 화면의 오른쪽 상단에 위치한다
      floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,
      backgroundColor: const Color.fromARGB(255, 171, 171, 171),
      appBar: AppBar(
        title: const Text(
          '도미노를 쓰러뜨려라!',
          style: TextStyle(
              color: Color.fromARGB(255, 67, 107, 175),
              fontSize: 28,
              fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: const Color.fromARGB(255, 171, 171, 171),
        elevation: 0.0,
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
