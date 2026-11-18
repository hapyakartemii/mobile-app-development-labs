import 'package:flutter/material.dart';

/// Spacing scale shared by all screens and widgets.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
  static const double radius = 16;
}

/// Brand and status colors of the app.
abstract final class AppColors {
  static const Color seed = Color(0xFF0277BD);
  static const Color online = Color(0xFF2E7D32);
  static const Color offline = Color(0xFFC62828);
}

/// Single source of truth for the visual style.
abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: AppColors.seed);
    final radius = BorderRadius.circular(AppSpacing.radius);
    final shape = RoundedRectangleBorder(borderRadius: radius);
    const buttonSize = Size.fromHeight(52);

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: scheme.surface,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: scheme.surfaceContainerLow,
        shape: shape,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(borderRadius: radius),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: buttonSize, shape: shape),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(minimumSize: buttonSize, shape: shape),
      ),
    );
  }
}
