import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/application/daily/daily_today_core.dart';

DailySourceEvidence e(DailySystemId system, String id) =>
    DailySourceEvidence(system: system, sourceId: id, version: '1');

DailyTodaySnapshot snapshot() => DailyTodaySnapshot(
  localDate: DateTime(2026, 9, 7),
  moonSign: DailySignal(value: 'moon:virgo', evidence: e(DailySystemId.astronomy, 'moon-sign')),
  moonPhase: DailySignal(value: 'waning-crescent', evidence: e(DailySystemId.astronomy, 'moon-phase')),
  currentPlanetaryHour: DailySignal(value: 'slot-10:venus', evidence: e(DailySystemId.planetaryHours, 'hours')),
  nextPlanetaryHour: DailySignal(value: 'slot-11:mercury', evidence: e(DailySystemId.planetaryHours, 'hours')),
  personalDay: DailySignal(value: 8, evidence: e(DailySystemId.numerology, 'personal-day')),
  personalTransits: [DailySignal(value: 'saturn-trine-moon', evidence: e(DailySystemId.western, 'transits'))],
  retrogrades: [DailySignal(value: 'saturn', evidence: e(DailySystemId.astronomy, 'retrogrades'))],
  astrologicalOutlook: DailySignal(value: 'structured-outlook', evidence: e(DailySystemId.western, 'outlook')),
);

void main() {
  test('RC-0187..0198 daily snapshot exposes required daily data', () {
    final s = snapshot();
    expect(s.localDate, DateTime(2026, 9, 7));
    expect(s.moonSign.value, 'moon:virgo');
    expect(s.moonPhase.value, 'waning-crescent');
    expect(s.currentPlanetaryHour.value, contains('slot-10'));
    expect(s.nextPlanetaryHour.value, contains('slot-11'));
    expect(s.personalDay?.value, 8);
    expect(s.personalTransits, isNotEmpty);
    expect(s.retrogrades, isNotEmpty);
    expect(s.astrologicalOutlook, isNotNull);
    expect(s.isPersonalized, isTrue);
  });

  test('RC-0199..0204 daily message is deterministic recipe-driven and provenance-aware', () {
    final s = snapshot();
    final recipe = DailyMessageRecipe(
      id: 'daily-western-v1', version: '1', sourceId: 'editorial-fixture',
      systems: {DailySystemId.western, DailySystemId.numerology},
      build: (x) => 'day-${x.personalDay!.value}:${x.personalTransits.first.value}',
    );
    final a = DailyMessageEngine.generate(s, recipe);
    final b = DailyMessageEngine.generate(s, recipe);
    expect(a.text, b.text);
    expect(a.systems, {DailySystemId.western, DailySystemId.numerology});
  });

  test('RC-0205/0206 Western and Vedic are not silently fused', () {
    expect(() => DailyMessageRecipe(
      id: 'bad', version: '1', sourceId: 'fixture',
      systems: {DailySystemId.western, DailySystemId.vedic},
      build: (_) => 'bad',
    ), throwsArgumentError);
  });

  test('RC-0207..0210 PRO and rewarded unlock have explicit finite scope', () {
    final now = DateTime.utc(2026, 9, 7, 7);
    final free = DailyAccessPolicy(pro: false);
    expect(free.canReadLocked(scope: 'daily-message:2026-09-07', nowUtc: now), isFalse);
    final rewarded = DailyAccessPolicy(pro: false, rewardedGrant: RewardedUnlockGrant(
      scope: 'daily-message:2026-09-07', expiresAtUtc: now.add(const Duration(hours: 2)),
    ));
    expect(rewarded.canReadLocked(scope: 'daily-message:2026-09-07', nowUtc: now), isTrue);
    expect(rewarded.canReadLocked(scope: 'daily-message:2026-09-08', nowUtc: now), isFalse);
    expect(rewarded.canReadLocked(scope: 'daily-message:2026-09-07', nowUtc: now.add(const Duration(hours: 3))), isFalse);
    expect(const DailyAccessPolicy(pro: true).canReadLocked(scope: 'x', nowUtc: now), isTrue);
  });

  test('RC-0211 rewarded prompts require user intent and are capped', () {
    const policy = DailyAdExperiencePolicy(maxRewardPromptsPerSession: 1);
    expect(policy.mayPrompt(promptsAlreadyShown: 0, userInitiated: false), isFalse);
    expect(policy.mayPrompt(promptsAlreadyShown: 0, userInitiated: true), isTrue);
    expect(policy.mayPrompt(promptsAlreadyShown: 1, userInitiated: true), isFalse);
  });
}
