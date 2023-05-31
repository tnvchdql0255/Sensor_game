//패키지 불러오기
import 'dart:async';
import 'package:light/light.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

//StatefulWidget을 사용하는 StageG1 클래스 생성
class StageG1 extends StatefulWidget {
  const StageG1({super.key});

  @override
  State<StageG1> createState() => _StageG1State();
}

class _StageG1State extends State<StageG1> {
  int _luxint = 0; //밝기의 값을 저장하는 _luxint 변수 선언
  int _bRGB = 255; //배경 화면의 RGB 값을 저장하는 _bRGB 변수 선언
  String _personAsset =
      'assets/images/stage_G_1_1.svg'; //사람의 svg를 저장하는 asset 변수 선언
  String _lampAsset =
      'assets/images/stage_G_1_5.svg'; //전등의 svg를 저장하는 asset 변수 선언
  bool _isClear = false; //클리어 조건을 만족했는지를 체크하는 _isClear 변수 선언

  late Timer checkLightTimer; //밝기 값이 낮은지를 체크하는 타이머
  late Timer checkClearTimer; //클리어 상태를 체크하는 타이머
  late Light _light; //밝기 값을 읽어들이는 _light 변수 선언
  late StreamSubscription _subscription; //이벤트 처리를 위한 _subscription 변수 선언

  List<int> lightList = []; //밝기 값을 저장하는 lightList 생성

  //스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps =
      const PopUps(startMessage: "스테이지 1", quest: "눈을 감기게 해줘라!", hints: [
    "아마 전등의 빛이 너무 밝아서 잠을 못 자는 것이 아닐까요?",
    "전등의 빛을 낮추기 위해서 어떻게 해야할까요?",
    "전등을 손바닥으로 가려보는 것은 어떨까요?"
  ]);
  DBHelper dbHelper = DBHelper();
  late final Database db;

  //DB를 불러오는 getDB 함수 생성
  void getDB() async {
    db = await dbHelper.db;
  }

  //읽어들인 밝기 값(luxValue)의 상태를 출력하는 onData 함수 생성
  void onData(int luxValue) async {
    print('luxValue: $luxValue');
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
    _light = Light();
    try {
      _subscription = _light.lightSensorStream.listen(onData);
    } on LightException catch (exception) {
      //예외 처리
      debugPrint('debug: $exception');
    }

    //1초마다 클리어 조건을 만족하는지 확인하는 타이머 생성
    checkLightTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      //만약 읽어들인 밝기 값이 18 이하라면
      if (_luxint <= 45) {
        setState(() {
          lightList.add(_luxint); //읽어들인 밝기 값을 lightList에 추가
          _bRGB -= 28; //배경 화면의 RGB 값을 28씩 감소

          //만약 4초 동안 읽어들인 밝기 값이 45 이하라면
          if (lightList.length > 2 && lightList.length <= 5) {
            _personAsset = 'assets/images/stage_G_1_2.svg'; //svg를 변경
          } else if (lightList.length > 5 && lightList.length <= 7) {
            _personAsset = 'assets/images/stage_G_1_3.svg'; //svg를 변경
          } else if (lightList.length >= 8 &&
              lightList.every((element) => element <= 45)) {
            checkLightTimer.cancel(); //타이머를 종료
            _isClear = true; //클리어 조건을 만족했으므로 isClear 변수를 true로 설정
          }
        });
      } else {
        //그 외의 경우에는
        _bRGB = 255; //배경 화면의 RGB 값을 255로 설정
        _personAsset = 'assets/images/stage_G_1_1.svg'; //svg를 초기화
        lightList.clear(); //lightList를 비움
      }
    });
  }

  //초기 상태를 설정하는 initState 함수 생성
  @override
  void initState() {
    super.initState();
    initPlatformState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
  }

  //초기 상태는 startListening 함수를 실행하여 밝기 값을 읽어들이는 상태로 설정
  Future<void> initPlatformState() async {
    startListening();

    //1초마다 클리어 상태를 확인하는 타이머 생성
    checkClearTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      clearStatus();
    });
  }

  //클리어 상태를 확인하는 clearStatus 함수 생성
  void clearStatus() async {
    setState(() {
      if (_isClear == true) {
        //클리어 조건을 만족했다면
        checkClearTimer.cancel(); //타이머를 종료
        stopListening(); //밝기 값을 읽어들이는 것을 중지

        lightList.clear(); //lightList를 비움
        _bRGB = 0; //배경 화면의 RGB 값을 0으로 설정
        _personAsset = 'assets/images/stage_G_1_4.svg'; //svg를 자는 사람으로 변경
        _lampAsset = 'assets/images/stage_G_1_6.svg'; //svg를 꺼진 전등으로 변경

        popUps.showClearedMessage(context).then((value) {
          //클리어 메시지를 출력
          if (value == 1) {
            //다시하기 버튼 코드
            initPlatformState(); //다시 시작할 시, 밝기 값을 읽어들이는 상태로 재설정
            setState(() {
              //그 외의 요소들을 다시 초기화
              _bRGB = 255;
              _personAsset = 'assets/images/stage_G_1_1.svg';
              _lampAsset = 'assets/images/stage_G_1_5.svg';
              _isClear = false;
            });
          }
          if (value == 2) {
            //메뉴 버튼 코드
            setState(() {
              _isClear = false;
            });
          }
          dbHelper.changeIsAccessible(7, true); //스테이지 7을 이용 가능한 것으로 설정
          dbHelper.changeIsCleared(6, true); //스테이지 6을 클리어한 것으로 설정
        });
      }
    });
  }

  @override
  void dispose() {
    //스테이지가 종료될 때
    stopListening(); //밝기 값을 읽어들이는 것을 중지
    super.dispose();
  }

  //위젯 설정
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, _bRGB, _bRGB, _bRGB),

      //힌트를 보여주는 탭바를 생성한다
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

      //상단의 타이틀 부분 설정
      appBar: AppBar(
        title: const Text('눈을 감기게 해줘라!',
            style: TextStyle(
                color: Color.fromARGB(255, 197, 229, 17),
                fontSize: 28,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Color.fromARGB(255, _bRGB, _bRGB, _bRGB),
        elevation: 0,
      ),

      //화면에 출력되는 요소들을 설정
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              //조건에 따라 달라지는 전등의 이미지를 출력
              Expanded(flex: 2, child: SvgPicture.asset(_lampAsset)),
              //조건에 따라 달라지는 사람의 이미지를 출력
              Expanded(flex: 10, child: SvgPicture.asset(_personAsset))
            ],
          ),
        ),
      ),
    );
  }
}
