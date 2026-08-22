import 'package:flutter/material.dart';

/// Runtime bridge for the canonical values in `ui/design_tokens.json`.
///
/// Keep this file intentionally small and literal: CI verifies every color value
/// against the machine-readable design-token contract so rendered Flutter UI
/// cannot silently drift from the approved Ruh Code palette.
abstract final class RuhDesignTokens {
  static const Color background = Color(0xFFFBF8F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceSoft = Color(0xFFF5EEE6);
  static const Color textPrimary = Color(0xFF25173E);
  static const Color textMuted = Color(0xFF6D617D);
  static const Color line = Color(0xFFE9DDCE);
  static const Color primary = Color(0xFF4C2A91);
  static const Color primaryStrong = Color(0xFF6B42E6);
  static const Color gold = Color(0xFFC89338);
  static const Color success = Color(0xFF12AD62);
  static const Color danger = Color(0xFFC23B53);

  static const double radiusXs = 8;
  static const double radiusSm = 12;
  static const double radiusMd = 16;
  static const double radiusLg = 22;
  static const double radiusXl = 28;
  static const double radiusPill = 999;

  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 12;
  static const double spacingLg = 16;
  static const double spacingXl = 24;
  static const double spacingXxl = 32;

  static const double minimumTouchTarget = 48;
}

abstract final class RuhAppTheme {
  static ThemeData light() {
    const scheme = ColorScheme.light(
      primary: RuhDesignTokens.primary,
      onPrimary: RuhDesignTokens.surface,
      secondary: RuhDesignTokens.gold,
      onSecondary: RuhDesignTokens.textPrimary,
      error: RuhDesignTokens.danger,
      onError: RuhDesignTokens.surface,
      surface: RuhDesignTokens.surface,
      onSurface: RuhDesignTokens.textPrimary,
      outline: RuhDesignTokens.line,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: RuhDesignTokens.background,
      cardColor: RuhDesignTokens.surface,
      dividerColor: RuhDesignTokens.line,
      textTheme: ThemeData.light().textTheme.apply(
            bodyColor: RuhDesignTokens.textPrimary,
            displayColor: RuhDesignTokens.textPrimary,
          ),
    );
  }
}
