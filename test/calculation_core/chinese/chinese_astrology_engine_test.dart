import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/chinese/chinese_astrology_engine.dart';
import 'package:ruh_code/src/domain/ids/entity_id.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';

void main() {
  const engine = ChineseAstrologyEngine();

  CalculationManifest manifest({
    String engineId = 'chinese-astrology',
    CalculationValidity validity = CalculationValidity.valid,
  }) {
    return CalculationManifest(
      id: EntityId.parse('123e4567-e89b-42d3-a456-426614174001'),
      engineId: engineId,
      engineVersion: '1.0.0',
      algorithmVersion: 'sexagenary-year-v1',
      dataVersion: 'calendar-unbound',
      localDateTime: DateTime.utc(2024, 2, 10),
      utcDateTime: DateTime.utc(2024, 2, 10),
      location: const LocationRecord(
        label: 'Test',
        countryCode: 'CN',
        latitude: 39.9042,
        longitude: 116.4074,
        ianaTimeZoneId: 'Asia/Shanghai',
      ),
      validity: validity,
    );
  }

  test('is a separate CalculationEngine with Chinese engine identity', () {
    expect(engine.engineId, 'chinese-astrology');
    expect(engine.engineId, isNot('western-astrology'));
    expect(engine.engineId, isNot('vedic-astrology'));
    expect(engine.engineId, isNot('bazi'));
  });

  test('maps the 1984 Jia-Zi reference year to cycle index zero', () async {
    final result = await engine.calculate(
      ChineseAstrologyInput(manifest: manifest(), cycleYear: 1984),
    );
    expect(result.value.sexagenaryIndex, 0);
    expect(result.value.heavenlyStemIndex, 0);
    expect(result.value.earthlyBranchIndex, 0);
  });

  test('maps 2024 deterministically within the 60-year cycle', () async {
    final result = await engine.calculate(
      ChineseAstrologyInput(manifest: manifest(), cycleYear: 2024),
    );
    expect(result.value.sexagenaryIndex, 40);
    expect(result.value.heavenlyStemIndex, 0);
    expect(result.value.earthlyBranchIndex, 4);
  });

  test('normalizes pre-reference years with floor-mod semantics', () async {
    final result = await engine.calculate(
      ChineseAstrologyInput(manifest: manifest(), cycleYear: 1983),
    );
    expect(result.value.sexagenaryIndex, 59);
    expect(result.value.heavenlyStemIndex, 9);
    expect(result.value.earthlyBranchIndex, 11);
  });

  test('rejects foreign engine and invalid calculation manifests', () async {
    await expectLater(
      engine.calculate(
        ChineseAstrologyInput(
          manifest: manifest(engineId: 'bazi'),
          cycleYear: 2024,
        ),
      ),
      throwsStateError,
    );
    await expectLater(
      engine.calculate(
        ChineseAstrologyInput(
          manifest: manifest(validity: CalculationValidity.invalid),
          cycleYear: 2024,
        ),
      ),
      throwsStateError,
    );
  });

  test('rejects cycle years outside the explicitly supported range', () async {
    await expectLater(
      engine.calculate(
        ChineseAstrologyInput(manifest: manifest(), cycleYear: 10000),
      ),
      throwsRangeError,
    );
  });
}
