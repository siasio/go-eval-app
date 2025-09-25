import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'screens/training_screen.dart';
import 'services/position_manager.dart';
import 'services/position_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check for dataset URL parameter in web
  String? datasetFile;
  if (kIsWeb) {
    final uri = Uri.parse(html.window.location.href);
    datasetFile = uri.queryParameters['dataset'];
    if (datasetFile != null) {
      print('Using dataset from URL parameter: $datasetFile');
      PositionLoader.setDatasetFile(datasetFile);
    }
  }

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