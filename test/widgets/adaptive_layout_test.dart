import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:countingapp/widgets/adaptive_layout.dart';
import 'package:countingapp/models/layout_type.dart';

void main() {
  group('AdaptiveLayout Widget Tests', () {
    testWidgets('should render vertical layout without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveLayout(
              layoutType: LayoutType.vertical,
              gearIcon: Container(), // Empty in vertical mode
              timerBar: Container(height: 8, color: Colors.green),
              board: Container(
                width: 200,
                height: 200,
                color: Colors.brown,
              ),
              buttons: const Text('Buttons'),
            ),
          ),
        ),
      );

      expect(find.byType(Column), findsOneWidget);
      expect(find.text('Buttons'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render horizontal layout without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveLayout(
              layoutType: LayoutType.horizontal,
              gearIcon: const Icon(Icons.settings),
              timerBar: Container(height: 8, color: Colors.green),
              gameInfoBar: const Text('Game Info'),
              board: Container(
                width: 200,
                height: 200,
                color: Colors.brown,
              ),
              buttons: const Text('Buttons'),
            ),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.text('Game Info'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle missing gameInfoBar in horizontal layout', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveLayout(
              layoutType: LayoutType.horizontal,
              gearIcon: const Icon(Icons.settings),
              timerBar: Container(height: 8, color: Colors.green),
              board: Container(
                width: 200,
                height: 200,
                color: Colors.brown,
              ),
              buttons: const Text('Buttons'),
            ),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle different screen sizes without overflow', (WidgetTester tester) async {
      // Test with a very small screen size
      tester.binding.window.physicalSizeTestValue = const Size(400, 600);
      tester.binding.window.devicePixelRatioTestValue = 1.0;
      addTearDown(tester.binding.window.clearPhysicalSizeTestValue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveLayout(
              layoutType: LayoutType.horizontal,
              gearIcon: const Icon(Icons.settings),
              timerBar: Container(height: 8, color: Colors.green),
              gameInfoBar: const Text('Game Info'),
              board: Container(
                width: 100,
                height: 100,
                color: Colors.brown,
              ),
              buttons: const Text('Buttons'),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}