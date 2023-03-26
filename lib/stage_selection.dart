import 'package:sensor_game/service/db_manager.dart';
import 'package:sensor_game/stage/stage_L_1.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class StageSelectionMenu extends StatefulWidget {
  const StageSelectionMenu({super.key});

  @override
  State<StageSelectionMenu> createState() => _StageSelectionMenuState();
}

class _StageSelectionMenuState extends State<StageSelectionMenu> {
  List<Widget> stageRoute = [const StageL1()];
  late List<bool> isClearedList;
  late final DBHelper dbHelper;
  late Database db;
  @override
  void initState() {
    getStage();
    super.initState();
  }

  void getStage() async {
    dbHelper = DBHelper();
    db = await dbHelper.db;
    isClearedList = await dbHelper.getAllStageStatus();
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
              stageStatusList: isClearedList,
            )),
          ],
        ));
  }
}

// ignore: must_be_immutable
class RowStageSelection extends StatefulWidget {
  RowStageSelection(
      {super.key, required this.stageRoute, required this.stageStatusList});
  final List<Widget> stageRoute;
  List<bool> stageStatusList;

  @override
  State<RowStageSelection> createState() => _RowStageSelectionState();
}

class _RowStageSelectionState extends State<RowStageSelection> {
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
                MaterialPageRoute(builder: (_) => widget.stageRoute[index]));
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
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(
                        widget.stageStatusList[index]
                            ? Icons.lock_open
                            : Icons.lock,
                        color: Colors.white,
                      )
                    ],
                  ),
                  Text(
                    "Stage ${index + 1}",
                    style: const TextStyle(fontSize: 30, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
