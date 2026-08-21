import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/numerology/compatibility.dart';
import 'package:ruh_code/src/interpretation/numerology_compatibility_interpretation.dart';

void main() {
  NumerologyCompatibilityCatalog fullCatalog() {
    final entries = <NumerologyCompatibilityInterpretationKey,
        NumerologyCompatibilityContentEntry>{};
    for (final metric in NumerologyCompatibilityMetric.values) {
      for (final exactMatch in <bool>[true, false]) {
        final key = NumerologyCompatibilityInterpretationKey(
          metric: metric,
          exactMatch: exactMatch,
        );
        entries[key] = NumerologyCompatibilityContentEntry(
          ruleId: key.stableId,
          tr: '${metric.name} için Türkçe ${exactMatch ? 'eşleşme' : 'fark'} metni.',
          en: 'English ${exactMatch ? 'match' : 'difference'} text for ${metric.name}.',
        );
      }
    }
    return NumerologyCompatibilityCatalog(entries);
  }

  const snapshot = PythagoreanCompatibilityResult(
    comparisons: <NumerologyMetricComparison>[
      NumerologyMetricComparison(
        metric: NumerologyCompatibilityMetric.lifePath,
        leftValue: 7,
        rightValue: 7,
        absoluteDifference: 0,
        exactMatch: true,
      ),
      NumerologyMetricComparison(
        metric: NumerologyCompatibilityMetric.expression,
        leftValue: 5,
        rightValue: 9,
        absoluteDifference: 4,
        exactMatch: false,
      ),
    ],
    exactMatchCount: 1,
  );

  test('TR and EN content stay separate from calculation values', () async {
    final engine = PythagoreanCompatibilityInterpretationEngine(
      catalog: fullCatalog(),
    );

    final tr = await engine.interpret(snapshot: snapshot, localeTag: 'tr');
    final en = await engine.interpret(snapshot: snapshot, localeTag: 'en');

    expect(tr.items, hasLength(2));
    expect(en.items, hasLength(2));
    expect(tr.items.first, contains('Türkçe'));
    expect(en.items.first, contains('English'));
    expect(tr.items, isNot(equals(en.items)));
    expect(tr.sourceRuleIds, en.sourceRuleIds);

    expect(snapshot.comparisons.first.leftValue, 7);
    expect(snapshot.comparisons.first.rightValue, 7);
    expect(snapshot.comparisons.last.absoluteDifference, 4);
    expect(snapshot.exactMatchCount, 1);
  });

  test('catalog rejects missing metric/state coverage', () {
    final key = const NumerologyCompatibilityInterpretationKey(
      metric: NumerologyCompatibilityMetric.lifePath,
      exactMatch: true,
    );
    expect(
      () => NumerologyCompatibilityCatalog(
        <NumerologyCompatibilityInterpretationKey,
            NumerologyCompatibilityContentEntry>{
          key: NumerologyCompatibilityContentEntry(
            ruleId: key.stableId,
            tr: 'Türkçe metin.',
            en: 'English text.',
          ),
        },
      ),
      throwsStateError,
    );
  });

  test('content rejects blank locale text and unresolved placeholders', () {
    expect(
      () => NumerologyCompatibilityContentEntry(
        ruleId: 'rule.blank',
        tr: ' ',
        en: 'English',
      ),
      throwsFormatException,
    );
    expect(
      () => NumerologyCompatibilityContentEntry(
        ruleId: 'rule.placeholder',
        tr: 'Değer {value}',
        en: 'Value text',
      ),
      throwsFormatException,
    );
  });

  test('unsupported locale never silently falls back', () async {
    final engine = PythagoreanCompatibilityInterpretationEngine(
      catalog: fullCatalog(),
    );

    await expectLater(
      engine.interpret(snapshot: snapshot, localeTag: 'de'),
      throwsArgumentError,
    );
  });
}
