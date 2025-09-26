import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:countingapp/widgets/timer_bar.dart';
import 'package:countingapp/models/timer_type.dart';
import 'package:countingapp/models/app_skin.dart';

void main() {
  group('TimerBar Widget Tests', () {
    testWidgets('should render horizontal smooth timer without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerBar(
              duration: const Duration(seconds: 10),
              timerType: TimerType.smooth,
              appSkin: AppSkin.classic,
              isVertical: false,
            ),
          ),
        ),
      );

      expect(find.byType(TimerBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render vertical smooth timer without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200,
              width: 50,
              child: TimerBar(
                duration: const Duration(seconds: 10),
                timerType: TimerType.smooth,
                appSkin: AppSkin.classic,
                isVertical: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TimerBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render segmented timer without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerBar(
              duration: const Duration(seconds: 5),
              timerType: TimerType.segmented,
              appSkin: AppSkin.classic,
              isVertical: false,
            ),
          ),
        ),
      );

      expect(find.byType(TimerBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should render e-ink timer without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimerBar(
              duration: const Duration(seconds: 10),
              timerType: TimerType.smooth,
              appSkin: AppSkin.eink,
              isVertical: false,
            ),
          ),
        ),
      );

      expect(find.byType(TimerBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle very small containers without overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 10,
              width: 50,
              child: TimerBar(
                duration: const Duration(seconds: 10),
                timerType: TimerType.smooth,
                appSkin: AppSkin.classic,
                isVertical: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TimerBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('should handle different screen sizes for vertical timer', (WidgetTester tester) async {
      // Test with constrained height
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 100,
              width: 20,
              child: TimerBar(
                duration: const Duration(seconds: 30), // Many segments
                timerType: TimerType.segmented,
                appSkin: AppSkin.classic,
                isVertical: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(TimerBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}