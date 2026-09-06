import 'vedic_nakshatra.dart';

enum VimshottariLord {
  ketu,
  venus,
  sun,
  moon,
  mars,
  rahu,
  jupiter,
  saturn,
  mercury,
}

const List<VimshottariLord> canonicalVimshottariOrder = <VimshottariLord>[
  VimshottariLord.ketu,
  VimshottariLord.venus,
  VimshottariLord.sun,
  VimshottariLord.moon,
  VimshottariLord.mars,
  VimshottariLord.rahu,
  VimshottariLord.jupiter,
  VimshottariLord.saturn,
  VimshottariLord.mercury,
];

const Map<VimshottariLord, double> vimshottariYears =
    <VimshottariLord, double>{
  VimshottariLord.ketu: 7,
  VimshottariLord.venus: 20,
  VimshottariLord.sun: 6,
  VimshottariLord.moon: 10,
  VimshottariLord.mars: 7,
  VimshottariLord.rahu: 18,
  VimshottariLord.jupiter: 16,
  VimshottariLord.saturn: 19,
  VimshottariLord.mercury: 17,
};

final class VimshottariPeriod {
  const VimshottariPeriod({
    required this.lords,
    required this.startJdTt,
    required this.endJdTt,
  });

  /// One item for Mahadasha, two for Antardasha, three for Pratyantardasha.
  final List<VimshottariLord> lords;
  final double startJdTt;
  final double endJdTt;

  bool contains(double jdTt) => jdTt >= startJdTt && jdTt < endJdTt;
}

final class VimshottariTimeline {
  VimshottariTimeline({
    required this.birthJdTt,
    required this.nakshatraIndex,
    required this.degreesIntoNakshatra,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
    required List<VimshottariPeriod> mahadashas,
  }) : mahadashas = List<VimshottariPeriod>.unmodifiable(mahadashas);

  final double birthJdTt;
  final int nakshatraIndex;
  final double degreesIntoNakshatra;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
  final List<VimshottariPeriod> mahadashas;
}

abstract final class VimshottariDasha {
  static const double cycleYears = 120;
  static const double daysPerDashaYear = 365.25;

  /// RC-0105/0106: builds the canonical Vimshottari Mahadasha timeline from
  /// the sidereal Moon Nakshatra at birth. The elapsed part of the birth
  /// Nakshatra is applied to the first Mahadasha, so that period can start
  /// before birth and its remaining balance is exact for the chosen 365.25
  /// day Dasha-year convention.
  static VimshottariTimeline fromNakshatra(
    VedicNakshatraPosition birthNakshatra,
  ) {
    _validateBirthNakshatra(birthNakshatra);

    final startIndex = birthNakshatra.nakshatraIndex % 9;
    final firstLord = canonicalVimshottariOrder[startIndex];
    final firstYears = vimshottariYears[firstLord]!;
    final elapsedFraction = birthNakshatra.degreesIntoNakshatra /
        VedicNakshatra.nakshatraSpanDegrees;
    final firstStart = birthNakshatra.jdTt -
        (firstYears * elapsedFraction * daysPerDashaYear);

    final periods = <VimshottariPeriod>[];
    var cursor = firstStart;
    for (var offset = 0; offset < canonicalVimshottariOrder.length; offset++) {
      final lord = canonicalVimshottariOrder[
          (startIndex + offset) % canonicalVimshottariOrder.length];
      final end = cursor + vimshottariYears[lord]! * daysPerDashaYear;
      periods.add(
        VimshottariPeriod(
          lords: List<VimshottariLord>.unmodifiable(<VimshottariLord>[lord]),
          startJdTt: cursor,
          endJdTt: end,
        ),
      );
      cursor = end;
    }

    return VimshottariTimeline(
      birthJdTt: birthNakshatra.jdTt,
      nakshatraIndex: birthNakshatra.nakshatraIndex,
      degreesIntoNakshatra: birthNakshatra.degreesIntoNakshatra,
      ephemerisSourceId: birthNakshatra.ephemerisSourceId,
      ephemerisDataVersion: birthNakshatra.ephemerisDataVersion,
      ayanamshaId: birthNakshatra.ayanamshaId,
      ayanamshaDataVersion: birthNakshatra.ayanamshaDataVersion,
      mahadashas: periods,
    );
  }

