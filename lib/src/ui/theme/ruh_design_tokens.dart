import 'package:flutter/material.dart';

/// Runtime bridge for the canonical values in `ui/design_tokens.json`.
///
/// RC-1273..RC-1285 extends the original palette/radius bridge with explicit
/// typography roles, readable minimum sizes, spacing/padding primitives,
/// chart-legend geometry and a dark palette. Values stay centralized so screen
/// UI, charts and PDF adapters can share one semantic design-system contract.
abstract final class RuhDesignTokens {
  // Light palette.
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

  // Dark palette. Contrast is verified by RC-1284/RC-1285 regression.
  static const Color darkBackground = Color(0xFF17131F);
  static const Color darkSurface = Color(0xFF21192D);
  static const Color darkSurfaceSoft = Color(0xFF2B2138);
  static const Color darkTextPrimary = Color(0xFFF7F2FC);
  static const Color darkTextMuted = Color(0xFFC8BCD5);
  static const Color darkLine = Color(0xFF4A3C5D);
  static const Color darkPrimary = Color(0xFFB79AFF);
  static const Color darkGold = Color(0xFFF0C36A);

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

  // RC-1277..RC-1282 semantic geometry.
  static const double paragraphSpacing = 12;
  static const double sectionSpacing = 24;
  static const double cardPadding = 16;
  static const double screenEdgePadding = 16;
  static const double pdfEdgePadding = 16;
  static const double chartLegendGap = 8;
  static const double chartLegendItemGap = 12;

  static const double minimumTouchTarget = 48;
}

/// Four explicit semantic text classes shared by screen/PDF adapters.
abstract final class RuhTypographyTokens {
  static const TextStyle title = TextStyle(
    fontSize: 28,
    height: 1.20,
    fontWeight: FontWeight.w700,
  );
  static const TextStyle section = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle body = TextStyle(
    fontSize: 16,
    height: 1.50,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  /// Chart labels must remain readable and are never allowed below caption size.
  static const double chartLabelMinimumFontSize = 13;

  static TextTheme textTheme(Color primary, Color muted) => TextTheme(
        headlineMedium: title.copyWith(color: primary),
        titleLarge: section.copyWith(color: primary),
        bodyMedium: body.copyWith(color: primary),
        bodySmall: caption.copyWith(color: muted),
      );
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
      textTheme: RuhTypographyTokens.textTheme(
        RuhDesignTokens.textPrimary,
        RuhDesignTokens.textMuted,
      ),
    );
  }

  static ThemeData dark() {
    const scheme = ColorScheme.dark(
      primary: RuhDesignTokens.darkPrimary,
      onPrimary: RuhDesignTokens.darkBackground,
      secondary: RuhDesignTokens.darkGold,
      onSecondary: RuhDesignTokens.darkBackground,
      error: Color(0xFFFF8FA3),
      onError: RuhDesignTokens.darkBackground,
      surface: RuhDesignTokens.darkSurface,
      onSurface: RuhDesignTokens.darkTextPrimary,
      outline: RuhDesignTokens.darkLine,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: RuhDesignTokens.darkBackground,
      cardColor: RuhDesignTokens.darkSurface,
      dividerColor: RuhDesignTokens.darkLine,
      textTheme: RuhTypographyTokens.textTheme(
        RuhDesignTokens.darkTextPrimary,
        RuhDesignTokens.darkTextMuted,
      ),
    );
  }
}
