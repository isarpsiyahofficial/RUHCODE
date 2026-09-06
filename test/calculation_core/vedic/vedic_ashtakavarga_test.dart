import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/ephemeris.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_ashtakavarga.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_engine.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_rashi_chart.dart';

VedicRashiPlacement _placement(AstroBody body, int rashi) => VedicRashiPlacement(
      placement: VedicPlacement(
        body: body,
        siderealLongitudeDegrees: rashi * 30.0 + 1.0,
        longitudeSpeedDegreesPerDay: 1.0,
      ),
      rashiIndex: rashi,
      degreesWithinRashi: 1.0,
      wholeSignHouse: rashi + 1,
    );

VedicRashiChart _chart() => VedicRashiChart(
      jdTt: 2460000.5,
      ephemerisSourceId: 'fixture-ephemeris',
      ephemerisDataVersion: '1',
      ayanamshaId: 'fixture-ayanamsha',
      ayanamshaDataVersion: '1',
      lagnaRashiIndex: 0,
      placements: [
        _placement(AstroBody.sun, 0),
        _placement(AstroBody.moon, 3),
      ],
    );

void main() {
  test('evaluates versioned Bhinna bindus and Sarva totals deterministically', () {
    final rules = AshtakavargaRuleSet(
      id: 'fixture',
      version: '1',
      sourceId: 'test-only',
      contributors: const [
        AshtakavargaContributor.graha('sun', AstroBody.sun),
        AshtakavargaContributor.lagna('lagna'),
      ],
      rules: [
        AshtakavargaRule(
          subject: AstroBody.sun,
          contributorId: 'sun',
          favorableRelativeHouses: const {1, 2},
        ),
        AshtakavargaRule(
          subject: AstroBody.sun,
          contributorId: 'lagna',
          favorableRelativeHouses: const {1},
        ),
      ],
    );

    final result = VedicAshtakavargaEngine.evaluate(chart: _chart(), ruleSet: rules);
    expect(result.bhinnaBindusBySubject[AstroBody.sun]![0], 2);
    expect(result.bhinnaBindusBySubject[AstroBody.sun]![1], 1);
    expect(result.sarvaBindusByRashi[0], 2);
    expect(result.sarvaBindusByRashi[1], 1);
    expect(result.ruleSetSourceId, 'test-only');
  });

  test('fails closed when a required Graha contributor is missing', () {
    final rules = AshtakavargaRuleSet(
      id: 'fixture',
      version: '1',
      sourceId: 'test-only',
      contributors: const [
        AshtakavargaContributor.graha('mars', AstroBody.mars),
      ],
      rules: [
        AshtakavargaRule(
          subject: AstroBody.sun,
          contributorId: 'mars',
          favorableRelativeHouses: const {1},
        ),
      ],
    );
    expect(
      () => VedicAshtakavargaEngine.evaluate(chart: _chart(), ruleSet: rules),
      throwsStateError,
    );
  });

  test('rejects duplicate subject/contributor rule bindings', () {
    expect(
      () => AshtakavargaRuleSet(
        id: 'fixture',
        version: '1',
        sourceId: 'test-only',
        contributors: const [
          AshtakavargaContributor.lagna('lagna'),
        ],
        rules: [
          AshtakavargaRule(
            subject: AstroBody.sun,
            contributorId: 'lagna',
            favorableRelativeHouses: const {1},
          ),
          AshtakavargaRule(
            subject: AstroBody.sun,
            contributorId: 'lagna',
            favorableRelativeHouses: const {2},
          ),
        ],
      ),
      throwsStateError,
    );
  });
}
