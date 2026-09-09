import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/ui/theme/ruh_design_tokens.dart';

void main() {
  test('title section body caption are explicit and visibly distinct', () {
    final styles = <TextStyle>[
      RuhTypographyTokens.title,
      RuhTypographyTokens.section,
      RuhTypographyTokens.body,
      RuhTypographyTokens.caption,
    ];
    expect(styles.map((s) => s.fontSize).toSet().length, 4);
    expect(RuhTypographyTokens.title.fontSize, greaterThan(RuhTypographyTokens.section.fontSize!));
    expect(RuhTypographyTokens.section.fontSize, greaterThan(RuhTypographyTokens.body.fontSize!));
    expect(RuhTypographyTokens.body.fontSize, 16);
    expect(RuhTypographyTokens.caption.fontSize, greaterThanOrEqualTo(13));
  });

  test('baseline line heights and semantic spacing are explicit', () {
    expect(RuhTypographyTokens.body.height, 1.50);
    expect(RuhTypographyTokens.caption.height, 1.35);
    expect(RuhDesignTokens.paragraphSpacing, 12);
    expect(RuhDesignTokens.sectionSpacing, 24);
    expect(RuhDesignTokens.cardPadding, 16);
    expect(RuhDesignTokens.screenEdgePadding, 16);
    expect(RuhDesignTokens.pdfEdgePadding, 16);
    expect(RuhDesignTokens.chartLegendGap, 8);
    expect(RuhDesignTokens.chartLegendItemGap, 12);
    expect(RuhTypographyTokens.chartLabelMinimumFontSize, greaterThanOrEqualTo(13));
  });

  test('light mode normal text contrast meets WCAG AA 4.5', () {
    _expectContrast(RuhDesignTokens.textPrimary, RuhDesignTokens.background, 4.5);
    _expectContrast(RuhDesignTokens.textMuted, RuhDesignTokens.background, 4.5);
    _expectContrast(RuhDesignTokens.textPrimary, RuhDesignTokens.surface, 4.5);
    _expectContrast(RuhDesignTokens.textMuted, RuhDesignTokens.surface, 4.5);
  });

  test('dark mode normal text contrast meets WCAG AA 4.5', () {
    _expectContrast(RuhDesignTokens.darkTextPrimary, RuhDesignTokens.darkBackground, 4.5);
    _expectContrast(RuhDesignTokens.darkTextMuted, RuhDesignTokens.darkBackground, 4.5);
    _expectContrast(RuhDesignTokens.darkTextPrimary, RuhDesignTokens.darkSurface, 4.5);
    _expectContrast(RuhDesignTokens.darkTextMuted, RuhDesignTokens.darkSurface, 4.5);
  });

  testWidgets('light and dark themes expose semantic text classes', (tester) async {
    for (final theme in <ThemeData>[RuhAppTheme.light(), RuhAppTheme.dark()]) {
      expect(theme.textTheme.headlineMedium?.fontSize, 28);
      expect(theme.textTheme.titleLarge?.fontSize, 20);
      expect(theme.textTheme.bodyMedium?.fontSize, 16);
      expect(theme.textTheme.bodySmall?.fontSize, 13);
    }
  });
}

void _expectContrast(Color foreground, Color background, double minimum) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  final ratio = (lighter + 0.05) / (darker + 0.05);
  expect(ratio, greaterThanOrEqualTo(minimum));
}
