//패키지 불러오기
import 'dart:async';
import 'package:light/light.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

//StatefulWidget을 사용하는 StageG1 클래스 생성
class StageG2 extends StatefulWidget {
  const StageG2({super.key});

  @override
  State<StageG2> createState() => _StageG2State();
}

class _StageG2State extends State<StageG2> {
  int _luxint = 0; //밝기의 값을 저장하는 _luxint 변수 선언
  String _asset = 'assets/images/stage_G_2_1.svg'; //동굴의 svg를 저장하는 asset 변수 선언
  bool _isClear = false; //클리어 조건을 만족했는지를 체크하는 _isClear 변수 선언

  late Timer checkLightTimer; //밝기 값이 낮은지를 체크하는 타이머
  late Timer checkClearTimer; //클리어 상태를 체크하는 타이머
  late Light _light; //밝기 값을 읽어들이는 _light 변수 선언
  late StreamSubscription _subscription; //이벤트 처리를 위한 _subscription 변수 선언

  List<int> lightList = []; //밝기 값을 저장하는 lightList 생성

  //스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps =
      const PopUps(startMessage: "스테이지 2", quest: "동굴 안의 보물을 찾아라!", hints: [
    "현재 동굴 안이 어두워서 잘 보이지가 않네요..",
    "동굴 안을 들여다 볼 수 있는 방법이 없을까요?",
    "동굴 안을 밝게 비추면 안을 볼 수 있을 것 같네요!"
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
      //만약 읽어들인 밝기 값이 200 이상이라면
      if (_luxint >= 200) {
        setState(() {
          lightList.add(_luxint); //읽어들인 밝기 값을 lightList에 추가

          //만약 2.5초 동안 읽어들인 밝기 값이 1500 이상이라면
          if (lightList.length >= 5 &&
              lightList.every((element) => element >= 1500)) {
            checkLightTimer.cancel(); //타이머를 종료
            _isClear = true; //클리어 조건을 만족했으므로 isClear 변수를 true로 설정
          }
        });
      } else {
        //그 외의 경우에는
        _asset = 'assets/images/stage_G_2_1.svg'; //svg를 초기화
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
        _asset = 'assets/images/stage_G_2_2.svg'; //svg를 동굴이 열린 사진으로 변경

        popUps.showClearedMessage(context).then((value) {
          //클리어 메시지를 출력
          if (value == 1) {
            //다시하기 버튼 코드
            initPlatformState(); //다시 시작할 시, 밝기 값을 읽어들이는 상태로 재설정
            setState(() {
              //그 외의 요소들을 다시 초기화
              _asset = 'assets/images/stage_G_2_1.svg';
              _isClear = false;
            });
          }
          if (value == 2) {
            //메뉴 버튼 코드
            setState(() {
              _isClear = false; //메뉴로 돌아갈 시, isClear 변수를 false로 재설정
            });
          }
          dbHelper.changeIsAccessible(3, true); //스테이지 2를 이용 가능한 것으로 설정
          dbHelper.changeIsCleared(2, true); //스테이지 1을 클리어한 것으로 설정
        });
      }
    });
  }

  @override
  void dispose() {
    //스테이지가 종료될 때
    super.dispose();
    checkLightTimer.cancel(); //밝기 값이 낮은지를 확인하는 타이머를 종료
    checkClearTimer.cancel(); //클리어 조건을 만족하는지 확인하는 타이머를 종료
    stopListening(); //밝기 값을 읽어들이는 것을 중지
  }

  //위젯 설정
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 19, 19, 19),

        //힌트를 보여주는 탭바를 생성한다
        floatingActionButton: SizedBox(
          height: 40.0,
          width: 40.0,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () {
                popUps.showHintTabBar(context);
              },
              child: const Icon(Icons.help_outline),
            ),
          ),
        ),
        //힌트를 보여주는 탭바는 화면의 오른쪽 상단에 위치한다
        floatingActionButtonLocation: FloatingActionButtonLocation.miniEndTop,

        //상단의 타이틀 부분 설정
        appBar: AppBar(
          title: const Text('동굴 안의 보물을 찾아라!',
              style: TextStyle(
                  color: Color.fromARGB(255, 247, 232, 18),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(1.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ])),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255, 19, 19, 19),
          elevation: 0,
        ),

        //화면에 출력되는 요소들을 설정
        body: SafeArea(
          child: Center(
            child: Column(
              children: <Widget>[
                //밝기 값을 출력하는 Container
                /*
                Container(
                    margin: const EdgeInsets.only(top: 20.0),
                    padding: const EdgeInsets.fromLTRB(10, 5, 10, 5),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 247, 249, 208),
                        border: Border.all(
                            color: const Color.fromARGB(255, 135, 135, 135),
                            width: 4.0),
                        borderRadius: const BorderRadius.horizontal(
                            left: Radius.circular(20.0),
                            right: Radius.circular(20.0))),
                    child: Text('밝기 값: $_luxint',
                        style: const TextStyle(fontSize: 20))),*/

                //조건에 따라 달라지는 동굴의 이미지를 출력
                Expanded(flex: 10, child: SvgPicture.asset(_asset))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
