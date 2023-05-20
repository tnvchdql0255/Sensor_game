import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

class StageS1 extends StatefulWidget {
  const StageS1({super.key});

  @override
  State<StageS1> createState() => _StageS1State();
}

class _StageS1State extends State<StageS1> {
  //스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps = const PopUps(
    startMessage: "스테이지 2",
    quest: "다이어트를 시켜줘!",
    hints: ["다이어트의 기본", "만보기", "핸드폰 잡고 흔들어"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;

  //DB를 불러오는 getDB 함수 생성
  void getDB() async {
    db = await dbHelper.db;
  }

  bool _isCleared = false;                // 클리어 상태를 저장할 변수
  int _steps = 0;                                                     //걸음 수를 저장할 변수
  late Image _image;                                                       //이미지를 저장할 변수
  List<double> _accelerometerValues = <double>[0, 0, 0];              //가속도센서 값 저장할 변수
  final List<StreamSubscription<dynamic>> _streamSubscriptions =      //이벤트 구독을 저장할 변수
      <StreamSubscription<dynamic>>[];  

  @override
  void initState() {            
    super.initState(); 
    initStage();                                               //스테이지 초기화 
    
    _image = Image.asset('assets/images/fat_person.png'); //이미지를 불러옴
    //해당 메서드 안에 팝업 메서드를 넣어야 정상적으로 실행됨 (위젯트리 로딩 이후에 실행되어야 하기 때문)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });

    sensorStart();                                             //센서 시작
  }

  void initStage() {                                           //스테이지 초기화 메서드
    _steps = 0;                                                //걸음 수를 저장할 변수 초기화
    _isCleared = false;                                        // 클리어 상태 초기화
    _image = Image.asset('asetss/images/fat_person.png');     //이미지를 불러옴
    //_accelerometerValues = <double>[0, 0, 0];                  //가속도센서 값 저장할 변수 초기화
    //_streamSubscriptions.clear();                              //이벤트 구독을 초기화
  }

  void sensorStart() async {                             //센서를 시작하는 메서드
    _streamSubscriptions    
      .add(accelerometerEvents.listen((AccelerometerEvent event) {   //가속도 센서의 이벤트를 구독합니다.
      // 이벤트 콜백 함수에서 UI 업데이트를 위해 setState 메서드를 호출합니다.
        setState(() {      
          _accelerometerValues = <double>[event.x, event.y, event.z];         //가속도 센서의 x,y,z값을 리스트에 저장
          _steps = _calculateSteps(_accelerometerValues);                     //걸음 수를 계산하는 메서드를 호출하여 걸음 수를 저장
        if (_steps == 10 && !_isCleared) {                                                 //걸음 수가 10이 되면
          print("%%%%%%%%%%%%%%%%%%%%%스테이지 걸음 수 다 채움%%%%%%%%%%%%%%%%%%%%%");
          print('걸음 수: $_steps');                                         //걸음 수를 출력
          _image = Image.asset('assets/images/thin_person.png');             //이미지를 불러옴
          _isCleared = true;                                                 //클리어 상태를 true로 변경

          popUps.showClearedMessage(context).then((value) {                 //클리어 메시지를 출력하고
            if (value == 1) {
              print("####################다시하기 버튼 눌림####################");
              //다시하기 버튼 코드
              initStage();
              setState(() {});
            }
            if (value == 2) {
              print("####################메뉴 버튼 눌림####################");
              //메뉴 버튼 코드
            }
            dbHelper.changeIsAccessible(3, true);          
            dbHelper.changeIsCleared(2, true);  
          });
        }
      });
    }));
  }

  // 걸음 수를 계산하는 메서드입니다.
  int _calculateSteps(List<double> values) {        //values는 가속도 센서의 x,y,z값을 저장한 리스트
    double norm = _norm(values);   //
    if (norm > 18) {                      //조건부의 값을 수정하면 걸음 수의 민감도를 조절할 수 있습니다.
      return _steps + 1;                  //걸음 수를 1 증가시킵니다.
    }
    return _steps;                        //걸음 수를 증가시키지 않습니다.
  }

  // 벡터의 크기를 구하는 메서드입니다.
  double _norm(List<double> values) {         //values는 가속도 센서의 x,y,z값을 저장한 리스트
    double sumOfSquares = 0;                  //제곱의 합을 저장할 변수
    for (double value in values) {            //values 값들을 하나씩 꺼내서 value에 저장
      sumOfSquares += value * value;          //value의 제곱을 sumOfSquares에 더함
    }
    return sqrt(sumOfSquares);                //sqrt는 제곱근을 구하는 함수
  }

  @override
  void dispose() {
    // 모든 이벤트 구독을 취소합니다.
    print("####################트리에서 제거됨 1번####################");
    for (StreamSubscription<dynamic> subscription in _streamSubscriptions) {
      subscription.cancel();
    }
    print("####################트리에서 제거됨 2번####################");
    super.dispose();
  }

  //위젯 설정
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage 2'),
        centerTitle: true,
      ),
      body: Center(
        child: _image,
      ),
    );
  }
}