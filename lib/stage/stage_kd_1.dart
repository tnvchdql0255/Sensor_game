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
  PopUps popUps = const PopUps(startMessage: "스테이지 2", quest: "자고 있는 사람을 깨워라!");
  DBHelper dbHelper = DBHelper();
  late final Database db;
  void getDB() async {
    db = await dbHelper.db;
  }

  bool _isRecording = false;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;
  double _decibel = 0.0;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter(onError);
    //해당 메서드 안에 팝업 메서드를 넣어야 정상적으로 실행됨 (위젯트리 로딩 이후에 실행되어야 하기 때문)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    super.dispose();
  }

  void initStage() {
    _noiseMeter = NoiseMeter(onError);
  }

  void onData(NoiseReading noiseReading) {
    setState(() {
      if (!_isRecording) {
        _isRecording = true;
      }
      _decibel = noiseReading.meanDecibel;
      if (_decibel > 80) {
        // 일정 데시벨 이상이 감지되었을 때 처리할 코드 추가
        print("Loud sound detected!");
        popUps.showClearedMessage(context).then((value) {
          if (value == 1) {
            //다시하기 버튼 코드
            initStage();
            setState(() {});
          }
          if (value == 2) {
            //메뉴 버튼 코드
          }
          dbHelper.changeIsAccessible(3, true);
          dbHelper.changeIsCleared(2, true);
        });
      }
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
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text(
            'Decibel: ${_decibel.toStringAsFixed(2)} dB',
            style: const TextStyle(fontSize: 36),
          ),
        ),
        floatingActionButton: FloatingActionButton(
            backgroundColor: _isRecording ? Colors.red : Colors.green,
            onPressed: _isRecording ? stop : start,
            child:
                _isRecording ? const Icon(Icons.stop) : const Icon(Icons.mic)),
      ),
    );
  }
}
