//패키지 불러오기
import 'dart:async';
import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

//음성 인식을 특정 언어의 텍스트로 변환할 수 있는 언어 리스트 설정
const languages = [
  Language('한국어', 'ko_KOR'), //한국어
  Language('English', 'en_US'), //영어
  Language('Francais', 'fr_FR'), //프랑스어
  Language('Pусский', 'ru_RU'), //러시아어
  Language('Italiano', 'it_IT'), //이탈리아어
  Language('Español', 'es_ES') //스페인어
];

//언어 설정을 위한 Language 클래스 생성
class Language {
  final String name; //선택한 언어의 이름을 저장하는 name 변수 선언
  final String code; //선택한 언어의 코드를 저장하는 code 변수 선언
  const Language(this.name, this.code); //설정한 name과 code를 받아와 저장함
}

//StatefulWidget을 사용하는 StageG4 클래스 생성
class StageG4 extends StatefulWidget {
  const StageG4({super.key});

  @override
  State<StageG4> createState() => _StageG4State();
}

class _StageG4State extends State<StageG4> {
  String _asset = 'assets/images/stage_G_4_2.svg'; //앵무새의 svg를 저장하는 asset 변수 선언
  String transcription = ""; //인식한 음성 내용을 저장하는 transcription 변수 선언
  String word = ""; //앵무새의 말을 저장하는 word 변수 선언
  bool _speechRecognitionAvailable = false; //음성 인식이 가능한지 여부를 체크하는 변수
  bool _isListening = false; //음성 인식을 시작했는지 여부를 체크하는 변수
  bool _hidingWidget = false; //앵무새의 말풍선이 숨겼는지 여부를 체크하는 변수

  Language selectedLang = languages.first; //언어 설정을 위한 selectedLang 변수 선언

  late Timer checkClearTimer; //클리어 상태를 체크하는 타이머
  late Timer hidingTimer; //앵무새의 말풍선을 숨기는 타이머
  late SpeechRecognition _speech; //음성 인식을 수행하는 _speech 변수 선언

  //앵무새의 말 리스트 생성
  List<String> korParrot = ["안녕하세요", "반가워요", "사랑해요", "잘 자요", "행복해요", "안아 주세요"];
  List<String> engParrot = [
    "hello",
    "hi",
    "i love you",
    "goodbye",
    "happy",
    "hug me"
  ];
  List<String> frParrot = [
    "bonjour",
    "enchanté ",
    "je t'aime",
    "dors bien",
    "Je suis heureuse",
    "Fais-moi un câlin"
  ];
  List<String> ruParrot = [
    "Здравствуйте",
    "pад познакомиться",
    "Люблю",
    "cпокойной ночи",
    "я счастлив",
    "oбнимите"
  ];
  List<String> itParrot = [
    "salve",
    "piacere di conoscerti",
    "ti amo",
    "buonanotte",
    "sono felice",
    "abbracciami"
  ];
  List<String> esParrot = [
    "hola",
    "encantada",
    "te quiero",
    "buenas noches",
    "soy feliz",
    "dame un abrazo"
  ];

  //설정 가능한 언어들을 리스트로 만들어서 반환하는 _buildLanguagesWidgets 함수 생성
  List<CheckedPopupMenuItem<Language>> get _buildLanguagesWidgets => languages
      .map((l) => CheckedPopupMenuItem<Language>(
            value: l,
            checked: selectedLang == l,
            child: Text(l.name),
          ))
      .toList();

  //스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps =
      const PopUps(startMessage: "스테이지 4", quest: "앵무새와 교감을 해라!", hints: [
    "앵무새가 하는 말에 어떤 의미가 있을까요?",
    "앵무새는 주변의 소리를 잘 흉내내기로 유명하죠!",
    "앵무새의 말을 따라해본다면 기뻐하지 않을까요?"
  ]);
  DBHelper dbHelper = DBHelper();
  late final Database db;

  //DB를 불러오는 getDB 함수 생성
  void getDB() async {
    db = await dbHelper.db;
  }

  //음성 인식이 활성화 될 때 실행되는 activateSpeechRecognizer 함수 생성
  void activateSpeechRecognizer() {
    //음성을 인식하고, 해당 값을 출력한다
    //출력된 음성은 에러를 확인하고, 에러가 없다면 한국어로 변환한다
    _speech = SpeechRecognition();
    _speech.setAvailabilityHandler(onSpeechAvailability);
    _speech.setRecognitionStartedHandler(onRecognitionStarted);
    _speech.setRecognitionResultHandler(onRecognitionResult);
    _speech.setRecognitionCompleteHandler(onRecognitionComplete);
    _speech.setErrorHandler(errorHandler);
    _speech.activate('ko_KOR').then((res) {
      setState(() => _speechRecognitionAvailable = res);
    });
  }

  //언어를 변경할 수 있는 _selectLangHandler 함수 생성
  void _selectLangHandler(Language lang) {
    setState(() => selectedLang = lang);
    parrotLanguage(); //언어가 변경될 때마다, 앵무새의 언어 또한 변경
  }

