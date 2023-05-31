import 'dart:async';
import 'package:sensor_game/service/audio_manager.dart';
import 'package:sensor_game/stage_selection_svg.dart';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:vibration/vibration.dart';

void main() {
  runApp(const MyApp());
}

// AssetsAudioPlayer _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();
AudioManager audioManager = AudioManager();

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
  bool isShaked = false;
  Timer? shakeTimer; // Flag to control shake animation

  bool isShaking(AccelerometerEvent event) {
    const double shakeThreshold = 10.0; // 흔들림 감지 임계값
    return (event.x.abs() > shakeThreshold ||
        event.y.abs() > shakeThreshold ||
        event.z.abs() > shakeThreshold);
  }

  void startShakeTimer() {
    shakeTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      setState(() {
        isShaked = true; // Enable shake animation
      });
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {
          isShaked = false; // Disable shake animation after 0.2 seconds
        });
      });
    });
  }

  //흔들림을 감지하면 StageselectionMenu로 이동
  void startListening() {
    streamSubscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        if (isShaking(event)) {
          Vibration.vibrate(duration: 10);
          print("흔들림 감지");
          setState(() {
            isShaked = true;
          }); // 0.01초간 진동
          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {
              isShaked = false;
            });
          });
          count++;
          if (count == 3) {
            pauseMainResource();
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const StageSelectionMenu()),
            ).then((value) => resume());
          }
        }
      },
    );
  }

  void resume() {
    startListening();
    startBGM();
  }

  void startBGM() {
    // _assetsAudioPlayer.open(
    //   Audio("assets/audios/title.mp3"),
    //   loopMode: LoopMode.single, //반복 여부 (LoopMode.none : 없음)
    //   autoStart: true, //자동 시작 여부
    //   showNotification: false, //스마트폰 알림 창에 띄울지 여부
    // );

    // _assetsAudioPlayer.play(); //재생
    // _assetsAudioPlayer.pause(); //멈춤
    // _assetsAudioPlayer.stop(); //정지
    audioManager.startBGM();
  }

  @override
  void initState() {
    super.initState();
    startListening();
    startBGM();
    startShakeTimer();
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    audioManager.dispose();
    shakeTimer?.cancel();
    super.dispose();
  }

  void pauseMainResource() {
    count = 0;
    streamSubscription?.cancel();
    audioManager.pause();
  }

  void testButton() {
    pauseMainResource();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const StageSelectionMenu()),
    ).then((value) => resume());
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
                  Align(
                    alignment: Alignment.center,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 100),
                      transform: isShaked
                          ? Matrix4.translationValues(0, 10, 0)
                          : Matrix4.identity(),
                      child: Text(
                        "Sensor IO",
                        style: TextStyle(
                            fontSize: 70,
                            color: Colors.blue.shade400,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    transform:
                        isShaked ? Matrix4.rotationZ(-0.2) : Matrix4.identity(),
                    child: Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.door_back_door_rounded,
                        size: 150,
                        color: Colors.blue.shade300,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    transform:
                        isShaked ? Matrix4.rotationZ(0.2) : Matrix4.identity(),
                    child: Text(
                      "스마트폰을 흔들어서 시작하기",
                      style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue.shade200,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              //ElevatedButton 을 center에 위치시켜줘
              Row(children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: ElevatedButton(
                      onPressed: () {
                        testButton();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "테스트 버튼",
                        style: textStyle,
                      ),
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}
