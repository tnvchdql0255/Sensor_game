import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sensor_game/service/audio_manager.dart';

final AudioManager audioManager = AudioManager();

class PopUps {
  final String startMessage;
  final String quest;
  final List<String> hints;

  const PopUps(
      {required this.startMessage, required this.quest, required this.hints});

  Future<void> showStartMessage(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
          insetPadding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.5),
          title: Text(
            startMessage,
            style: const TextStyle(
              color: Color.fromARGB(255, 67, 107, 175),
              fontSize: 40,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          backgroundColor: const Color.fromARGB(255, 240, 240, 240),
          elevation: 0, // 그림자 없애기
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // 화면 너비의 800
            child: Text(quest,
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center),
          ),
          actions: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(
                      width: 5, color: Color.fromARGB(255, 209, 223, 243)),
                  backgroundColor: const Color.fromARGB(255, 67, 107, 175),
                ),
                child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                  child: const Text('시작!',
                      style: TextStyle(
                          color: Color.fromARGB(255, 240, 240, 240),
                          fontSize: 25,
                          fontWeight: FontWeight.bold)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Future<dynamic> showfailedMessage(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("실패.."),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            insetPadding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.5),
            elevation: 0,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(1);
                  },
                  icon: const Icon(
                    Icons.refresh,
                    size: 30,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop(2); //스테이지
                    Navigator.of(context).pop(2); //스테이지 선택창까지 Route함
                  },
                  icon: const Icon(
                    Icons.menu,
                    size: 30,
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<dynamic> showClearedMessage(BuildContext context) {
    audioManager.clearBGM();
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text("클리어!",
                  style: TextStyle(
                    color: Color.fromARGB(255, 67, 107, 175),
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center),
              insetPadding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.15,
                bottom: MediaQuery.of(context).size.height * 0.15,
                left: MediaQuery.of(context).size.height * 0.04,
                right: MediaQuery.of(context).size.height * 0.04,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0)),
              elevation: 0,
              content: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                      child: SvgPicture.asset('assets/images/stage_clear.svg')),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color.fromARGB(255, 209, 223, 243),
                                width: 5,
                                style: BorderStyle.solid)),
                        margin: const EdgeInsets.fromLTRB(20, 20, 40, 0),
                        child: FloatingActionButton(
                          focusColor: Colors.white54,
                          backgroundColor:
                              const Color.fromARGB(255, 67, 107, 175),
                          onPressed: () {
                            Navigator.of(context).pop(1);
                          },
                          child: const Icon(
                            Icons.refresh,
                            color: Color.fromARGB(255, 240, 240, 240),
                            size: 40,
                          ),
                        ),
                      ),
                      Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: const Color.fromARGB(255, 209, 223, 243),
                                width: 5,
                                style: BorderStyle.solid)),
                        margin: const EdgeInsets.fromLTRB(40, 20, 20, 0),
                        child: FloatingActionButton(
                          focusColor: Colors.white54,
                          backgroundColor:
                              const Color.fromARGB(255, 67, 107, 175),
                          onPressed: () {
                            Navigator.of(context).pop(2); //스테이지
                            Navigator.of(context).pop(2); //스테이지 선택창까지 Route 함
                          },
                          child: const Icon(
                            Icons.menu,
                            color: Color.fromARGB(255, 240, 240, 240),
                            size: 40,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ));
        });
  }

  ///스테이지 마다 override 해서 사용
  Future<dynamic> showHintTabBar(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            insetPadding: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.1,
                bottom: MediaQuery.of(context).size.height * 0.44),
            backgroundColor: Colors.transparent,
            //backgroundColor: const Color.fromARGB(255, 67, 107, 175),
            elevation: 0,
            content: DefaultTabController(
              initialIndex: 0,
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color.fromARGB(255, 240, 240, 240),
                  title: Container(
                    width: 53,
                    height: 53,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: const Color.fromARGB(255, 209, 223, 243),
                            width: 3,
                            style: BorderStyle.solid)),
                    child: FloatingActionButton(
                      focusColor: Colors.white54,
                      backgroundColor: const Color.fromARGB(255, 67, 107, 175),
                      elevation: 0,
                      onPressed: () {},
                      child: const Icon(
                        Icons.psychology_alt_outlined,
                        //Icons.priority_high,
                        color: Color.fromARGB(255, 240, 240, 240),
                        size: 43,
                      ),
                    ),
                  ),
                  centerTitle: true,
                  bottom: const TabBar(
                    tabs: <Widget>[
                      Tab(
                        icon: Icon(Icons.looks_one,
                            size: 30, color: Color.fromARGB(255, 67, 107, 175)),
                      ),
                      Tab(
                        icon: Icon(Icons.looks_two,
                            size: 30, color: Color.fromARGB(255, 67, 107, 175)),
                      ),
                      Tab(
                        icon: Icon(Icons.looks_3,
                            size: 30, color: Color.fromARGB(255, 67, 107, 175)),
                      ),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: <Widget>[
                    Center(
                      child: Text(
                        hints[0],
                        style: const TextStyle(fontSize: 19),
                      ),
                    ),
                    Center(
                      child: Text(
                        hints[1],
                        style: const TextStyle(fontSize: 19),
                      ),
                    ),
                    Center(
                      child: Text(
                        hints[2],
                        style: const TextStyle(fontSize: 19),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
