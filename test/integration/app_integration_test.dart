import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:countingapp/main.dart' as app;

void main() {
  group('App Integration Tests', () {
    testWidgets('app should start without errors and render main screen', (WidgetTester tester) async {
      // Run the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify app starts without exceptions
      expect(tester.takeException(), isNull);

      // Verify main components are present
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));

      // Verify we can find the app title
      expect(find.text('Go Territory Counting'), findsOneWidget);
    });

    testWidgets('navigation to settings should work', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap on settings icon
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Should not cause any exceptions
      expect(tester.takeException(), isNull);

      // Should show settings screen
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('app should handle configuration screen navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Navigate to global configuration
      await tester.tap(find.text('Global Settings'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Global Settings'), findsAtLeastNWidgets(1));

      // Go back
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('app should handle different themes without errors', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to global settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Global Settings'));
      await tester.pumpAndSettle();

      // Try to change to e-ink theme - look for dropdown
      final dropdown = find.byType(DropdownButtonFormField<dynamic>).last;
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      // Find and tap E-ink Minimalist option
      await tester.tap(find.text('E-ink Minimalist').last);
      await tester.pumpAndSettle();

      // Should not cause any exceptions
      expect(tester.takeException(), isNull);
    });
  });
}