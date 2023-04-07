//패키지 불러오기
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter/material.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

//음성 인식을 특정 언어의 텍스트로 변환할 수 있는 언어 리스트 설정
const languages = const [
  const Language('한국어', 'ko_KOR'), //한국어
  const Language('English', 'en_US'), //영어
  const Language('Francais', 'fr_FR'), //프랑스어
  const Language('Pусский', 'ru_RU'), //러시아어
  const Language('Italiano', 'it_IT'), //이탈리아어
  const Language('Español', 'es_ES') //스페인어
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
  bool _speechRecognitionAvailable = false; //음성 인식이 가능한지 여부를 체크하는 변수
  bool _isListening = false; //음성 인식을 시작했는지 여부를 체크하는 변수
  String transcription = ""; //음성 인식 결과를 저장하는 transcription 변수 선언
  String word = ""; //앵무새가 말하는 단어를 저장하는 word 변수 선언

  Language selectedLang = languages.first; //설정한 언어를 저장하는 selectedLang 변수 선언

  late Timer checkClearTimer; //1초마다 클리어 상태를 체크하는 타이머를 위한 변수 선언
  late SpeechRecognition _speech; //음성 인식을 받아오는 _speech 변수 선언

  //앵무새가 말하는 단어 리스트 생성
  List<String> _Kor_parrot = ["안녕하세요", "반가워요", "사랑해요", "왱알왱알", "헬로"];

  //설정이 가능한 언어들을 리스트로 만들어서 반환하는 _buildLanguagesWidgets 함수 생성
  List<CheckedPopupMenuItem<Language>> get _buildLanguagesWidgets => languages
      .map((l) => CheckedPopupMenuItem<Language>(
            value: l,
            checked: selectedLang == l,
            child: Text(l.name),
          ))
      .toList();

  //스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps = const PopUps(startMessage: "스테이지 4", quest: "앵무새의 말을 따라해라!");
  DBHelper dbHelper = DBHelper();
  late final Database db;

  //DB를 불러오는 getDB 함수 생성
  void getDB() async {
    db = await dbHelper.db;
  }

  //음성 인식이 활성화 될 때 실행되는 activateSpeechRecognizer 함수 생성
  void activateSpeechRecognizer() {
    //음성 인식이 시작되면 음성을 기록하고, 해당 값을 출력한다
    //출력된 음성은 에러를 확인하고, 에러가 없다면 한국어로 변환한다
    print('_MyAppState.activateSpeechRecognizer... ');
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

  //선택한 언어로 설정을 변경하는 _selectLangHandler 함수 생성
  void _selectLangHandler(Language lang) {
    setState(() => selectedLang = lang);
  }

  //음성 인식이 시작되면 선택한 언어로 음성을 받아옴
  void start() => _speech.activate(selectedLang.code).then((_) {
        //음성 인식이 시작되면 음성을 기록하고, 해당 값을 출력한다
        return _speech.listen().then((result) {
          print('_MyAppState.start => result $result');
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
    print('_MyAppState.onCurrentLocale... $locale');
    setState(
        () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  //음성 인식이 시작되면 _isListening을 활성화시켜 음성을 받아오는 상태로 만듦
  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  //음성 인식을 한 뒤의 결과는 transcription에 저장됨
  void onRecognitionResult(String text) {
    print('_MyAppState.onRecognitionResult... $text');
    setState(() => transcription = text);
  }

  //음성 인식 과정이 전부 완료되면 이를 알리고, 음성 인식을 중지
  void onRecognitionComplete(String text) {
    print('_MyAppState.onRecognitionComplete... $text');
    setState(() => _isListening = false);
  }

  //에러가 발생할 경우, activateSpeechRecognizer 내에서 에러를 확인
  void errorHandler() => activateSpeechRecognizer();

  //초기 상태를 설정하는 initState 함수 생성
  @override
  initState() {
    super.initState();
    activateSpeechRecognizer(); //스테이지가 시작될 때, 음성 인식을 활성화

    word = (_Kor_parrot.toList()..shuffle()).first; //앵무새의 말을 랜덤으로 추출

    //1초마다 클리어 상태를 확인하는 타이머 생성
    checkClearTimer =
        Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      clearStatus();
    });

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
        popUps.showClearedMessage(context).then((value) {
          //클리어 메시지를 출력
          if (value == 1) {
            //다시하기 버튼 코드
            cancel();
            initState();
            setState(() {});
          }
          if (value == 2) {
            //메뉴 버튼 코드
            setState(() {});
          }
          dbHelper.changeIsAccessible(2, true); //스테이지 2를 이용 가능한 것으로 설정
          dbHelper.changeIsCleared(1, true); //스테이지 1을 클리어한 것으로 설정
        });
      }
    });
  }

  //위젯 설정
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          //상단의 타이틀 부분 설정 (가운데 정렬)
          title: const Text('음성 인식'),
          centerTitle: true,

          //오른쪽에 언어 설정 버튼을 추가
          actions: [
            PopupMenuButton<Language>(
              onSelected: _selectLangHandler,
              itemBuilder: (BuildContext context) => _buildLanguagesWidgets,
            )
          ],
        ),
        body: Padding(
            padding: EdgeInsets.all(8.0), //외부면에는 8 픽셀 만큼의 여백을 주어진다
            child: Center(
              //아래의 요소들을 가로로 가운데 정렬
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                      //이미지를 출력하는 컨테이너
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/images/parrot.png')))),
                  Container(
                      //앵무새가 말하는 문장을 출력하는 컨테이너
                      child: Text(
                    '현재 앵무새가 하는 말: $word',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  )),

                  //Expanded를 사용하여, 음성을 길게 말한 경우 출력 화면을 그만큼 늘린다
                  Expanded(
                      child: Container(
                          //출력 화면의 외부면에는 8 픽셀 만큼의 여백을 주어진다
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey.shade200, //출력 화면은 밝은 회색으로 설정
                          child: Text(transcription))), //음성 인식 결과를 텍스트로 지정한다
                  _buildButton(
                    //음성 인식이 가능하며, 음성 인식이 시작되지 않은 경우에만 버튼을 활성화
                    //버튼을 누르면 start 함수를 실행하여 음성 인식을 시작하고 결과를 출력
                    onPressed: _speechRecognitionAvailable && !_isListening
                        ? () => start()
                        : null,
                    label: _isListening
                        ? '음성 인식 중...' //음성 인식이 시작될 경우, 텍스트는 '음성 인식 중...'으로 표시
                        : '(${selectedLang.name}로) 음성 인식 시작하기', //그 외의 경우, 텍스트는 '("선택한 언어"로) 음성 인식 시작하기'로 표시
                  ),
                  _buildButton(
                    //음성 인식이 시작된 경우에만 버튼을 활성화
                    //버튼을 누르면 cancel 함수를 실행하여 음성 인식을 초기화 상태로 전환
                    onPressed: _isListening ? () => cancel() : null,
                    label: '초기화하기',
                  ),
                  _buildButton(
                    //음성 인식이 시작된 경우에만 버튼을 활성화
                    //버튼을 누르면 stop 함수를 실행하여 음성 인식을 정지함
                    onPressed: _isListening ? () => stop() : null,
                    label: '멈추기',
                  ),
                ],
              ),
            )),
      ),
    );
  }

  //화면 내의 버튼 스타일을 지정하기 위한 _buildButton 함수 생성
  Widget _buildButton({required String label, VoidCallback? onPressed}) =>
      Padding(
          padding: EdgeInsets.all(4.0), //버튼의 외부면에는 4픽셀 만큼의 여백을 주어진다
          child: ElevatedButton(
            //버튼에 그림자를 넣는다
            onPressed: onPressed, //버튼을 누르면 onPressed 함수를 실행한다
            child: Text(
              label, //버튼의 텍스트가 저장된 label을 지정한다
              style:
                  const TextStyle(color: Colors.white), //버튼의 텍스트 색상은 흰색으로 지정한다
            ),
          ));
}
