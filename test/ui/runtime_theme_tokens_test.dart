import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/ui/theme/ruh_design_tokens.dart';

void main() {
  group('RuhAppTheme', () {
    test('uses the canonical palette in ThemeData', () {
      final theme = RuhAppTheme.light();

      expect(theme.scaffoldBackgroundColor, RuhDesignTokens.background);
      expect(theme.cardColor, RuhDesignTokens.surface);
      expect(theme.dividerColor, RuhDesignTokens.line);
      expect(theme.colorScheme.primary, RuhDesignTokens.primary);
      expect(theme.colorScheme.onPrimary, RuhDesignTokens.surface);
      expect(theme.colorScheme.secondary, RuhDesignTokens.gold);
      expect(theme.colorScheme.onSecondary, RuhDesignTokens.textPrimary);
      expect(theme.colorScheme.error, RuhDesignTokens.danger);
      expect(theme.colorScheme.onError, RuhDesignTokens.surface);
      expect(theme.colorScheme.surface, RuhDesignTokens.surface);
      expect(theme.colorScheme.onSurface, RuhDesignTokens.textPrimary);
      expect(theme.colorScheme.outline, RuhDesignTokens.line);
    });

    test('keeps the accessibility touch target at 48dp or larger', () {
      expect(RuhDesignTokens.minimumTouchTarget, greaterThanOrEqualTo(48));
    });
  });
}
