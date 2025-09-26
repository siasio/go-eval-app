import 'package:flutter/material.dart';
import '../models/app_skin.dart';

class AppTheme {
  static ThemeData getTheme(AppSkin skin) {
    switch (skin) {
      case AppSkin.classic:
        return _classicTheme;
      case AppSkin.modern:
        return _modernTheme;
      case AppSkin.ocean:
        return _oceanTheme;
      case AppSkin.eink:
        return _einkTheme;
    }
  }

  // Classic brown wood theme (current default)
  static final ThemeData _classicTheme = ThemeData(
    primarySwatch: Colors.brown,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFF5F5DC),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF8B4513),
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
    ),
    cardColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B4513),
      brightness: Brightness.light,
    ),
  );

  // Modern dark theme
  static final ThemeData _modernTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFF121212),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
    ),
    cardColor: const Color(0xFF2D2D2D),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.indigo,
      brightness: Brightness.dark,
    ),
  );

  // Ocean blue theme
  static final ThemeData _oceanTheme = ThemeData(
    primarySwatch: Colors.blue,
    useMaterial3: true,
    scaffoldBackgroundColor: const Color(0xFFE3F2FD),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1565C0),
      foregroundColor: Colors.white,
      elevation: 4,
      centerTitle: true,
    ),
    cardColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF1565C0),
      brightness: Brightness.light,
    ),
  );

  // E-ink minimalist black and white theme
  static final ThemeData _einkTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: false, // Disable Material 3 for simpler appearance
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.black,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0, // No shadow for e-ink
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardColor: Colors.white,
    cardTheme: const CardThemeData(
      elevation: 0, // No shadow for e-ink
      color: Colors.white,
      surfaceTintColor: Colors.white,
    ),
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.grey,
      surface: Colors.white,
      background: Colors.white,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.black,
      onBackground: Colors.black,
      outline: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        side: const BorderSide(color: Colors.black, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        side: const BorderSide(color: Colors.black, width: 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black),
      displayLarge: TextStyle(color: Colors.black),
      displayMedium: TextStyle(color: Colors.black),
      displaySmall: TextStyle(color: Colors.black),
      headlineLarge: TextStyle(color: Colors.black),
      headlineMedium: TextStyle(color: Colors.black),
      headlineSmall: TextStyle(color: Colors.black),
      titleLarge: TextStyle(color: Colors.black),
      titleMedium: TextStyle(color: Colors.black),
      titleSmall: TextStyle(color: Colors.black),
      labelLarge: TextStyle(color: Colors.black),
      labelMedium: TextStyle(color: Colors.black),
      labelSmall: TextStyle(color: Colors.black),
    ),
    iconTheme: const IconThemeData(color: Colors.black),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.black,
    ),
    dropdownMenuTheme: const DropdownMenuThemeData(
      textStyle: TextStyle(color: Colors.black),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      labelStyle: TextStyle(color: Colors.black),
      hintStyle: TextStyle(color: Colors.grey),
      helperStyle: TextStyle(color: Colors.grey),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.black, width: 2),
      ),
    ),
  );
}

class SkinConfig {
  static bool shouldAnimate(AppSkin skin) {
    return skin != AppSkin.eink;
  }

  static bool shouldGrayOutBoard(AppSkin skin) {
    return skin != AppSkin.eink;
  }

  static Color getCorrectColor(AppSkin skin) {
    return skin == AppSkin.eink ? Colors.black : Colors.green;
  }

  static Color getIncorrectColor(AppSkin skin) {
    return skin == AppSkin.eink ? Colors.black : Colors.red;
  }

  static Color getProgressBarColor(AppSkin skin) {
    switch (skin) {
      case AppSkin.classic:
        return Colors.green;
      case AppSkin.modern:
        return Colors.indigo;
      case AppSkin.ocean:
        return Colors.blue;
      case AppSkin.eink:
        return Colors.black;
    }
  }

  static Color getButtonColor(AppSkin skin, String buttonType) {
    switch (buttonType) {
      case 'white':
        return Colors.white;
      case 'black':
        switch (skin) {
          case AppSkin.classic:
            return Colors.black87;
          case AppSkin.modern:
            return const Color(0xFF1A1A1A);
          case AppSkin.ocean:
            return const Color(0xFF0D47A1);
          case AppSkin.eink:
            return Colors.black;
        }
      case 'draw':
      default:
        switch (skin) {
          case AppSkin.classic:
            return const Color(0xFFD4B896); // Warm beige for classic
          case AppSkin.modern:
            return const Color(0xFF424242); // Dark grey for modern
          case AppSkin.ocean:
            return const Color(0xFF42A5F5); // Light blue for ocean
          case AppSkin.eink:
            return Colors.grey.shade400;
        }
    }
  }

  static Color getButtonTextColor(AppSkin skin, String buttonType) {
    switch (buttonType) {
      case 'white':
        return Colors.black; // Black text on white background for all themes
      case 'black':
        return Colors.white; // White text on dark background for all themes
      case 'draw':
      default:
        switch (skin) {
          case AppSkin.classic:
            return const Color(0xFF5D4037); // Dark brown text for classic beige
          case AppSkin.modern:
            return Colors.white; // White text on dark grey
          case AppSkin.ocean:
            return Colors.white; // White text on blue
          case AppSkin.eink:
            return Colors.black; // Black text on light grey
        }
    }
  }

  static Color getBoardColor(AppSkin skin) {
    switch (skin) {
      case AppSkin.classic:
        return const Color(0xFFDEB887); // Tan
      case AppSkin.modern:
        return const Color(0xFF424242); // Dark grey
      case AppSkin.ocean:
        return const Color(0xFF90CAF9); // Light blue
      case AppSkin.eink:
        return Colors.white;
    }
  }

  static Color getStoneColor(AppSkin skin, bool isBlack) {
    if (skin == AppSkin.eink) {
      return isBlack ? Colors.black : Colors.white;
    }

    // For other themes, use traditional stone colors
    return isBlack ? Colors.black : Colors.white;
  }

  // Get theme-appropriate background color for progress bars
  static Color getProgressBarBackgroundColor(AppSkin skin) {
    switch (skin) {
      case AppSkin.classic:
        return Colors.grey[300]!;
      case AppSkin.modern:
        return const Color(0xFF2D2D2D);
      case AppSkin.ocean:
        return const Color(0xFFBBDEFB);
      case AppSkin.eink:
        return Colors.grey.shade200;
    }
  }

  // Get theme-appropriate colors for feedback overlay background
  static Color getFeedbackOverlayColor(AppSkin skin) {
    if (skin == AppSkin.eink) {
      return Colors.transparent; // No overlay for e-ink
    }
    return Colors.black26; // Semi-transparent black for other themes
  }

  // Get theme-appropriate border colors
  static Color getBorderColor(AppSkin skin) {
    switch (skin) {
      case AppSkin.classic:
        return const Color(0xFF8B4513); // Brown
      case AppSkin.modern:
        return const Color(0xFF424242); // Dark grey
      case AppSkin.ocean:
        return const Color(0xFF1565C0); // Blue
      case AppSkin.eink:
        return Colors.black;
    }
  }

  // Get theme-appropriate text colors for general use
  static Color getTextColor(AppSkin skin) {
    switch (skin) {
      case AppSkin.classic:
        return const Color(0xFF3E2723); // Dark brown
      case AppSkin.modern:
        return Colors.white;
      case AppSkin.ocean:
        return const Color(0xFF0D47A1); // Dark blue
      case AppSkin.eink:
        return Colors.black;
    }
  }
}