  /// RC-0107: returns all nine Antardashas within a Mahadasha. The first
  /// sub-period is ruled by the parent Mahadasha lord, then the canonical
  /// nine-lord order continues cyclically. Durations are parent duration
  /// multiplied by the sub-lord Vimshottari years / 120.
  static List<VimshottariPeriod> antardashas(VimshottariPeriod mahadasha) {
    if (mahadasha.lords.length != 1) {
      throw ArgumentError.value(
        mahadasha.lords,
        'mahadasha',
        'Antardasha expansion requires one parent lord.',
      );
    }
    return _children(mahadasha);
  }

  /// RC-0108: optional third-level Pratyantardasha support using the same
  /// recursive 120-year proportional rule.
  static List<VimshottariPeriod> pratyantardashas(
    VimshottariPeriod antardasha,
  ) {
    if (antardasha.lords.length != 2) {
      throw ArgumentError.value(
        antardasha.lords,
        'antardasha',
        'Pratyantardasha expansion requires two parent lords.',
      );
    }
    return _children(antardasha);
  }

  /// RC-0109/0110: resolves the running Maha/Antar/Pratyantar periods at an
  /// explicit TT instant. Ranges are half-open [start, end), avoiding boundary
  /// ambiguity and preserving exact start/end JD(TT) values for rendering.
  static List<VimshottariPeriod> currentPeriods(
    VimshottariTimeline timeline,
    double queryJdTt, {
    bool includePratyantardasha = true,
  }) {
    if (!queryJdTt.isFinite) {
      throw ArgumentError.value(queryJdTt, 'queryJdTt', 'Finite TT is required.');
    }
    final maha = timeline.mahadashas.where((period) => period.contains(queryJdTt));
    if (maha.length != 1) {
      throw StateError('Requested TT is outside the generated Vimshottari cycle.');
    }
    final major = maha.single;
    final antar = antardashas(major).where((period) => period.contains(queryJdTt));
    if (antar.length != 1) {
      throw StateError('Antardasha partition failed to resolve exactly one period.');
    }
    final result = <VimshottariPeriod>[major, antar.single];
    if (includePratyantardasha) {
      final pratyantar = pratyantardashas(antar.single)
          .where((period) => period.contains(queryJdTt));
      if (pratyantar.length != 1) {
        throw StateError(
          'Pratyantardasha partition failed to resolve exactly one period.',
        );
      }
      result.add(pratyantar.single);
    }
    return List<VimshottariPeriod>.unmodifiable(result);
  }

  static List<VimshottariPeriod> _children(VimshottariPeriod parent) {
    if (!parent.startJdTt.isFinite ||
        !parent.endJdTt.isFinite ||
        parent.endJdTt <= parent.startJdTt ||
        parent.lords.isEmpty ||
        parent.lords.length >= 3) {
      throw StateError('Vimshottari parent period is invalid.');
    }

    final parentLord = parent.lords.last;
    final startIndex = canonicalVimshottariOrder.indexOf(parentLord);
    if (startIndex < 0) {
      throw StateError('Unknown Vimshottari parent lord.');
    }

    final parentDays = parent.endJdTt - parent.startJdTt;
    final children = <VimshottariPeriod>[];
    var cursor = parent.startJdTt;
    for (var offset = 0; offset < canonicalVimshottariOrder.length; offset++) {
      final lord = canonicalVimshottariOrder[
          (startIndex + offset) % canonicalVimshottariOrder.length];
      final isLast = offset == canonicalVimshottariOrder.length - 1;
      final end = isLast
          ? parent.endJdTt
          : cursor + parentDays * (vimshottariYears[lord]! / cycleYears);
      children.add(
        VimshottariPeriod(
          lords: List<VimshottariLord>.unmodifiable(<VimshottariLord>[
            ...parent.lords,
            lord,
          ]),
          startJdTt: cursor,
          endJdTt: end,
        ),
      );
      cursor = end;
    }
    return List<VimshottariPeriod>.unmodifiable(children);
  }

  static void _validateBirthNakshatra(VedicNakshatraPosition value) {
    if (!value.jdTt.isFinite ||
        value.ephemerisSourceId.trim().isEmpty ||
        value.ephemerisDataVersion.trim().isEmpty ||
        value.ayanamshaId.trim().isEmpty ||
        value.ayanamshaDataVersion.trim().isEmpty ||
        value.nakshatraIndex < 0 ||
        value.nakshatraIndex >= VedicNakshatra.nakshatraCount ||
        !value.degreesIntoNakshatra.isFinite ||
        value.degreesIntoNakshatra < 0 ||
        value.degreesIntoNakshatra >= VedicNakshatra.nakshatraSpanDegrees) {
      throw StateError('Vimshottari Dasha requires a valid birth Nakshatra with provenance.');
    }
  }
}
