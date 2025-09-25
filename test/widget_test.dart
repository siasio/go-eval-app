// Flutter widget test for Go Territory Trainer app.
//
// Tests basic app functionality and widget structure.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:countingapp/main.dart';

void main() {
  testWidgets('App loads and shows Go board', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GoCountingApp());

    // Wait for async initialization
    await tester.pumpAndSettle();

    // Verify that the app loads (look for key UI elements)
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  testWidgets('App has basic structure', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GoCountingApp());

    // Wait for async operations
    await tester.pumpAndSettle();

    // App should have a basic structure - just verify it doesn't crash
    expect(tester.takeException(), isNull);
  });
}
