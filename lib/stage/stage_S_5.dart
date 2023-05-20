/*import 'package:flutter/material.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';


class StageS5 extends StatefulWidget {
  const StageS5({super.key});

  @override
  State<StageS5> createState() => _StageS5State();
}

class _StageS5State extends State<StageS5> {
  // 스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps = const PopUps(
      startMessage: "스테이지 6",
      quest: "당신은 동굴을 들어가야합니다 어떻게 할건가요?!",
      hints: ["힌트1", "힌트2", "힌트3"]);

  DBHelper dbHelper = DBHelper();
  late final Database db;

  //static const platform = MethodChannel('com.sensorIO.method');

  bool _isFlashlightOn = false;
  late MethodChannel _methodChannel;

  @override
  void initState() {
    super.initState();
    _methodChannel = const MethodChannel('com.sensorIO.method');
  }

  void _toggleFlashlight() async {
    try {
      final int result = await _methodChannel.invokeMethod('toggleFlashlight');
      setState(() {
        _isFlashlightOn = result == 1;
      });
    } on PlatformException catch (e) {
      print('Failed to toggle flashlight: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flashlight'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              _isFlashlightOn ? Icons.flash_on : Icons.flash_off,
              size: 100,
              color: _isFlashlightOn ? Colors.yellow : Colors.grey,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _toggleFlashlight,
              child: Text(_isFlashlightOn ? 'Turn Off' : 'Turn On'),
            ),
          ],
        ),
      ),
    );
  }
}
*/