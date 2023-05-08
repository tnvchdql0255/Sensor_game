import 'package:flutter/material.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';

class StageS3 extends StatefulWidget {
  const StageS3({super.key});

  @override
  State<StageS3> createState() => _StageS3State();
}

class _StageS3State extends State<StageS3> with SingleTickerProviderStateMixin {
  //스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps = const PopUps(startMessage: "스테이지 4", quest: "화산을 터트려라!", hints: ["힌트1", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;

  //DB를 불러오는 getDB 함수 생성
  void getDB() async {
    db = await dbHelper.db;
  }

  late AnimationController _animationController;  //애니메이션을 위한 AnimationController 클래스의 인스턴스 생성
  late Animation<double> _animation;   //애니메이션을 위한 Animation 클래스의 인스턴스 생성

  final double _swipeThreshold = 200.0;  //화면을 터치한 채로 위로 드래그할 때, 터치한 위치의 y좌표와 현재 위치의 y좌표의 차이를 계산하여 일정 거리 이상 드래그하면 애니메이션을 실행
  double _initialPositionY = 0.0;        //화면을 터치했을 때, 터치한 위치의 y좌표를 저장

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(  //애니메이션 컨트롤러 생성
      vsync: this,
      duration: const Duration(milliseconds: 500),  //애니메이션의 지속시간 설정
    );

    _animation = Tween<double>(begin: 1.0, end: 0.0).animate(_animationController)  //Tween 클래스를 이용하여 애니메이션의 시작과 끝을 설정
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onVerticalDragStart(DragStartDetails details) {    //화면을 터치했을 때, 터치한 위치의 y좌표를 저장
    _initialPositionY = details.globalPosition.dy;  //터치한 위치의 y좌표를 저장
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {   //화면을 터치한 채로 위로 드래그할 때, 터치한 위치의 y좌표와 현재 위치의 y좌표의 차이를 계산하여 일정 거리 이상 드래그하면 애니메이션을 실행
    double dy = details.globalPosition.dy;    //현재 위치의 y좌표를 저장
    double distance = _initialPositionY - dy;  //터치한 위치의 y좌표와 현재 위치의 y좌표의 차이를 계산하여 저장
    if (distance.abs() > _swipeThreshold) {   //터치한 위치의 y좌표와 현재 위치의 y좌표의 차이가 일정 거리 이상이면 애니메이션을 실행
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stage4'),
      ),
      body: GestureDetector(
        onVerticalDragStart: _onVerticalDragStart,  
        onVerticalDragUpdate: _onVerticalDragUpdate,  
        child: Center(
          child: Stack(
            children: [
              Opacity(
                opacity: _animation.value,
                child: Image.asset(
                  'assets/images/volcano_erupt.png',
                  width: 300,
                  height: 300,
                ),
              ),
              Opacity(
                opacity: 1 - _animation.value,
                child: Image.asset(
                  'assets/images/volcano.png',
                  width: 300,
                  height: 300,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
