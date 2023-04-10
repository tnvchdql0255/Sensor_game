import 'package:flutter/material.dart';

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
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
          insetPadding:
              EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.5),
          title: Text(startMessage, style: const TextStyle(fontSize: 50)),
          backgroundColor: Colors.lightBlue,
          elevation: 0, // 그림자 없애기
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8, // 화면 너비의 80%
            child: Text(quest),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('확인',
                  style: TextStyle(fontSize: 30, color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
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
                borderRadius: BorderRadius.circular(40.0)),
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
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("성공!"),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40.0)),
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
                    Navigator.of(context).pop(2); //스테이지 선택창까지 Route 함
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

  ///스테이지 마다 override 해서 사용
  Future<dynamic> showHintTabBar(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            // insetPadding: EdgeInsets.only(
            //     bottom: MediaQuery.of(context).size.height * 0.5),
            backgroundColor: Colors.transparent,

            elevation: 0,
            content: DefaultTabController(
              initialIndex: 0,
              length: 3,
              child: Scaffold(
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: const Text('Hint'),
                  bottom: const TabBar(
                    tabs: <Widget>[
                      Tab(
                        icon: Icon(Icons.looks_one),
                      ),
                      Tab(
                        icon: Icon(Icons.looks_two),
                      ),
                      Tab(
                        icon: Icon(Icons.looks_3),
                      ),
                    ],
                  ),
                ),
                body: TabBarView(
                  children: <Widget>[
                    Center(
                      child: Text(hints[0]),
                    ),
                    Center(
                      child: Text(hints[1]),
                    ),
                    Center(
                      child: Text(hints[2]),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
