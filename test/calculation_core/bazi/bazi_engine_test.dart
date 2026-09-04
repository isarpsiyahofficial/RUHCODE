import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/bazi/bazi_engine.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';

void main() {
  const engine = BaZiEngine();

  CalculationManifest manifest({
    String engineId = 'bazi',
    CalculationValidity validity = CalculationValidity.valid,
  }) => CalculationManifest(
        id: EntityId.parse('123e4567-e89b-42d3-a456-426614174002'),
        engineId: engineId,
        engineVersion: '1.0.0',
        algorithmVersion: 'four-pillars-v1',
        dataVersion: 'calendar-unbound',
        localDateTime: DateTime.utc(2024, 1, 1),
        utcDateTime: DateTime.utc(2024, 1, 1),
        location: const LocationRecord(
          label: 'Test', countryCode: 'CN', latitude: 39.9042,
          longitude: 116.4074, ianaTimeZoneId: 'Asia/Shanghai'),
        validity: validity,
      );

  const validPillar = BaZiPillarInput(stemIndex: 0, branchIndex: 0);

  test('uses a BaZi-specific CalculationEngine identity', () {
    expect(engine.engineId, 'bazi');
    expect(engine.engineId, isNot('chinese-astrology'));
    expect(engine.engineId, isNot('vedic-astrology'));
  });

  test('preserves four independently supplied validated pillars', () async {
    final result = await engine.calculate(BaZiInput(
      manifest: manifest(),
      year: const BaZiPillarInput(stemIndex: 0, branchIndex: 4),
      month: const BaZiPillarInput(stemIndex: 2, branchIndex: 2),
      day: const BaZiPillarInput(stemIndex: 5, branchIndex: 7),
      hour: const BaZiPillarInput(stemIndex: 8, branchIndex: 10),
    ));
    expect(result.value.year.branchIndex, 4);
    expect(result.value.month.stemIndex, 2);
    expect(result.value.day.branchIndex, 7);
    expect(result.value.hour.stemIndex, 8);
  });

  test('rejects foreign and invalid manifests', () async {
    await expectLater(engine.calculate(BaZiInput(
      manifest: manifest(engineId: 'chinese-astrology'),
      year: validPillar, month: validPillar, day: validPillar, hour: validPillar,
    )), throwsStateError);
    await expectLater(engine.calculate(BaZiInput(
      manifest: manifest(validity: CalculationValidity.error),
      year: validPillar, month: validPillar, day: validPillar, hour: validPillar,
    )), throwsStateError);
  });

  test('rejects invalid stem and branch indices', () async {
    await expectLater(engine.calculate(BaZiInput(
      manifest: manifest(),
      year: const BaZiPillarInput(stemIndex: 10, branchIndex: 0),
      month: validPillar, day: validPillar, hour: validPillar,
    )), throwsRangeError);
    await expectLater(engine.calculate(BaZiInput(
      manifest: manifest(),
      year: validPillar,
      month: const BaZiPillarInput(stemIndex: 0, branchIndex: 12),
      day: validPillar, hour: validPillar,
    )), throwsRangeError);
  });
}
