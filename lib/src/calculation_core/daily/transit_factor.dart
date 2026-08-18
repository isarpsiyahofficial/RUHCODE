import '../ephemeris/ephemeris.dart';
import '../transits/transit_aspects.dart';
import 'daily_snapshot.dart';

final class TransitDailyFactor {
  const TransitDailyFactor({
    required this.engineVersion,
    required this.ephemeris,
    this.orbPolicy = const TransitAspectOrbPolicy(),
  });

  final String engineVersion;
  final EphemerisProvider ephemeris;
  final TransitAspectOrbPolicy orbPolicy;

  DailyFactorReference build({
    required double jdTt,
    required Iterable<NatalPoint> natalPoints,
    required Iterable<AstroBody> transitBodies,
  }) {
    if (engineVersion.trim().isEmpty) {
      throw StateError('Transit engine version is required.');
    }

    final matches = TransitAspectEngine(
      ephemeris,
      orbPolicy: orbPolicy,
    ).calculate(
      jdTt: jdTt,
      natalPoints: natalPoints,
      transitBodies: transitBodies,
    );

    final parts = <String>['transits', jdTt.toStringAsFixed(8)];
    for (final match in matches) {
      parts.add(<String>[
        match.transitBody.name,
        match.aspect.name,
        match.natalBody.name,
        match.orbDegrees.toStringAsFixed(6),
        match.sourceId,
        match.dataVersion,
      ].join(':'));
    }

    return DailyFactorReference(
      kind: DailyFactorKind.transit,
      sourceEngineId: 'western_transit_aspects',
      sourceEngineVersion: engineVersion,
      resultId: parts.join('|'),
    );
  }
}
