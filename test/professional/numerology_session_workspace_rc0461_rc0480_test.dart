import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/professional/numerology_session_workspace.dart';

final class _Provider implements NumerologyPeriodProvider {
  @override
  NumerologyYearPeriod buildYear({required int year, required NumerologySystemId system}) =>
      NumerologyYearPeriod(
        year: year,
        personalYear: ((year % 9) + 1),
        months: List<int>.generate(12, (i) => (i % 9) + 1),
        sourceId: 'fixture',
        version: '1',
      );
}

void main() {
  test('selected year produces all twelve periods and five-year timeline is contiguous', () {
    final year = _Provider().buildYear(year: 2027, system: NumerologySystemId.pythagorean);
    expect(year.months, hasLength(12));
    final timeline = NumerologyTimelineAssembler.buildFiveYears(
      startYear: 2027,
      system: NumerologySystemId.pythagorean,
      provider: _Provider(),
    );
    expect(timeline.years.map((e) => e.year), [2027, 2028, 2029, 2030, 2031]);
  });

  test('different numerology systems remain explicit workspace choices', () {
    const p = NumerologyWorkspacePreferences(defaultSystem: NumerologySystemId.chaldean);
    expect(p.defaultSystem, NumerologySystemId.chaldean);
  });

  test('two distinct numerology analyses can be compared', () {
    final c = NumerologyPairComparison(
      leftAnalysisId: 'a1',
      rightAnalysisId: 'a2',
      system: NumerologySystemId.pythagorean,
    );
    expect(c.leftAnalysisId, isNot(c.rightAnalysisId));
    expect(
      () => NumerologyPairComparison(leftAnalysisId: 'a1', rightAnalysisId: 'a1', system: NumerologySystemId.pythagorean),
      throwsArgumentError,
    );
  });

  test('business brand and person analysis kinds are separate and name changes are comparable', () {
    final oldA = SavedNumerologyAnalysis(
      id: 'old', subjectId: 's1', kind: NumerologyAnalysisKind.brandName, inputName: 'Old Brand',
      system: NumerologySystemId.pythagorean, resultId: 'r1', createdAtUtc: DateTime.utc(2026, 1, 1),
    );
    final newA = SavedNumerologyAnalysis(
      id: 'new', subjectId: 's1', kind: NumerologyAnalysisKind.brandName, inputName: 'New Brand',
      system: NumerologySystemId.pythagorean, resultId: 'r2', createdAtUtc: DateTime.utc(2026, 2, 1),
    );
    final comparison = NameAnalysisComparison(previous: oldA, current: newA);
    expect(comparison.previous.inputName, 'Old Brand');
  });

  test('spiritual session preserves client spread card order positions and professional interpretation', () {
    final s = SpiritualConsultationSession(
      id: 'session-1',
      clientId: 'client-1',
      method: SpiritualSessionMethod.tarot,
      spreadId: 'three-card',
      cards: [
        SpiritualCardRecord(cardId: 'c1', positionId: 'past', order: 0),
        SpiritualCardRecord(cardId: 'c2', positionId: 'present', order: 1),
        SpiritualCardRecord(cardId: 'c3', positionId: 'future', order: 2),
      ],
      professionalInterpretation: 'Reflective professional note',
      occurredAtUtc: DateTime.utc(2026, 9, 8),
      disclosurePolicyId: 'symbolic-not-scientific-v1',
    );
    expect(s.cards.map((c) => c.positionId), ['past', 'present', 'future']);
    expect(s.disclosurePolicyId, isNotEmpty);
  });

  test('previous spreads can be retrieved and compared for same client', () {
    SpiritualConsultationSession make(String id, int day) => SpiritualConsultationSession(
      id: id,
      clientId: 'client-1',
      method: SpiritualSessionMethod.tarot,
      spreadId: 'single-card',
      cards: [SpiritualCardRecord(cardId: 'card-$id', positionId: 'focus', order: 0)],
      professionalInterpretation: 'note $id',
      occurredAtUtc: DateTime.utc(2026, 9, day),
      disclosurePolicyId: 'symbolic-v1',
    );
    final history = SpiritualSessionHistory(sessions: [make('a', 1), make('b', 2)]);
    expect(history.forClient('client-1'), hasLength(2));
    expect(history.comparable(clientId: 'client-1', spreadId: 'single-card'), hasLength(2));
  });
}
