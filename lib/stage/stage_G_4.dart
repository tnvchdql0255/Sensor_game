//패키지 불러오기
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_speech/flutter_speech.dart';
import 'package:flutter/material.dart';

//음성 인식을 텍스트로 변환할 언어 설정
const languages = const [
  const Language('Korean', 'ko_KOR'), //한국어
  const Language('English', 'en_US'), //영어
  const Language('Francais', 'fr_FR'), //프랑스어
  const Language('Pусский', 'ru_RU'), //러시아어
  const Language('Italiano', 'it_IT'), //이탈리아어
  const Language('Español', 'es_ES') //스페인어
];

//언어 설정을 위한 Language 클래스 생성
class Language {
  final String name; //선택한 언어의 이름
  final String code; //선택한 언어의 코드

  //언어 이름과 코드를 입력받아서 저장
  const Language(this.name, this.code);
}

//StatefulWidget을 사용하는 StageG4 클래스 생성
class StageG4 extends StatefulWidget {
  const StageG4({super.key});

  @override
  State<StageG4> createState() => _StageG4State();
}

class _StageG4State extends State<StageG4> {
  late SpeechRecognition _speech; //음성 인식을 위한 _speech 변수 선언

  //음성 인식이 가능한지 여부를 저장하는 변수 _speechRecognitionAvailable
  //음성 인식을 시작했는지 여부를 저장하는 변수 _isListening
  //두 변수의 초기 상태는 false로 시작함
  bool _speechRecognitionAvailable = false;
  bool _isListening = false;

  //음성 인식 결과를 저장하는 변수 transcription의 초기 상태는 공백으로 처리
  String transcription = '';

  //언어 설정의 초기 상태를 지정하는 selectedLang 변수 생성
  Language selectedLang = languages.first;

  //초기 상태를 설정하는 initState 함수 생성
  @override
  initState() {
    super.initState();
    activateSpeechRecognizer(); //스테이지가 시작될 때, 음성 인식을 활성화
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
            padding: EdgeInsets.all(8.0),
            child: Center(
              //아래의 요소들을 가로로 가운데 정렬
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  //Expanded를 사용하여, 음성을 길게 말한 경우 출력 화면을 그만큼 늘린다
                  Expanded(
                      child: Container(
                          //출력 화면의 외부면에는 8 픽셀 만큼의 여백을 주어진다
                          //출력 화면은 밝은 회색으로 설정
                          padding: const EdgeInsets.all(8.0),
                          color: Colors.grey.shade200,
                          child: Text(transcription))),
                  _buildButton(
                    //음성 인식이 가능하고, 음성 인식이 시작되지 않은 경우에만 음성 인식 버튼을 활성화
                    onPressed: _speechRecognitionAvailable && !_isListening
                        ? () => start()
                        : null,
                    //음성 인식이 가능하고, 음성 인식이 시작된 경우에만 음성 인식 중지 버튼을 활성화
                    //음성 인식 버튼은 평소에 'Listen (설정한 언어)'로 표시되고, 음성 인식이 시작되면 'Listening...'으로 표시된다
                    label: _isListening
                        ? 'Listening...'
                        : 'Listen (${selectedLang.code})',
                  ),
                  _buildButton(
                    //Cancel 버튼을 누르면 음성 인식을 중지하고, 음성 인식 결과를 초기화
                    onPressed: _isListening ? () => cancel() : null,
                    label: 'Cancel',
                  ),
                  _buildButton(
                    //Stop 버튼을 누르면 음성 인식을 중지하고, 음성 인식 결과를 출력
                    onPressed: _isListening ? () => stop() : null,
                    label: 'Stop',
                  ),
                ],
              ),
            )),
      ),
    );
  }

  //음성 인식이 가능한지 여부를 확인하는 onSpeechAvailability 함수 생성
  List<CheckedPopupMenuItem<Language>> get _buildLanguagesWidgets => languages
      //언어 설정이 가능한 언어들을 리스트로 만들어서 반환
      .map((l) => CheckedPopupMenuItem<Language>(
            value: l,
            checked: selectedLang == l,
            child: Text(l.name),
          ))
      .toList();

  //언어 설정을 변경하는 _selectLangHandler 함수 생성
  void _selectLangHandler(Language lang) {
    setState(() => selectedLang = lang);
  }

  //버튼을 누르면 실행되는 _buildButton 함수 생성
  Widget _buildButton({required String label, VoidCallback? onPressed}) =>
      Padding(
          //버튼의 외부면에는 12 픽셀 만큼의 여백을 주어진다
          padding: EdgeInsets.all(12.0),
          child: ElevatedButton(
            onPressed: onPressed,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
            ),
          ));

  //음성 인식이 시작되면 실행되는 onRecognitionStarted 함수 생성
  void start() => _speech.activate(selectedLang.code).then((_) {
        //음성 인식이 시작되면 음성을 기록하고, 해당 값을 출력한다
        return _speech.listen().then((result) {
          print('_MyAppState.start => result $result');
          setState(() {
            _isListening = result;
          });
        });
      });

  //Cancle 버튼을 누르면 음성 인식을 중지
  void cancel() =>
      _speech.cancel().then((_) => setState(() => _isListening = false));

  //Stop 버튼을 누르면 음성 인식을 중지
  void stop() => _speech.stop().then((_) {
        setState(() => _isListening = false);
      });

  //음성 인식이 가능한지 여부를 출력
  void onSpeechAvailability(bool result) =>
      setState(() => _speechRecognitionAvailable = result);

  //현재 언어를 출력
  void onCurrentLocale(String locale) {
    print('_MyAppState.onCurrentLocale... $locale');
    setState(
        () => selectedLang = languages.firstWhere((l) => l.code == locale));
  }

  //음성 인식이 시작되면 음성 인식을 활성화
  void onRecognitionStarted() {
    setState(() => _isListening = true);
  }

  //음성 인식 결과를 출력
  void onRecognitionResult(String text) {
    print('_MyAppState.onRecognitionResult... $text');
    setState(() => transcription = text);
  }

  //음성 인식이 완료되면 음성 인식을 중지
  void onRecognitionComplete(String text) {
    print('_MyAppState.onRecognitionComplete... $text');
    setState(() => _isListening = false);
  }

  //에러가 발생할 경우, 음성 인식을 활성화
  void errorHandler() => activateSpeechRecognizer();
}
