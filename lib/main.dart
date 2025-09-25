import 'package:flutter/material.dart';
import 'screens/training_screen.dart';
import 'services/position_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PositionManager.initialize();
  runApp(const GoCountingApp());
}

class GoCountingApp extends StatelessWidget {
  const GoCountingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Go Territory Counting',
      theme: ThemeData(
        primarySwatch: Colors.brown,
        useMaterial3: true,
      ),
      home: const TrainingScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}