import 'package:sensor_game/stage/stage_L_1.dart';
import 'package:sensor_game/stage/stage_S_1.dart';
import 'package:flutter/material.dart';

class StageSelectionMenu extends StatefulWidget {
  const StageSelectionMenu({super.key});

  @override
  State<StageSelectionMenu> createState() => _StageSelectionMenuState();
}

class _StageSelectionMenuState extends State<StageSelectionMenu> {
  List<Widget> stageRoute = [
    const StageS1(),
    const StageL1()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Temp")),
        backgroundColor: Colors.lightBlue,
        body: Column(
          children: [
            Expanded(child: RowStageSelection(stageRoute: stageRoute)),
          ],
        ));
  }
}

class RowStageSelection extends StatelessWidget {
  const RowStageSelection({super.key, required this.stageRoute});
  final List<Widget> stageRoute;

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
        return Container(
          height: 50,
          width: 50,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.blue.shade200,
          ),
          child: TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => stageRoute[index]));
            },
            child: Text(
              "Stage $index",
              style: TextStyle(fontSize: 30),
            ),
          ),
        );
      },
    );
  }
}

class gridStageSelection extends StatelessWidget {
  const gridStageSelection({
    super.key,
    required this.stageRoute,
  });

  final List<Widget> stageRoute;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GridView.builder(
        itemCount: 30,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 3 / 1,
        ),
        itemBuilder: (BuildContext context, int index) {
          return TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => stageRoute[index]));
            },
            child: Text('Button $index'),
          );
        },
      ),
    );
  }
}
