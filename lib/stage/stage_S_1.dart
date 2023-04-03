import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';

class StageS1 extends StatefulWidget {
  const StageS1({super.key});

  @override
  State<StageS1> createState() => _StageS1State();
}

class _StageS1State extends State<StageS1> {
  StreamSubscription<int>? _pedometerStatesubscription;
  int _stepCount = 0;

  @override
  void initState() {
    super.initState();
    startListening();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  void startListening() {
    _pedometerStatesubscription = Pedometer.stepCountStream.listen(onStepCount);
  }

  void stopListening() {
    _pedometerStatesubscription?.cancel();
    _pedometerStatesubscription = null;
  }

  void onStepCount(int stepCountValue) {
    setState(() {
      _stepCount = stepCountValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedometer'),
      ),
      body: Center(
        child: Text(
          '걸음 수: $_stepCount',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
