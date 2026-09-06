import 'vedic_engine.dart';

final class VedicVargaPlacement {
  const VedicVargaPlacement({
    required this.placement,
    required this.division,
    required this.divisionIndex,
    required this.vargaRashiIndex,
    required this.degreesWithinVargaRashi,
  });

  final VedicPlacement placement;
  final int division;
  final int divisionIndex;
  final int vargaRashiIndex;
  final double degreesWithinVargaRashi;
}

final class VedicVargaChart {
  VedicVargaChart({
    required this.jdTt,
    required this.ephemerisSourceId,
    required this.ephemerisDataVersion,
    required this.ayanamshaId,
    required this.ayanamshaDataVersion,
    required this.division,
    required List<VedicVargaPlacement> placements,
  }) : placements = List<VedicVargaPlacement>.unmodifiable(placements);

  final double jdTt;
  final String ephemerisSourceId;
  final String ephemerisDataVersion;
  final String ayanamshaId;
  final String ayanamshaDataVersion;
  final int division;
  final List<VedicVargaPlacement> placements;
}

/// Classical Parashari Varga core.
///
/// RC-0092: Navamsa D9
/// RC-0093: Hora D2
/// RC-0094: Drekkana D3
/// RC-0095: Chaturthamsa D4
abstract final class VedicVargaBuilder {
  static VedicVargaChart navamsaD9(VedicCalculationSnapshot snapshot) =>
      _build(snapshot: snapshot, division: 9, mapper: _navamsaRashi);

  static VedicVargaChart horaD2(VedicCalculationSnapshot snapshot) =>
      _build(snapshot: snapshot, division: 2, mapper: _horaRashi);

  static VedicVargaChart drekkanaD3(VedicCalculationSnapshot snapshot) =>
      _build(snapshot: snapshot, division: 3, mapper: _drekkanaRashi);

  static VedicVargaChart chaturthamsaD4(VedicCalculationSnapshot snapshot) =>
      _build(snapshot: snapshot, division: 4, mapper: _chaturthamsaRashi);

  static VedicVargaChart _build({
    required VedicCalculationSnapshot snapshot,
    required int division,
    required int Function(int rashiIndex, int divisionIndex) mapper,
  }) {
    _validateSnapshot(snapshot);
    final partSize = 30.0 / division;
    final placements = <VedicVargaPlacement>[];
    final seenBodies = <Object>{};

    for (final placement in snapshot.placements) {
      if (!seenBodies.add(placement.body)) {
        throw StateError('Varga chart contains duplicate Graha placements.');
      }
      final longitude = placement.siderealLongitudeDegrees;
      if (!longitude.isFinite || longitude < 0 || longitude >= 360) {
        throw StateError('Varga chart requires normalized sidereal longitudes.');
      }
      final rashiIndex = (longitude / 30.0).floor();
      final withinRashi = longitude - (rashiIndex * 30.0);
      var divisionIndex = (withinRashi / partSize).floor();
      if (divisionIndex >= division) divisionIndex = division - 1;
      final offset = withinRashi - (divisionIndex * partSize);
      final projectedDegrees = offset / partSize * 30.0;

      placements.add(
        VedicVargaPlacement(
          placement: placement,
          division: division,
          divisionIndex: divisionIndex,
          vargaRashiIndex: mapper(rashiIndex, divisionIndex),
          degreesWithinVargaRashi: projectedDegrees,
        ),
      );
    }
    placements.sort((a, b) => a.placement.body.index.compareTo(b.placement.body.index));

    return VedicVargaChart(
      jdTt: snapshot.jdTt,
      ephemerisSourceId: snapshot.ephemerisSourceId,
      ephemerisDataVersion: snapshot.ephemerisDataVersion,
      ayanamshaId: snapshot.ayanamshaId,
      ayanamshaDataVersion: snapshot.ayanamshaDataVersion,
      division: division,
      placements: placements,
    );
  }

  static int _navamsaRashi(int rashiIndex, int divisionIndex) {
    // Movable signs start from themselves, fixed signs from the ninth,
    // and dual signs from the fifth; subsequent Navamsas proceed zodiacally.
    final modality = rashiIndex % 3;
    final start = switch (modality) {
      0 => rashiIndex,
      1 => (rashiIndex + 8) % 12,
      _ => (rashiIndex + 4) % 12,
    };
    return (start + divisionIndex) % 12;
  }

  static int _horaRashi(int rashiIndex, int divisionIndex) {
    // Classical Hora: odd signs = Sun then Moon; even signs = Moon then Sun.
    // The Sun Hora is Leo (4), the Moon Hora is Cancer (3).
    final isOddSign = rashiIndex.isEven; // Aries is the first/odd sign.
    final sunHora = isOddSign ? divisionIndex == 0 : divisionIndex == 1;
    return sunHora ? 4 : 3;
  }

  static int _drekkanaRashi(int rashiIndex, int divisionIndex) {
    // Classical Parashari D3: first decan = sign itself, second = fifth sign,
    // third = ninth sign from the natal Rashi.
    const offsets = <int>[0, 4, 8];
    return (rashiIndex + offsets[divisionIndex]) % 12;
  }

  static int _chaturthamsaRashi(int rashiIndex, int divisionIndex) {
    // Classical Parashari D4: quarters map to the 1st, 4th, 7th and 10th
    // signs counted from the natal Rashi.
    const offsets = <int>[0, 3, 6, 9];
    return (rashiIndex + offsets[divisionIndex]) % 12;
  }

  static void _validateSnapshot(VedicCalculationSnapshot snapshot) {
    if (!snapshot.jdTt.isFinite ||
        snapshot.ephemerisSourceId.trim().isEmpty ||
        snapshot.ephemerisDataVersion.trim().isEmpty ||
        snapshot.ayanamshaId.trim().isEmpty ||
        snapshot.ayanamshaDataVersion.trim().isEmpty ||
        !snapshot.ayanamshaDegrees.isFinite) {
      throw StateError('Varga chart requires explicit Vedic provenance.');
    }
    if (snapshot.placements.isEmpty) {
      throw StateError('Varga chart requires at least one Graha placement.');
    }
  }
}
