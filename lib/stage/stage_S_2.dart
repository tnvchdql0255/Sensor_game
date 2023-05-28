import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

class StageS2 extends StatefulWidget {
  const StageS2({super.key});

  @override
  State<StageS2> createState() => _StageS2State();
}

class _StageS2State extends State<StageS2> {
  //스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps = const PopUps(
    startMessage: "스테이지 3",
    quest: "액자 속 그림을 맞춰보세요!",
    hints: ["액자 속을 확인해야될 거 같아요.",
            "줌 인을 활용해보세요!",
            "정답은 세글자입니다."]);
  DBHelper dbHelper = DBHelper();
  late final Database db;

  //DB를 불러오는 getDB 함수 생성
  void getDB() async {
    db = await dbHelper.db;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      popUps.showStartMessage(context);
    });
  }

  void initStage() {
    answer = '';
  }

  
  double scaleFactor = 1.0; // 확대/축소 비율을 나타내는 변수
  String answer = ''; // 정답을 입력받을 변수

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('액자 속 그림을 맞춰보세요!'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -100, // 액자 그림을 화면 위쪽으로 이동
            left: 0,
            right: 0,
            child: GestureDetector(
              // 확대/축소 기능을 위한 GestureDetector 위젯
              onScaleUpdate: (ScaleUpdateDetails details) {
                setState(() {
                  scaleFactor = 1.0 + (details.scale - 1.0); // 확대/축소 비율을 제한하여 설정
                });
              },
              onScaleEnd: (ScaleEndDetails details) {
                // 확대/축소가 끝났을 때, 확대/축소 비율을 1.0으로 초기화
                if (scaleFactor < 1.1) {
                  setState(() {
                    scaleFactor = 1.0;
                 });
                }
              },
              child: Transform.scale(
                scale: scaleFactor,
                child: SvgPicture.asset(
                  scaleFactor == 1.0
                      ? 'assets/images/photo_frame.svg' // 작은 액자 사진
                      : 'assets/images/spoon.svg', // 확대된 숟가락 사진
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16.0),
                const Text(
                  '정답을 입력하세요:',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.7,
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        answer = value; // 정답 입력값 업데이트
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    // 정답 확인 로직
                    if (answer == '숟가락') {
                      popUps.showClearedMessage(context).then((value) {
                        if (value == 1) {
                          initStage();
                        }
                        if (value == 2) {}
                      });
                      dbHelper.changeIsAccessible(4, true);
                      dbHelper.changeIsCleared(3, true);
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('땡!'),
                            content: const Text('정답이 아닙니다. 다시 시도하세요.'),
                            actions: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('확인'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: const Text('제출'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}