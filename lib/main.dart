import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'screens/training_screen.dart';
import 'services/position_manager.dart';
import 'services/position_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Future: Could add URL parameter support here if needed
  // For now, dataset selection is handled via the settings UI

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