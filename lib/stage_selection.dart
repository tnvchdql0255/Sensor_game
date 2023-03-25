import 'package:sensor_game/stage/stage_L_1.dart';
import 'package:flutter/material.dart';

class StageSelectionMenu extends StatefulWidget {
  const StageSelectionMenu({super.key});

  @override
  State<StageSelectionMenu> createState() => _StageSelectionMenuState();
}

class _StageSelectionMenuState extends State<StageSelectionMenu> {
  List<Widget> stageRoute = [const StageL1()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Temp")),
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
        return stageSelectionPannel(context, index);
      },
    );
  }

  GestureDetector stageSelectionPannel(BuildContext context, int index) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => stageRoute[index]));
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
                children: const [
                  Icon(
                    Icons.lock_open,
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
  }
}
