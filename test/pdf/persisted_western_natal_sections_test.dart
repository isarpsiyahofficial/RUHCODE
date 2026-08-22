import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/persisted_western_natal_sections.dart';
import 'package:ruh_code/src/pdf/persisted_western_natal_snapshot.dart';

void main() {
  test('projects placements houses and aspects from sealed snapshot only', () {
    final snapshot = _snapshot();
    final envelope = PersistedWesternNatalEnvelope.seal(snapshot);

    final sections = PersistedWesternNatalSectionAdapter.build(
      envelope: envelope,
      placementsTitle: 'Yerleşimler',
      housesTitle: 'Evler',
      aspectsTitle: 'Açılar',
      bodyHeader: 'Gezegen',
      signHeader: 'Burç',
      degreeHeader: 'Derece',
      houseHeader: 'Ev',
      motionHeader: 'Hareket',
      cuspHeader: 'Başlangıç',
      aspectHeader: 'Açı',
      separationHeader: 'Ayrım',
      orbHeader: 'Orb',
      bodyLabel: (id) => {'sun': 'Güneş', 'moon': 'Ay'}[id] ?? '',
      signLabel: (id) => {'aries': 'Koç', 'gemini': 'İkizler'}[id] ?? id,
      motionLabel: (id) => {'direct': 'Direkt'}[id] ?? '',
      aspectLabel: (id) => {'sextile': 'Sekstil'}[id] ?? '',
    );

    expect(sections.length, 3);
    expect(sections.every((section) => section.snapshotDigest == snapshot.sha256Hex), isTrue);
    expect(sections[0].rows[1], <String>['Ay', 'İkizler', '0.00°', '3', 'Direkt']);
    expect(sections[0].rows[2], <String>['Güneş', 'Koç', '0.00°', '1', 'Direkt']);
    expect(sections[1].rows.length, 13);
    expect(sections[1].rows[1], <String>['1', '0.00°', 'Koç']);
    expect(sections[2].rows[1], <String>['Güneş', 'Ay', 'Sekstil', '60.00°', '0.00°']);
  });

  test('missing localized label fails closed', () {
    final envelope = PersistedWesternNatalEnvelope.seal(_snapshot());
    expect(
      () => PersistedWesternNatalSectionAdapter.build(
        envelope: envelope,
        placementsTitle: 'Placements',
        housesTitle: 'Houses',
        aspectsTitle: 'Aspects',
        bodyHeader: 'Body',
        signHeader: 'Sign',
        degreeHeader: 'Degree',
        houseHeader: 'House',
        motionHeader: 'Motion',
        cuspHeader: 'Cusp',
        aspectHeader: 'Aspect',
        separationHeader: 'Separation',
        orbHeader: 'Orb',
        bodyLabel: (_) => '',
        signLabel: (id) => id,
        motionLabel: (id) => id,
        aspectLabel: (id) => id,
      ),
      throwsFormatException,
    );
  });
}

PersistedWesternNatalSnapshot _snapshot() {
  return PersistedWesternNatalSnapshot(
    engineVersion: 'western-engine-1',
    algorithmVersion: 'western-algorithm-1',
    dataVersion: 'ephemeris-test-1',
    ttJulianDay: 2447892.0,
    sourceId: 'fixture-source',
    requestedHouseSystem: 'wholeSign',
    effectiveHouseSystem: 'wholeSign',
    houseCuspsDeg: List<double>.generate(12, (index) => index * 30.0),
    placements: const <PersistedWesternNatalPlacement>[
      PersistedWesternNatalPlacement(
        body: 'sun',
        longitudeDeg: 0.0,
        houseNumber: 1,
        motion: 'direct',
      ),
      PersistedWesternNatalPlacement(
        body: 'moon',
        longitudeDeg: 60.0,
        houseNumber: 3,
        motion: 'direct',
      ),
    ],
    aspects: const <PersistedWesternNatalAspect>[
      PersistedWesternNatalAspect(
        bodyA: 'sun',
        bodyB: 'moon',
        type: 'sextile',
        exactAngleDeg: 60.0,
        separationDeg: 60.0,
        deltaFromExactDeg: 0.0,
        allowedOrbDeg: 6.0,
      ),
    ],
  );
}