  //언어가 변경될 때마다, 앵무새의 언어 또한 변경하는 parrotLanguage 함수 생성
  void parrotLanguage() {
    switch (selectedLang.name) {
      case '한국어':
        word = (korParrot.toList()..shuffle()).first;
        break;
      case 'English':
        word = (engParrot.toList()..shuffle()).first;
        break;
      case 'Francais':
        word = (frParrot.toList()..shuffle()).first;
        break;
      case 'Pусский':
        word = (ruParrot.toList()..shuffle()).first;
        break;
      case 'Italiano':
        word = (itParrot.toList()..shuffle()).first;
        break;
      case 'Español':
        word = (esParrot.toList()..shuffle()).first;
        break;
      default:
        word = (korParrot.toList()..shuffle()).first;
        break;
    }
  }

  //음성 인식이 시작되면 선택한 언어로 음성을 받아옴
  void start() => _speech.activate(selectedLang.code).then((_) {
        //음성 인식이 시작되면 음성을 기록하고, 해당 값을 출력한다
        return _speech.listen().then((result) {
          setState(() {
            _isListening = result;
          });
        });
      });

  //초기화 버튼을 누르면 _isListening을 false로 만들고 음성 인식 과정을 초기화
  void cancel() =>
      _speech.cancel().then((_) => setState(() => _isListening = false));

  //정지 버튼을 누르면 _isListening을 false로 만들어 음성 인식을 중지
  void stop() => _speech.stop().then((_) {
        setState(() => _isListening = false);
      });

