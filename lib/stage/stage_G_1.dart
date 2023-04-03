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
  int _luxint = 0; //밝기의 초기값은 0으로 지정
  late Light _light; //밝기 값을 읽어들이는 _light 변수 선언
  late StreamSubscription _subscription; //이벤트 처리를 위한 StreamSubscription 변수 선언

  //읽어들인 밝기 값(luxvalue)의 상태를 출력하는 onData 함수 생성
  void onData(int luxValue) async {
    print("밝기 값: $luxValue");
    setState(() {
      _luxint = luxValue;
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
          //상단의 타이틀 부분 설정 (가운데 정렬)
          title: const Text('눈을 감기게 해줘라!'),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Center(
            //아래의 요소들을 가로로 가운데 정렬
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    //밝기 값을 출력하는 컨테이너
                    child: new Text('밝기 값: $_luxint\n',
                        style: TextStyle(fontSize: 30))),
                Container(
                  //이미지를 출력하는 컨테이너
                  width: 400,
                  height: 400,
                  decoration: BoxDecoration(
                    //밝기 값이 15보다 작으면 자는 이미지를 출력하고, 그렇지 않으면 졸린 이미지를 출력
                    image: DecorationImage(
                        image: _luxint < 15
                            ? AssetImage('assets/images/insomnia.png')
                            : AssetImage('assets/images/sleeping.png')),
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
