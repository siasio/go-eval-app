import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:countingapp/themes/app_theme.dart';
import 'package:countingapp/models/app_skin.dart';

void main() {
  group('AppTheme', () {
    test('should return classic theme for AppSkin.classic', () {
      final theme = AppTheme.getTheme(AppSkin.classic);

      expect(theme.scaffoldBackgroundColor, const Color(0xFFF5F5DC));
      expect(theme.appBarTheme.backgroundColor, const Color(0xFF8B4513));
    });

    test('should return modern dark theme for AppSkin.modern', () {
      final theme = AppTheme.getTheme(AppSkin.modern);

      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF121212));
    });

    test('should return ocean theme for AppSkin.ocean', () {
      final theme = AppTheme.getTheme(AppSkin.ocean);

      expect(theme.scaffoldBackgroundColor, const Color(0xFFE3F2FD));
      expect(theme.appBarTheme.backgroundColor, const Color(0xFF1565C0));
    });

    test('should return e-ink theme for AppSkin.eink', () {
      final theme = AppTheme.getTheme(AppSkin.eink);

      expect(theme.brightness, Brightness.light);
      expect(theme.scaffoldBackgroundColor, Colors.white);
      expect(theme.appBarTheme.backgroundColor, Colors.white);
      expect(theme.appBarTheme.foregroundColor, Colors.black);
      expect(theme.appBarTheme.elevation, 0);
    });
  });

  group('SkinConfig', () {
    test('should return correct animation setting for each skin', () {
      expect(SkinConfig.shouldAnimate(AppSkin.classic), isTrue);
      expect(SkinConfig.shouldAnimate(AppSkin.modern), isTrue);
      expect(SkinConfig.shouldAnimate(AppSkin.ocean), isTrue);
      expect(SkinConfig.shouldAnimate(AppSkin.eink), isFalse);
    });

    test('should return correct board graying setting for each skin', () {
      expect(SkinConfig.shouldGrayOutBoard(AppSkin.classic), isTrue);
      expect(SkinConfig.shouldGrayOutBoard(AppSkin.modern), isTrue);
      expect(SkinConfig.shouldGrayOutBoard(AppSkin.ocean), isTrue);
      expect(SkinConfig.shouldGrayOutBoard(AppSkin.eink), isFalse);
    });

    test('should return correct colors for feedback indicators', () {
      expect(SkinConfig.getCorrectColor(AppSkin.classic), Colors.green);
      expect(SkinConfig.getCorrectColor(AppSkin.modern), Colors.green);
      expect(SkinConfig.getCorrectColor(AppSkin.ocean), Colors.green);
      expect(SkinConfig.getCorrectColor(AppSkin.eink), Colors.black);

      expect(SkinConfig.getIncorrectColor(AppSkin.classic), Colors.red);
      expect(SkinConfig.getIncorrectColor(AppSkin.modern), Colors.red);
      expect(SkinConfig.getIncorrectColor(AppSkin.ocean), Colors.red);
      expect(SkinConfig.getIncorrectColor(AppSkin.eink), Colors.black);
    });

    test('should return correct board colors for each skin', () {
      expect(SkinConfig.getBoardColor(AppSkin.classic), const Color(0xFFDEB887));
      expect(SkinConfig.getBoardColor(AppSkin.modern), const Color(0xFF424242));
      expect(SkinConfig.getBoardColor(AppSkin.ocean), const Color(0xFF90CAF9));
      expect(SkinConfig.getBoardColor(AppSkin.eink), Colors.white);
    });

    test('should return correct stone colors', () {
      // Test black stones
      expect(SkinConfig.getStoneColor(AppSkin.classic, true), Colors.black);
      expect(SkinConfig.getStoneColor(AppSkin.modern, true), Colors.black);
      expect(SkinConfig.getStoneColor(AppSkin.ocean, true), Colors.black);
      expect(SkinConfig.getStoneColor(AppSkin.eink, true), Colors.black);

      // Test white stones
      expect(SkinConfig.getStoneColor(AppSkin.classic, false), Colors.white);
      expect(SkinConfig.getStoneColor(AppSkin.modern, false), Colors.white);
      expect(SkinConfig.getStoneColor(AppSkin.ocean, false), Colors.white);
      expect(SkinConfig.getStoneColor(AppSkin.eink, false), Colors.white);
    });

    test('should return correct progress bar colors', () {
      expect(SkinConfig.getProgressBarColor(AppSkin.classic), Colors.green);
      expect(SkinConfig.getProgressBarColor(AppSkin.modern), Colors.indigo);
      expect(SkinConfig.getProgressBarColor(AppSkin.ocean), Colors.blue);
      expect(SkinConfig.getProgressBarColor(AppSkin.eink), Colors.black);
    });

    test('should return correct button colors for different types', () {
      // Test white button - same for all themes
      expect(SkinConfig.getButtonColor(AppSkin.eink, 'white'), Colors.white);
      expect(SkinConfig.getButtonColor(AppSkin.classic, 'white'), Colors.white);
      expect(SkinConfig.getButtonColor(AppSkin.modern, 'white'), Colors.white);
      expect(SkinConfig.getButtonColor(AppSkin.ocean, 'white'), Colors.white);

      // Test black button - theme specific
      expect(SkinConfig.getButtonColor(AppSkin.eink, 'black'), Colors.black);
      expect(SkinConfig.getButtonColor(AppSkin.classic, 'black'), Colors.black87);
      expect(SkinConfig.getButtonColor(AppSkin.modern, 'black'), const Color(0xFF1A1A1A));
      expect(SkinConfig.getButtonColor(AppSkin.ocean, 'black'), const Color(0xFF0D47A1));

      // Test draw button - theme specific
      expect(SkinConfig.getButtonColor(AppSkin.eink, 'draw'), Colors.grey.shade400);
      expect(SkinConfig.getButtonColor(AppSkin.classic, 'draw'), const Color(0xFFD4B896));
      expect(SkinConfig.getButtonColor(AppSkin.modern, 'draw'), const Color(0xFF424242));
      expect(SkinConfig.getButtonColor(AppSkin.ocean, 'draw'), const Color(0xFF42A5F5));
    });

    test('should return correct button text colors', () {
      // White button - black text for all themes
      expect(SkinConfig.getButtonTextColor(AppSkin.eink, 'white'), Colors.black);
      expect(SkinConfig.getButtonTextColor(AppSkin.classic, 'white'), Colors.black);
      expect(SkinConfig.getButtonTextColor(AppSkin.modern, 'white'), Colors.black);
      expect(SkinConfig.getButtonTextColor(AppSkin.ocean, 'white'), Colors.black);

      // Black button - white text for all themes
      expect(SkinConfig.getButtonTextColor(AppSkin.eink, 'black'), Colors.white);
      expect(SkinConfig.getButtonTextColor(AppSkin.classic, 'black'), Colors.white);
      expect(SkinConfig.getButtonTextColor(AppSkin.modern, 'black'), Colors.white);
      expect(SkinConfig.getButtonTextColor(AppSkin.ocean, 'black'), Colors.white);

      // Draw button - theme specific
      expect(SkinConfig.getButtonTextColor(AppSkin.eink, 'draw'), Colors.black);
      expect(SkinConfig.getButtonTextColor(AppSkin.classic, 'draw'), const Color(0xFF5D4037));
      expect(SkinConfig.getButtonTextColor(AppSkin.modern, 'draw'), Colors.white);
      expect(SkinConfig.getButtonTextColor(AppSkin.ocean, 'draw'), Colors.white);
    });

    test('should return correct progress bar background colors', () {
      expect(SkinConfig.getProgressBarBackgroundColor(AppSkin.classic), Colors.grey[300]!);
      expect(SkinConfig.getProgressBarBackgroundColor(AppSkin.modern), const Color(0xFF2D2D2D));
      expect(SkinConfig.getProgressBarBackgroundColor(AppSkin.ocean), const Color(0xFFBBDEFB));
      expect(SkinConfig.getProgressBarBackgroundColor(AppSkin.eink), Colors.grey.shade200);
    });

    test('should return correct feedback overlay colors', () {
      expect(SkinConfig.getFeedbackOverlayColor(AppSkin.classic), Colors.black26);
      expect(SkinConfig.getFeedbackOverlayColor(AppSkin.modern), Colors.black26);
      expect(SkinConfig.getFeedbackOverlayColor(AppSkin.ocean), Colors.black26);
      expect(SkinConfig.getFeedbackOverlayColor(AppSkin.eink), Colors.transparent);
    });

    test('should return correct border colors', () {
      expect(SkinConfig.getBorderColor(AppSkin.classic), const Color(0xFF8B4513));
      expect(SkinConfig.getBorderColor(AppSkin.modern), const Color(0xFF424242));
      expect(SkinConfig.getBorderColor(AppSkin.ocean), const Color(0xFF1565C0));
      expect(SkinConfig.getBorderColor(AppSkin.eink), Colors.black);
    });

    test('should return correct text colors', () {
      expect(SkinConfig.getTextColor(AppSkin.classic), const Color(0xFF3E2723));
      expect(SkinConfig.getTextColor(AppSkin.modern), Colors.white);
      expect(SkinConfig.getTextColor(AppSkin.ocean), const Color(0xFF0D47A1));
      expect(SkinConfig.getTextColor(AppSkin.eink), Colors.black);
    });
  });
}