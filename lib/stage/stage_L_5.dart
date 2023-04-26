import 'package:flutter/material.dart';

class StageL5 extends StatefulWidget {
  const StageL5({super.key});

  @override
  State<StageL5> createState() => _StageL5State();
}

class _StageL5State extends State<StageL5> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Temp")),
        backgroundColor: Colors.lightBlue,
        body: Column(
          children: [
            Text("dd"),
          ],
        ));
  }
}
