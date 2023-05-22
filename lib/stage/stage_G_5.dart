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

//StatefulWidget을 사용하는 StageG5 클래스 생성
class StageG5 extends StatefulWidget {
  const StageG5({super.key});

  @override
  State<StageG5> createState() => _StageG5State();
}

class _StageG5State extends State<StageG5> {
  String _asset = 'assets/images/stage_G_5_1.svg'; //동굴의 svg를 저장하는 asset 변수 선언
  String transcription = ""; //인식한 음성 내용을 저장하는 transcription 변수 선언
  String word = ""; //동굴을 여는 주문을 저장하는 word 변수 선언
  bool _speechRecognitionAvailable = false; //음성 인식이 가능한지 여부를 체크하는 변수
  bool _isListening = false; //음성 인식을 시작했는지 여부를 체크하는 변수

  Language selectedLang = languages.first; //언어 설정을 위한 selectedLang 변수 선언

  late Timer checkClearTimer; //클리어 상태를 체크하는 타이머
  late SpeechRecognition _speech; //음성 인식을 수행하는 _speech 변수 선언

  //앵무새의 말 리스트 생성
  List<String> korSpell = ["열려라 참깨"];
  List<String> engSpell = ["open sesame"];
  List<String> frSpell = ["sésame ouvre-toi"];
  List<String> ruSpell = ["cим-сим откройся"];
  List<String> itSpell = ["Apriti sesamo"];
  List<String> esSpell = ["ábrete sésamo"];

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
      const PopUps(startMessage: "스테이지 5", quest: "동굴 안의 보물을 얻어라!", hints: [
    "동굴의 문을 열어야만 보물을 얻을 수 있을것 같네요!",
    "동굴의 문이 꿈쩍도 안 하는 것을 보니 뭔가 특수한 주문을 외쳐야 할 것 같은데요?",
    "혹시 '알리바바와 40인의 도둑'이라는 이야기를 아시나요?"
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
    spellLanguage(); //언어가 변경될 때마다, 앵무새의 언어 또한 변경
  }

  //언어가 변경될 때마다, 동굴의 주문 또한 변경하는 spellLanguage 함수 생성
  void spellLanguage() {
    switch (selectedLang.name) {
      case '한국어':
        word = korSpell.toList().first;
        break;
      case 'English':
        word = engSpell.toList().first;
        break;
      case 'Francais':
        word = frSpell.toList().first;
        break;
      case 'Pусский':
        word = ruSpell.toList().first;
        break;
      case 'Italiano':
        word = itSpell.toList().first;
        break;
      case 'Español':
        word = esSpell.toList().first;
        break;
      default:
        word = korSpell.toList().first;
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
    spellLanguage(); //스테이지가 시작될 때, 주문의 언어를 설정

    //1초마다 클리어 상태를 확인하는 타이머 생성
    checkClearTimer =
        Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      clearStatus();
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
        _asset = 'assets/images/stage_G_5_2.svg'; //동굴이 열리는 그림으로 변경

        popUps.showClearedMessage(context).then((value) {
          //클리어 메시지를 출력
          if (value == 1) {
            //다시하기 버튼 코드
            spellLanguage(); //주문의 언어를 다시 설정

            //클리어 여부를 체크하는 타이머를 다시 가동
            checkClearTimer =
                Timer.periodic(const Duration(milliseconds: 1000), (timer) {
              clearStatus();
            });

            setState(() {
              //그 외의 요소들을 다시 초기화
              _asset = 'assets/images/stage_G_5_1.svg';
              transcription = '';
            });
          }
          if (value == 2) {
            //메뉴 버튼 코드
            setState(() {});
          }
          dbHelper.changeIsAccessible(5, true); //스테이지 6를 이용 가능한 것으로 설정
          dbHelper.changeIsCleared(4, true); //스테이지 5를 클리어한 것으로 설정
        });
      }
    });
  }

  @override
  void dispose() {
    //스테이지가 종료될 때
    super.dispose();
    checkClearTimer.cancel(); //타이머를 종료
  }

  //위젯 설정
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),

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
        title: const Text('동굴 안의 보물을 얻어라!',
            style: TextStyle(
                color: Color.fromARGB(255, 163, 137, 122),
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
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //동굴의 이미지를 출력
              Expanded(flex: 4, child: SvgPicture.asset(_asset)),

              //인식한 음성을 말풍선으로 보여주는 위젯
              Expanded(
                  flex: 1,
                  child: transcription == ""
                      ? Container()
                      : Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(left: 20, right: 20),
                          decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 255, 255, 255),
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 163, 137, 122),
                                  width: 4.0),
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(19))),
                          child: Text('$transcription!',
                              style: const TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 25),
                              textAlign: TextAlign.center),
                        )),

              //다음의 요소들은 가로로 나열하여 배치함
              Row(
                children: [
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
                ],
              )
            ],
          ),
        ),
      ),
    ));
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
                width: 5, color: const Color.fromARGB(255, 163, 137, 122)),
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.g_translate,
            color: Color.fromARGB(255, 163, 137, 122),
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
              width: 5, color: const Color.fromARGB(255, 163, 137, 122)),
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.mic),
          iconSize: 85,
          color: const Color.fromARGB(255, 163, 137, 122),
          onPressed: onPressed,
        ),
      ));

  //활성화된 음성 인식을 정지하는 버튼
  Widget _stopSpeechButton({VoidCallback? onPressed}) => Expanded(
          child: Ink(
        decoration: BoxDecoration(
          border: Border.all(
              width: 5, color: const Color.fromARGB(255, 163, 137, 122)),
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.stop),
          iconSize: 55,
          color: const Color.fromARGB(255, 163, 137, 122),
          onPressed: onPressed,
        ),
      ));
}
