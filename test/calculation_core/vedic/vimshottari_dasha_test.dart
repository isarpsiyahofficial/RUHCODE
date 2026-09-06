import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/vedic/vedic_nakshatra.dart';
import 'package:ruh_code/src/calculation_core/vedic/vimshottari_dasha.dart';

VedicNakshatraPosition _birth({
  int nakshatraIndex = 0,
  double degreesIntoNakshatra = 0,
}) {
  return VedicNakshatraPosition(
    jdTt: 2451545.0,
    ephemerisSourceId: 'fixture',
    ephemerisDataVersion: 'v1',
    ayanamshaId: 'lahiri-chitrapaksha',
    ayanamshaDataVersion: 'fixture-v1',
    siderealMoonLongitudeDegrees:
        nakshatraIndex * VedicNakshatra.nakshatraSpanDegrees +
            degreesIntoNakshatra,
    nakshatraIndex: nakshatraIndex,
    nakshatraId: canonicalNakshatraIds[nakshatraIndex],
    pada: 1,
    degreesIntoNakshatra: degreesIntoNakshatra,
  );
}

void main() {
  test('RC-0105 canonical Vimshottari lords sum to 120 years', () {
    expect(
      canonicalVimshottariOrder,
      const <VimshottariLord>[
        VimshottariLord.ketu,
        VimshottariLord.venus,
        VimshottariLord.sun,
        VimshottariLord.moon,
        VimshottariLord.mars,
        VimshottariLord.rahu,
        VimshottariLord.jupiter,
        VimshottariLord.saturn,
        VimshottariLord.mercury,
      ],
    );
    expect(vimshottariYears.values.reduce((a, b) => a + b), 120);
  });

  test('RC-0105 birth Nakshatra selects starting Mahadasha lord', () {
    expect(
      VimshottariDasha.fromNakshatra(_birth(nakshatraIndex: 0))
          .mahadashas
          .first
          .lords
          .single,
      VimshottariLord.ketu,
    );
    expect(
      VimshottariDasha.fromNakshatra(_birth(nakshatraIndex: 1))
          .mahadashas
          .first
          .lords
          .single,
      VimshottariLord.venus,
    );
    expect(
      VimshottariDasha.fromNakshatra(_birth(nakshatraIndex: 9))
          .mahadashas
          .first
          .lords
          .single,
      VimshottariLord.ketu,
    );
  });

  test('RC-0106 Mahadasha balance reflects elapsed birth Nakshatra fraction', () {
    final half = VedicNakshatra.nakshatraSpanDegrees / 2;
    final timeline = VimshottariDasha.fromNakshatra(
      _birth(degreesIntoNakshatra: half),
    );
    final ketu = timeline.mahadashas.first;
    expect(
      timeline.birthJdTt - ketu.startJdTt,
      closeTo(3.5 * VimshottariDasha.daysPerDashaYear, 1e-7),
    );
    expect(
      ketu.endJdTt - timeline.birthJdTt,
      closeTo(3.5 * VimshottariDasha.daysPerDashaYear, 1e-7),
    );
  });

  test('RC-0107 Antardashas partition the Mahadasha exactly', () {
    final major = VimshottariDasha.fromNakshatra(_birth()).mahadashas.first;
    final children = VimshottariDasha.antardashas(major);
    expect(children, hasLength(9));
    expect(children.first.lords, const [VimshottariLord.ketu, VimshottariLord.ketu]);
    expect(children.last.endJdTt, major.endJdTt);
    expect(
      children.first.endJdTt - children.first.startJdTt,
      closeTo(
        (major.endJdTt - major.startJdTt) * 7 / 120,
        1e-7,
      ),
    );
  });

  test('RC-0108 Pratyantardashas recursively partition Antardasha', () {
    final major = VimshottariDasha.fromNakshatra(_birth()).mahadashas.first;
    final antar = VimshottariDasha.antardashas(major).first;
    final children = VimshottariDasha.pratyantardashas(antar);
    expect(children, hasLength(9));
    expect(
      children.first.lords,
      const [
        VimshottariLord.ketu,
        VimshottariLord.ketu,
        VimshottariLord.ketu,
      ],
    );
    expect(children.last.endJdTt, antar.endJdTt);
  });

  test('RC-0109 current period resolves exactly one period per requested level', () {
    final timeline = VimshottariDasha.fromNakshatra(_birth());
    final current = VimshottariDasha.currentPeriods(
      timeline,
      timeline.birthJdTt,
    );
    expect(current, hasLength(3));
    expect(current.every((period) => period.contains(timeline.birthJdTt)), isTrue);
  });

  test('RC-0110 ranges are half-open and expose exact start/end TT', () {
    final timeline = VimshottariDasha.fromNakshatra(_birth());
    final first = timeline.mahadashas.first;
    final second = timeline.mahadashas[1];
    expect(first.contains(first.startJdTt), isTrue);
    expect(first.contains(first.endJdTt), isFalse);
    expect(second.contains(first.endJdTt), isTrue);
    expect(first.endJdTt, second.startJdTt);
  });

  test('RC-0105-RC-0110 fail closed for invalid provenance and query TT', () {
    final invalid = VedicNakshatraPosition(
      jdTt: 2451545,
      ephemerisSourceId: '',
      ephemerisDataVersion: 'v1',
      ayanamshaId: 'lahiri-chitrapaksha',
      ayanamshaDataVersion: 'v1',
      siderealMoonLongitudeDegrees: 0,
      nakshatraIndex: 0,
      nakshatraId: 'ashwini',
      pada: 1,
      degreesIntoNakshatra: 0,
    );
    expect(() => VimshottariDasha.fromNakshatra(invalid), throwsStateError);
    final timeline = VimshottariDasha.fromNakshatra(_birth());
    expect(
      () => VimshottariDasha.currentPeriods(timeline, double.nan),
      throwsArgumentError,
    );
    expect(
      () => VimshottariDasha.currentPeriods(
        timeline,
        timeline.mahadashas.last.endJdTt,
      ),
      throwsStateError,
    );
  });
}
