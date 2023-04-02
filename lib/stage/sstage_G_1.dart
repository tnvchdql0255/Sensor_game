//패키지 불러오기
import 'dart:async';
import 'package:light/light.dart';
import 'package:flutter/material.dart';

//StatefulWidget을 사용하는 StageG1 클래스 생성
class StageG1 extends StatefulWidget {
  const StageG1({super.key});

  @override
  State<StageG1> createState() => _StageG1State();
}

class _StageG1State extends State<StageG1> {
  String _luxString = 'Unknown'; //밝기의 초기값은 'Unknown'으로 지정
  late Light _light; //밝기 값을 읽어들이는 _light 변수 선언
  late StreamSubscription _subscription; //이벤트 처리를 위한 StreamSubscription 변수 선언
  //int lux = 0;

  //읽어들인 밝기 값(luxvalue)의 상태를 출력하는 onData 함수 생성
  void onData(int luxValue) async {
    print("밝기 값: $luxValue");
    setState(() {
      _luxString = "$luxValue";
    });
  }

  //밝기 값을 그만 읽을 때 사용하는 stopListening 함수 생성
  void stopListening() {
    _subscription.cancel();
  }

  //밝기 값을 읽어들이는 startListening 함수 생성
  void startListening() {
    _light = new Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      //예외 처리
      print(exception);
    }
  }

  //초기 상태를 설정하는 initState 함수 생성
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  /*
  void main() {
    try {
      Timer(Duration(seconds: 4), () => lux = int.parse(_luxString));
    } on FormatException catch (exception) {
      lux = -1;
    }
  }*/

  //초기 상태는 startListening 함수를 실행하여 밝기 값을 읽어들이는 상태로 설정
  Future<void> initPlatformState() async {
    startListening();
  }

  //위젯 설정
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('눈을 감기게 해줘라!'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    child: new Text('밝기 값: $_luxString\n',
                        style: TextStyle(fontSize: 30))),
                Container(
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/insomnia.png'),
                      /*
                      image: lux > 10
                          ? AssetImage('assets/images/insomnia.png')
                          : AssetImage('assets/images/sleeping.png'),*/
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
