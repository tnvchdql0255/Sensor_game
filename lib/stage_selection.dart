import 'package:sensor_game/service/db_manager.dart';
import 'package:sensor_game/stage/stage_L_1.dart';
import 'package:sensor_game/stage/stage_L_2.dart';
import 'package:sensor_game/stage/stage_L_3.dart';
import 'package:sensor_game/stage/stage_L_4.dart';
import 'package:sensor_game/stage/stage_L_5.dart';
import 'package:sensor_game/stage/stage_S_1.dart';
import 'package:sensor_game/stage/stage_S_2.dart';
import 'package:sensor_game/stage/stage_S_3.dart';
import 'package:sensor_game/stage/stage_G_1.dart';
import 'package:sensor_game/stage/stage_G_4.dart';
import 'package:sensor_game/stage/stage_k_1.dart';
import 'package:sensor_game/stage/stage_k_2.dart';
import 'package:sensor_game/stage/stage_k_3.dart';
import 'package:sensor_game/stage/stage_k_4.dart';
import 'package:sensor_game/stage/stage_k_5.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class StageSelectionMenu extends StatefulWidget {
  const StageSelectionMenu({super.key});

  @override
  State<StageSelectionMenu> createState() => _StageSelectionMenuState();
}

class _StageSelectionMenuState extends State<StageSelectionMenu> {
  List<Widget> stageRoute = [
    const StageG1(),
    const StageG4(),
    const StageL1(),
    const StageL2(),
    const StageL3(),
    const StageL4(),
    const StageL5(),
    const StageS1(),
    const StageS2(),
    const StageS3(),
    const StageK1(),
    const StageK2(),
    const StageK3(),
    const StageK4(
      videoUrl: '',
    ),
    const StageK5(),
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
        appBar: AppBar(title: const Text("Temp")),
        backgroundColor: Colors.lightBlue,
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
          child: Container(
            height: 50,
            width: 200,
            margin: const EdgeInsets.all(10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: Colors.blue.shade200,
            ),
            child: FutureBuilder(
              future: getStage(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              snapshot.data![index]
                                  ? Icons.lock_open
                                  : Icons.lock,
                              color: Colors.white,
                            )
                          ],
                        ),
                        Text(
                          "Stage ${index + 1}",
                          style: const TextStyle(
                              fontSize: 30, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const CircularProgressIndicator();
                }
              },
            ),
          ),
        );
      },
    );
  }
}
