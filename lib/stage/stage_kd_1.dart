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
  late Timer _timer;
  int _count = 0;
  bool _isRecording = false;
  StreamSubscription<NoiseReading>? _noiseSubscription;
  late NoiseMeter _noiseMeter;
  double _decibel = 0.0;
  late NoiseReading noiseReading;
  late AssetImage _sleepingImage;

  void getDB() async {
    db = await dbHelper.db;
  }

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter(onError);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      popUps.showStartMessage(context).then((value) => {start()});
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      checkDecibel();
    });
  }

  void checkDecibel() {
    if (_decibel >= 20) {
      _count++;
      if (_count >= 3) {
        stop();
        popUps
            .showClearedMessage(context)
            .then((value) => {setState(() {}), start()});
        dbHelper.changeIsAccessible(3, true);
        dbHelper.changeIsCleared(2, true);
      }
    } else {
      _count = 0;
    }
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
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Image(
            image: AssetImage('assets/icons/sleeping.png'),
          ),
          // Text(
          //   'Decibel: ${_decibel.toStringAsFixed(2)} dB',
          //   style: const TextStyle(fontSize: 36),
          // ),
        ),
        // floatingActionButton: FloatingActionButton(
        //     backgroundColor: _isRecording ? Colors.red : Colors.green,
        //     onPressed: _isRecording ? stop : start,
        //     child:
        //         _isRecording ? const Icon(Icons.stop) : const Icon(Icons.mic)),
      ),
    );
  }
}
