import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/calculation_cache_policy.dart';

CalculationCacheContext context({
  String timezone = 'Europe/Istanbul',
  String day = '2026-09-09',
  String hour = '2026-09-09T08:00+03:00',
  String natalLocation = 'TR-ISTANBUL',
  String? currentLocation = 'TR-ANTALYA',
  String? solarReturnLocation = 'TR-ANTALYA',
}) =>
    CalculationCacheContext(
      calculationTimezoneId: timezone,
      localDayId: day,
      planetaryHourWindowId: hour,
      natalLocationId: natalLocation,
      currentLocationId: currentLocation,
      solarReturnLocationId: solarReturnLocation,
    );

CalculationCacheKey key({
  String subjectId = 'client-a',
  String fingerprint = 'birth=1990-01-01T12:00|loc=TR-ISTANBUL|house=placidus',
  String engineVersion = 'western-7',
  CalculationCacheKind kind = CalculationCacheKind.natal,
}) =>
    CalculationCacheKey(
      subjectId: subjectId,
      inputFingerprint: fingerprint,
      engineVersion: engineVersion,
      kind: kind,
    );

void main() {
  group('RC-1222 through RC-1236 calculation cache', () {
    test('same natal chart is reused instead of recomputed on every screen open', () {
      final store = InMemoryCalculationCacheStore<String>();
      final coordinator = CalculationCacheCoordinator<String>(store: store);
      var computes = 0;

      String compute() {
        computes++;
        return 'natal-result';
      }

      final first = coordinator.getOrCompute(
        key: key(),
        context: context(),
        manifestOverrides: CalculationManifestOverrides(const {}),
        generatedAtUtc: DateTime.utc(2026, 9, 9, 5),
        computeFromSource: compute,
      );
      final second = coordinator.getOrCompute(
        key: key(),
        context: context(currentLocation: 'US-NYC', timezone: 'America/New_York'),
        manifestOverrides: CalculationManifestOverrides(const {}),
        generatedAtUtc: DateTime.utc(2026, 9, 9, 6),
        computeFromSource: compute,
      );

      expect(first, 'natal-result');
      expect(second, 'natal-result');
      expect(computes, 1, reason: 'natal cache must survive travel/current timezone changes');
    });

    test('cache identity includes canonical input and engineVersion', () {
      expect(key().stableId, contains('western-7'));
      expect(key().stableId, contains('birth=1990-01-01T12:00'));
      expect(key(engineVersion: 'western-8').stableId, isNot(key().stableId));
      expect(key(fingerprint: 'birth=1990-01-01T13:00').stableId, isNot(key().stableId));
    });

    test('engine version change invalidates old cache automatically', () {
      final store = InMemoryCalculationCacheStore<String>();
      final coordinator = CalculationCacheCoordinator<String>(store: store);
      var computes = 0;

      String run(CalculationCacheKey cacheKey) => coordinator.getOrCompute(
            key: cacheKey,
            context: context(),
            manifestOverrides: CalculationManifestOverrides(const {}),
            generatedAtUtc: DateTime.utc(2026, 9, 9, 5),
            computeFromSource: () => 'result-${++computes}',
          );

      expect(run(key(engineVersion: 'western-7')), 'result-1');
      expect(run(key(engineVersion: 'western-8')), 'result-2');
      expect(computes, 2);
    });

    test('wrong-client cache can never be shown', () {
      final store = InMemoryCalculationCacheStore<String>();
      final coordinator = CalculationCacheCoordinator<String>(store: store);
      var computes = 0;

      final a = coordinator.getOrCompute(
        key: key(subjectId: 'client-a'),
        context: context(),
        manifestOverrides: CalculationManifestOverrides(const {}),
        generatedAtUtc: DateTime.utc(2026, 9, 9, 5),
        computeFromSource: () => 'client-a-${++computes}',
      );
      final b = coordinator.getOrCompute(
        key: key(subjectId: 'client-b'),
        context: context(),
        manifestOverrides: CalculationManifestOverrides(const {}),
        generatedAtUtc: DateTime.utc(2026, 9, 9, 5),
        computeFromSource: () => 'client-b-${++computes}',
      );

      expect(a, 'client-a-1');
      expect(b, 'client-b-2');
    });

    test('cache is derivative and deletion deterministically rebuilds from source', () {
      final store = InMemoryCalculationCacheStore<String>();
      final coordinator = CalculationCacheCoordinator<String>(store: store);
      var computes = 0;
      final cacheKey = key();

      String calculate() => coordinator.getOrCompute(
            key: cacheKey,
            context: context(),
            manifestOverrides: CalculationManifestOverrides(const {}),
            generatedAtUtc: DateTime.utc(2026, 9, 9, 5),
            computeFromSource: () {
              computes++;
              return 'deterministic-result';
            },
          );

      expect(calculate(), 'deterministic-result');
      store.remove(cacheKey.stableId);
      expect(calculate(), 'deterministic-result');
      expect(computes, 2, reason: 'cache removal must rebuild rather than lose source data');
    });

    test('daily cache expires on local day or timezone change', () {
      const policy = CalculationCachePolicy();
      final cacheKey = key(kind: CalculationCacheKind.daily);
      final record = CalculationCacheRecord<String>(
        key: cacheKey,
        value: 'today',
        generatedAtUtc: DateTime.utc(2026, 9, 9, 5),
        context: context(),
        manifestOverrides: CalculationManifestOverrides(const {}),
      );

      expect(policy.isReusable(record: record, expectedKey: cacheKey, currentContext: context()), isTrue);
      expect(
        policy.isReusable(
          record: record,
          expectedKey: cacheKey,
          currentContext: context(day: '2026-09-10'),
        ),
        isFalse,
        reason: 'today screen must roll over after local midnight',
      );
      expect(
        policy.isReusable(
          record: record,
          expectedKey: cacheKey,
          currentContext: context(timezone: 'America/New_York'),
        ),
        isFalse,
        reason: 'daily data must be reevaluated when calculation timezone changes',
      );
    });

    test('planetary-hour cache expires when hour window changes', () {
      const policy = CalculationCachePolicy();
      final cacheKey = key(kind: CalculationCacheKind.planetaryHour);
      final record = CalculationCacheRecord<String>(
        key: cacheKey,
        value: 'hour-1',
        generatedAtUtc: DateTime.utc(2026, 9, 9, 5),
        context: context(),
        manifestOverrides: CalculationManifestOverrides(const {}),
      );

      expect(
        policy.isReusable(
          record: record,
          expectedKey: cacheKey,
          currentContext: context(hour: '2026-09-09T09:00+03:00'),
        ),
        isFalse,
      );
    });

    test('transit current location is separate from natal birthplace', () {
      const policy = CalculationCachePolicy();
      final cacheKey = key(kind: CalculationCacheKind.transit);
      final record = CalculationCacheRecord<String>(
        key: cacheKey,
        value: 'transit',
        generatedAtUtc: DateTime.utc(2026, 9, 9, 5),
        context: context(currentLocation: 'TR-ANTALYA'),
        manifestOverrides: CalculationManifestOverrides(const {}),
      );

      expect(
        policy.isReusable(
          record: record,
          expectedKey: cacheKey,
          currentContext: context(currentLocation: 'TR-ANKARA'),
        ),
        isFalse,
      );
      expect(record.context.natalLocationId, 'TR-ISTANBUL');
    });

    test('solar return technique location must be explicit', () {
      final invalid = context(solarReturnLocation: null);
      expect(
        () => invalid.validateFor(CalculationCacheKind.solarReturn),
        throwsArgumentError,
      );
    });

    test('non-default user settings are carried into Calculation Manifest overrides', () {
      final overrides = CalculationManifestOverrides({
        'houseSystem': 'whole_sign',
        'orbPreset': 'custom-professional',
      });
      expect(overrides.hasOverrides, isTrue);
      expect(overrides.values['houseSystem'], 'whole_sign');
      expect(overrides.values['orbPreset'], 'custom-professional');
    });
  });
}