  //음성 인식이 가능한지의 여부를 _speechRecognitionAvailable에 저장
  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  //언어를 선택하게 되면, 음성 인식에 사용되는 언어 코드는 해당 언어의 코드로 바뀜
  void onCurrentLocale(String locale) {
    setState(
        () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  //음성 인식이 시작되면 _isListening을 활성화시켜 음성을 받아오는 상태로 만듦
  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  //음성 인식을 한 뒤의 결과는 transcription 변수에 저장됨
  void onRecognitionResult(String text) {
    setState(() => transcription = text);
  }

  //음성 인식 과정이 전부 완료되면 이를 알리고, 음성 인식을 중지
  void onRecognitionComplete(String text) {
    setState(() => _isListening = false);
  }

  //에러가 발생할 경우, activateSpeechRecognizer 내에서 에러를 확인
  void errorHandler() => activateSpeechRecognizer();

  //초기 상태를 설정하는 initState 함수 생성
  @override
  initState() {
    super.initState();
    activateSpeechRecognizer(); //스테이지가 시작될 때, 음성 인식을 활성화
    parrotLanguage(); //스테이지가 시작될 때, 앵무새의 언어를 설정

    //1초마다 클리어 상태를 확인하는 타이머 생성
    checkClearTimer =
        Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      clearStatus();
    });

    //5초마다 앵무새의 말풍선을 숨기는 타이머 생성
    hidingTimer = Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      _hidingWidget = true;
      _asset = 'assets/images/stage_G_4_1.svg';

      //말풍선이 숨겨지면 1.8초 후에 말풍선을 다시 생성
      Future.delayed(const Duration(milliseconds: 1800), () {
        _hidingWidget = false;
        _asset = 'assets/images/stage_G_4_2.svg';
      });
    });

    //스테이지가 시작될 때, 스테이지 설명을 출력
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
  }

  //클리어 상태를 확인하는 clearStatus 함수 생성
  void clearStatus() async {
    setState(() {
      if (transcription == word) {
        //클리어 조건을 만족했다면
        checkClearTimer.cancel(); //타이머를 종료
        hidingTimer.cancel(); //타이머를 종료
        _hidingWidget = true; //말풍선을 가림
        _asset = 'assets/images/stage_G_4_3.svg'; //앵무새가 기뻐하는 그림으로 변경

        popUps.showClearedMessage(context).then((value) {
          //클리어 메시지를 출력
          if (value == 1) {
            //다시하기 버튼 코드
            parrotLanguage(); //앵무새의 언어를 다시 설정

            //클리어 여부를 체크하는 타이머를 다시 가동
            checkClearTimer =
                Timer.periodic(const Duration(milliseconds: 1000), (timer) {
              clearStatus();
            });

            //말풍선을 숨기는 타이머를 다시 가동
            hidingTimer =
                Timer.periodic(const Duration(milliseconds: 5000), (timer) {
              _hidingWidget = true;
              _asset = 'assets/images/stage_G_4_1.svg';

              Future.delayed(const Duration(milliseconds: 1800), () {
                _hidingWidget = false;
                _asset = 'assets/images/stage_G_4_2.svg';
              });
            });

            setState(() {
              //그 외의 요소들을 다시 초기화
              _asset = 'assets/images/stage_G_4_2.svg';
              transcription = '';
              _hidingWidget = false;
            });
          }
          if (value == 2) {
            //메뉴 버튼 코드
            setState(() {});
          }
          dbHelper.changeIsAccessible(5, true); //스테이지 5를 이용 가능한 것으로 설정
          dbHelper.changeIsCleared(4, true); //스테이지 4를 클리어한 것으로 설정
        });
      }
    });
  }

  @override
  void dispose() {
    //스테이지가 종료될 때
    super.dispose();
    checkClearTimer.cancel(); //타이머를 종료
    hidingTimer.cancel(); //타이머를 종료
  }

  //위젯 설정
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),

        //힌트를 보여주는 탭바를 생성한다
        floatingActionButton: Container(
          width: 57,
          height: 57,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  color: Color.fromARGB(255, 209, 223, 243),
                  width: 5,
                  style: BorderStyle.solid)),
          margin: const EdgeInsets.fromLTRB(0, 70, 0, 0),
          child: FloatingActionButton(
            focusColor: Colors.white54,
            backgroundColor: Color.fromARGB(255, 67, 107, 175),
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
          title: const Text('앵무새와 교감을 해라!',
              style: TextStyle(
                  color: Color.fromARGB(255, 248, 99, 99),
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
          backgroundColor: Colors.white,
          elevation: 0,
        ),

        //화면에 출력되는 요소들을 설정
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                //아래의 요소들을 수직 및 수평 기준으로 가운데 정렬
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      flex: 8,
                      //다음의 요소들은 가로로 나열하여 배치함
                      child: Row(children: [
                        Expanded(
                          //_hidingWidget이 true인 경우, 앵무새의 말풍선을 숨김
                          child: _hidingWidget == true
                              ? Container()
                              : Container(
                                  padding: const EdgeInsets.all(15),
                                  margin: const EdgeInsets.only(top: 30),
                                  decoration: BoxDecoration(
                                    color: const Color.fromARGB(
                                        255, 230, 226, 215),
                                    border: Border.all(
                                        color: const Color.fromARGB(
                                            255, 178, 176, 161),
                                        width: 4.0),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(19),
                                      bottomLeft: Radius.circular(19),
                                      bottomRight: Radius.circular(19),
                                    ),
                                  ),
                                  child: Text(word,
                                      style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 17),
                                      textAlign: TextAlign.center),
                                ),
                        ),
                        //앵무새의 이미지를 출력
                        Expanded(flex: 2, child: SvgPicture.asset(_asset)),
                      ])),

                  //인식한 음성을 말풍선으로 보여주는 위젯
                  Expanded(
                      flex: 3,
                      //만약 어떤 음성도 인식되지 않았다면 말풍선을 숨김
                      child: transcription == ""
                          ? Container()
                          : Container(
                              alignment: Alignment.center,
                              margin:
                                  const EdgeInsets.only(left: 20, right: 20),
                              decoration: BoxDecoration(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  border: Border.all(
                                      color: const Color.fromARGB(
                                          255, 255, 169, 154),
                                      width: 4.0),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(19))),
                              child: Text('$transcription~',
                                  style: const TextStyle(
                                      color: Color.fromARGB(255, 0, 0, 0),
                                      fontSize: 25),
                                  textAlign: TextAlign.center),
                            )),

                  //다음의 요소들은 가로로 나열하여 배치함
                  Row(children: [
                    _selectLangButton(
                        //버튼을 누르면 언어를 변경할 수 있는 목록을 출력함
                        item: _buildLanguagesWidgets),
                    _activeSpeechButton(
                      //음성 인식이 가능하며, 음성 인식이 시작되지 않은 경우에만 버튼을 활성화
                      //버튼을 누르면 start 함수를 실행하여 음성 인식을 수행한다
                      onPressed: _speechRecognitionAvailable && !_isListening
                          ? () => start()
                          : null,
                    ),
                    _stopSpeechButton(
                      //음성 인식이 시작된 경우에만 버튼을 활성화
                      //버튼을 누르면 stop 함수를 실행하여 활성화된 음성 인식을 정지함
                      onPressed: _isListening ? () => stop() : null,
                    ),
                  ]),
                ],
              ),
            )),
      ),
    );
  }

  //변경할 수 있는 언어의 목록을 출력하는 버튼
  Widget _selectLangButton({required item}) => Expanded(
          child: PopupMenuButton<Language>(
        onSelected: _selectLangHandler,
        itemBuilder: (BuildContext context) => item,
        child: Ink(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(
                width: 5, color: const Color.fromARGB(255, 250, 140, 140)),
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.g_translate,
            color: Color.fromARGB(255, 248, 99, 99),
            size: 50,
          ),
        ),
      ));

  //음성 인식을 활성화하는 버튼
  Widget _activeSpeechButton({VoidCallback? onPressed}) => Padding(
      padding: const EdgeInsets.only(top: 40, bottom: 40),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(
              width: 5, color: const Color.fromARGB(255, 250, 140, 140)),
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.mic),
          iconSize: 85,
          color: const Color.fromARGB(255, 248, 99, 99),
          onPressed: onPressed,
        ),
      ));

  //활성화된 음성 인식을 정지하는 버튼
  Widget _stopSpeechButton({VoidCallback? onPressed}) => Expanded(
          child: Ink(
        decoration: BoxDecoration(
          border: Border.all(
              width: 5, color: const Color.fromARGB(255, 250, 140, 140)),
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.stop),
          iconSize: 55,
          color: const Color.fromARGB(255, 248, 99, 99),
          onPressed: onPressed,
        ),
      ));
}
