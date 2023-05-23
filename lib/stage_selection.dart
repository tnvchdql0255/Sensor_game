import 'package:sensor_game/service/db_manager.dart';
//import 'package:sensor_game/stage/stage_L_1.dart';
//import 'package:sensor_game/stage/stage_L_2.dart';
//import 'package:sensor_game/stage/stage_L_3.dart';
import 'package:sensor_game/stage/stage_G_1.dart';
import 'package:sensor_game/stage/stage_G_2.dart';
import 'package:sensor_game/stage/stage_G_3.dart';
import 'package:sensor_game/stage/stage_G_4.dart';
import 'package:sensor_game/stage/stage_G_5.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sqflite/sqflite.dart';

class StageSelectionMenu extends StatefulWidget {
  const StageSelectionMenu({super.key});

  @override
  State<StageSelectionMenu> createState() => _StageSelectionMenuState();
}

class _StageSelectionMenuState extends State<StageSelectionMenu> {
  List<Widget> stageRoute = [
    const StageG1(),
    const StageG2(),
    const StageG3(),
    const StageG4(),
    const StageG5(),
  ];
  late final DBHelper dbHelper;
  late Database db;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //스테이지 선택 화면의 상단바 설정
          title: const Text('스테이지 목록',
              style: TextStyle(
                  color: Color.fromARGB(255, 209, 174, 0),
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
          backgroundColor: const Color.fromARGB(255, 233, 218, 156),
          elevation: 0,
        ),
        backgroundColor: const Color.fromARGB(255, 243, 233, 192),
        body: Column(
          children: [
            Expanded(
                child: RowStageSelection(
              stageRoute: stageRoute,
            )),
          ],
        ));
  }
}

// ignore: must_be_immutable
class RowStageSelection extends StatefulWidget {
  // ignore: prefer_const_constructors_in_immutables
  RowStageSelection({super.key, required this.stageRoute});
  final List<Widget> stageRoute;

  @override
  State<RowStageSelection> createState() => _RowStageSelectionState();
}

class _RowStageSelectionState extends State<RowStageSelection> {
  late List<bool> isAccessibleList;
  late final DBHelper dbHelper;
  late Database db;

  @override
  void initState() {
    dbHelper = DBHelper();
    super.initState();
  }

  Future<List<bool>> getStage() async {
    db = await dbHelper.db;
    isAccessibleList = await dbHelper.getAllStageStatus();
    return isAccessibleList;
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 30,
      separatorBuilder: (context, index) => const Divider(
        height: 20,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
            onTap: () {
              Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => widget.stageRoute[index]))
                  .then((value) => setState(() {}));
            },
            child: Column(
              children: [
                FutureBuilder(
                  future: getStage(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                                snapshot.data![index]
                                    ? Icons.lock_open
                                    : Icons.lock,
                                color: Colors.black),
                            Text(
                              //스테이지를 나타내는 텍스트 설정
                              "Stage ${index + 1}",
                              style: const TextStyle(
                                  color: Color.fromARGB(241, 229, 144, 17),
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  shadows: <Shadow>[
                                    Shadow(
                                      offset: Offset(1.0, 1.0),
                                      blurRadius: 3.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                ),
                Expanded(
                    child: Container(
                        width: 400,
                        padding: const EdgeInsets.fromLTRB(0, 0, 0, 40),
                        //스테이지 선택 화면의 이미지 설정
                        child: SvgPicture.asset(
                            'assets/images/stage_selec_2.svg'))),
              ],
            ));
      },
    );
  }
}
