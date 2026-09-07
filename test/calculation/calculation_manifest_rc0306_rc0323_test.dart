import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation/calculation_manifest.dart';

void main() {
  CalculationManifest manifest() => CalculationManifest(
        id: 'm1', engineId: 'western', engineVersion: '2.3.1', zodiacFrame: ZodiacFrame.tropical,
        houseSystemId: 'placidus', ayanamshaId: null, nodeSystemId: 'true-node', timeZoneDatabaseVersion: '2026b',
        coordinate: GeoCoordinate(latitude: 36.89, longitude: 30.70), instantUtc: DateTime.utc(2026, 9, 7, 12),
        localDateTimeIso: '2026-09-07T15:00:00+03:00', timeZoneId: 'Europe/Istanbul',
        assumptions: const {'ephemeris':'swisseph-v1','deltaT':'provider-v1'},
      );

  test('manifest preserves engine/time/location/settings for reproducibility', () {
    final m=manifest(); final r=m.reproducibilityRecord();
    expect(r['engineVersion'],'2.3.1'); expect(r['timeZoneDatabaseVersion'],'2026b');
    expect(r['houseSystemId'],'placidus'); expect(r['nodeSystemId'],'true-node');
    expect((r['assumptions'] as Map)['ephemeris'],'swisseph-v1');
  });

  test('sidereal manifests require explicit ayanamsha', () {
    expect(() => CalculationManifest(id:'x',engineId:'v',engineVersion:'1',zodiacFrame:ZodiacFrame.sidereal,houseSystemId:'whole-sign',ayanamshaId:null,nodeSystemId:'mean-node',timeZoneDatabaseVersion:'2026b',coordinate:GeoCoordinate(latitude:0,longitude:0),instantUtc:DateTime.utc(2026),localDateTimeIso:'2026-01-01T00:00:00Z',timeZoneId:'UTC',assumptions:const{}), throwsArgumentError);
  });

  test('calculation and interpretation artifacts remain separate', () {
    final c=CalculationArtifact(id:'c1',manifest:manifest(),payloadDigest:'calc-digest');
    final i=InterpretationArtifact(id:'i1',calculationArtifactId:c.id,interpreterId:'editorial',interpreterVersion:'4',contentDigest:'text-digest');
    expect(i.calculationArtifactId,c.id); expect(i.contentDigest,isNot(c.payloadDigest));
  });

  test('Calculation QA must precede Interpretation QA and verdicts stay independent', () {
    const pending=QaRecord();
    expect(() => pending.recordInterpretation(QaVerdict.passed), throwsStateError);
    final calcFailed=pending.recordCalculation(QaVerdict.failed).recordInterpretation(QaVerdict.passed);
    expect(calcFailed.calculationPassed,isFalse); expect(calcFailed.interpretationPassed,isTrue); expect(calcFailed.fullyPassed,isFalse);
    final calcPassed=pending.recordCalculation(QaVerdict.passed).recordInterpretation(QaVerdict.failed);
    expect(calcPassed.calculationPassed,isTrue); expect(calcPassed.interpretationPassed,isFalse); expect(calcPassed.fullyPassed,isFalse);
  });
}
