import 'package:flutter_svg/flutter_svg.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

class StageK1 extends StatefulWidget {
  const StageK1({super.key});

  @override
  State<StageK1> createState() => _StageK1State();
}

class _StageK1State extends State<StageK1> {
  PopUps popUps = const PopUps(
      startMessage: "스테이지 2",
      quest: "자고 있는 사람을 깨워라!",
      hints: ["힌트1", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;
  late Timer _timer;
  int _count = 0;
  bool _isRecording = false;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;
  double _decibel = 0.0;
  late NoiseReading noiseReading;
  late String _image;

  void getDB() async {
    db = await dbHelper.db;
  }

  @override
  void initState() {
    super.initState();
    _image = 'assets/images/sleep.svg';
    _noiseMeter = NoiseMeter(onError);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      popUps.showStartMessage(context).then((value) => {start()});
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkDecibel();
    });
  }

  void checkDecibel() {
    if (_decibel >= 50) {
      _count++;
      if (_count >= 3) {
        stop();
        _image = 'assets/images/get_up.svg';
        popUps.showClearedMessage(context).then((value) {
          if (value == 1) {
            //다시하기 버튼 코드
            initStage();
          }
          if (value == 2) {
            //메뉴 버튼 코드
          }
        });
        dbHelper.changeIsAccessible(11, true);
        dbHelper.changeIsCleared(10, true);
      }
    } else {
      _count = 0;
    }
  }

  void initStage() {
    _count = 0;
    setState(() {
      _image = 'assets/images/sleep.svg';
    });
    start();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  void onData(NoiseReading noiseReading) {
    setState(() {
      if (!_isRecording) {
        _isRecording = true;
      }
      _decibel = noiseReading.meanDecibel;
    });
    // print(noiseReading.toString());
  }

  void onError(Object error) {
    // print(error.toString());
    _isRecording = false;
  }

  void start() async {
    try {
      _noiseSubscription = _noiseMeter.noiseStream.listen(onData);
    } catch (err) {
      // print(err);
    }
  }

  void stop() async {
    try {
      if (_noiseSubscription != null) {
        _noiseSubscription!.cancel();
        _noiseSubscription = null;
      }
      setState(() {
        _isRecording = false;
        _decibel = 0.0;
      });
    } catch (err) {
      // print('stopRecorder error: $err');
    }
  }

  // List<Widget> getContent() => <Widget>[
  //       Container(
  //         margin: const EdgeInsets.all(25),
  //         child: Column(
  //           children: [
  //             Container(
  //               margin: const EdgeInsets.only(top: 20),
  //               child: Text(_isRecording ? "Mic: ON" : "Mic: OFF",
  //                   style: const TextStyle(fontSize: 25, color: Colors.blue)),
  //             )
  //           ],
  //         ),
  //       ),
  //     ];

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
      appBar: AppBar(title: const Text('Stage 2')),
      body: Center(
        child: SvgPicture.asset(_image),
      ),
      // Text(
      //   'Decibel: ${_decibel.toStringAsFixed(2)} dB',
      //   style: const TextStyle(fontSize: 36),
      // ),

      // floatingActionButton: FloatingActionButton(
      //     backgroundColor: _isRecording ? Colors.red : Colors.green,
      //     onPressed: _isRecording ? stop : start,
      //     child:
      //         _isRecording ? const Icon(Icons.stop) : const Icon(Icons.mic)),
    );
  }
}
