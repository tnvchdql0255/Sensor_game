import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:torch_controller/torch_controller.dart';
import 'package:sensor_game/common_ui/start.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:sqflite/sqflite.dart';


class StageS5 extends StatefulWidget {
  const StageS5({super.key});

  @override
  State<StageS5> createState() => _StageS5State();
}

class _StageS5State extends State<StageS5> {
  //스테이지 시작 시, 스테이지 설명을 출력하는 PopUps 클래스의 인스턴스 생성
  PopUps popUps = const PopUps(
    startMessage: "스테이지 6",
    quest: "앞이 보이지 않아!",
    hints: ["불빛이 필요해", "힌트2", "힌트3"]);
  DBHelper dbHelper = DBHelper();
  late final Database db;

  //DB를 불러오는 getDB 함수 생성
  void getDB() async {
    db = await dbHelper.db;
  }
  
  final controller = TorchController();  
  bool isTorchOn = false;           //토글이 꺼져있는 상태
  bool showTreasure = false;        //보물이 보이지 않는 상태

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {  //스테이지 시작 시, 스테이지 설명을 출력
      popUps.showStartMessage(context);
    });
    TorchController().initialize();  //손전등이 스마트폰에서 작동하려면 이 코드가 필요하다. <필수>
  }

  void toggleTorch() {
    setState(() {
      isTorchOn = !isTorchOn;
      if (isTorchOn) {              //토글이 켜져있으면
        controller.toggle();
        showTreasure = true;  
        popUps.showClearedMessage(context).then((value) {
              if (value == 1) {
                initStage();
              }
              if (value == 2) {}
            });
            dbHelper.changeIsAccessible(6, true);
            dbHelper.changeIsCleared(7, true);
      } else {  // 토글 손전등이 꺼지면 실패 로직을 넣거나 없애야된다.
        controller.toggle();        //토글이 꺼져있으면
        showTreasure = false;
      }
    });
  }
  
  void initStage() {
    setState(() {
      isTorchOn = false;
      showTreasure = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('앞이 보이지 않아!'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 70,
            left: 20,
            child: AnimatedOpacity(
              opacity: isTorchOn ? 0 : 1,
              duration: const Duration(milliseconds: 300),  
              child: SvgPicture.asset(
                'assets/images/man.svg',
                width: 500,
                height: 500,
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (details) {
                if (!isTorchOn) {
                  toggleTorch();
                }
              },
              child: Container(
                width: 80,
                height: 80,
                child: Transform.scale(
                  scale: 3.0,
                  child: SvgPicture.asset(
                    isTorchOn
                      ? 'assets/images/flash_man.svg'
                      : 'assets/images/flashlight.svg',
                      width: 20,
                      height: 20,
                  ),
                )  
              ),
            ),
          ),
        ],
      ),
    );
  }
}