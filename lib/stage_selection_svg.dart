import 'package:flutter_svg/svg.dart';
import 'package:sensor_game/service/db_manager.dart';
import 'package:flutter/material.dart';
import 'package:sensor_game/stage/stage_L_1.dart';
import 'package:sensor_game/stage/stage_L_2.dart';
import 'package:sensor_game/stage/stage_L_3.dart';
import 'package:sensor_game/stage/stage_L_4.dart';
import 'package:sensor_game/stage/stage_L_5.dart';
import 'package:sensor_game/stage/stage_G_1.dart';
import 'package:sensor_game/stage/stage_G_2.dart';
import 'package:sensor_game/stage/stage_G_3.dart';
import 'package:sensor_game/stage/stage_G_4.dart';

import 'package:sqflite/sqflite.dart';

class StageSelectionMenu extends StatefulWidget {
  const StageSelectionMenu({super.key});

  @override
  State<StageSelectionMenu> createState() => _StageSelectionMenuState();
}

class _StageSelectionMenuState extends State<StageSelectionMenu> {
  List<Widget> stageRoute = [
    const StageL1(),
    const StageL2(),
    const StageL3(),
    const StageL4(),
    const StageL5(),
    const StageG1(),
    const StageG2(),
    const StageG3(),
    const StageG4(),
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
          title: const Text(
            "스테이지 목록",
            style: TextStyle(
                color: Color.fromARGB(255, 67, 107, 175),
                fontSize: 28,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          backgroundColor: const Color.fromARGB(255, 240, 240, 240),
          elevation: 0,
        ),
        backgroundColor: const Color.fromARGB(255, 240, 240, 240),
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
  static const String stageLocked = "assets/images/stage_selec_locked.svg";
  static const String stageUnLocked = "assets/images/stage_selec_unlocked.svg";

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
      padding: const EdgeInsets.all(15),
      scrollDirection: Axis.horizontal,
      itemCount: 30,
      separatorBuilder: (context, index) => const Divider(
        height: 20,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(context,
                    MaterialPageRoute(builder: (_) => widget.stageRoute[index]))
                .then((value) => setState(() {}));
          },
          child: FutureBuilder(
            future: getStage(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child:
                      Stack(alignment: AlignmentDirectional.center, children: [
                    Center(
                      child: SvgPicture.asset(
                        snapshot.data![index] ? stageUnLocked : stageLocked,
                        width: MediaQuery.of(context).size.width * 0.75,
                        height: MediaQuery.of(context).size.height * 0.95,
                      ),
                    ),
                    Container(
                      width: 150,
                      height: 60,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 3,
                              color: const Color.fromARGB(255, 159, 163, 163)),
                          color: const Color.fromARGB(255, 93, 107, 114)),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                            snapshot.data![index]
                                ? Icons.lock_open
                                : Icons.lock,
                            size: 33,
                            color: Colors.yellow),
                        Text(
                          " Stage ${index + 1}",
                          style: const TextStyle(
                              color: Color.fromARGB(255, 205, 167, 0),
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              shadows: <Shadow>[
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 10.0,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ]),
                        ),
                      ],
                    )
                  ]),
                );
              } else {
                return const CircularProgressIndicator();
              }
            },
          ),
        );
      },
    );
  }
}
