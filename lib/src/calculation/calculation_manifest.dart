/// Reproducible calculation manifest and independent QA lifecycle.
enum ZodiacFrame { tropical, sidereal }
enum QaVerdict { pending, passed, failed }

final class GeoCoordinate {
  GeoCoordinate({required this.latitude, required this.longitude}) {
    if (latitude < -90 || latitude > 90) throw ArgumentError('latitude must be -90..90');
    if (longitude < -180 || longitude > 180) throw ArgumentError('longitude must be -180..180');
  }
  final double latitude;
  final double longitude;
}

final class CalculationManifest {
  CalculationManifest({
    required this.id,
    required this.engineId,
    required this.engineVersion,
    required this.zodiacFrame,
    required this.houseSystemId,
    required this.ayanamshaId,
    required this.nodeSystemId,
    required this.timeZoneDatabaseVersion,
    required this.coordinate,
    required this.instantUtc,
    required this.localDateTimeIso,
    required this.timeZoneId,
    required Map<String, String> assumptions,
  }) : assumptions = Map.unmodifiable(assumptions) {
    for (final entry in <String, String>{
      'id': id,
      'engineId': engineId,
      'engineVersion': engineVersion,
      'houseSystemId': houseSystemId,
      'nodeSystemId': nodeSystemId,
      'timeZoneDatabaseVersion': timeZoneDatabaseVersion,
      'localDateTimeIso': localDateTimeIso,
      'timeZoneId': timeZoneId,
    }.entries) {
      _text(entry.value, entry.key);
    }
    if (!instantUtc.isUtc) throw ArgumentError('instantUtc must be UTC');
    if (zodiacFrame == ZodiacFrame.sidereal) _text(ayanamshaId ?? '', 'ayanamshaId');
    for (final entry in this.assumptions.entries) {
      _text(entry.key, 'assumption key');
      _text(entry.value, 'assumption value');
    }
  }

  final String id;
  final String engineId;
  final String engineVersion;
  final ZodiacFrame zodiacFrame;
  final String houseSystemId;
  final String? ayanamshaId;
  final String nodeSystemId;
  final String timeZoneDatabaseVersion;
  final GeoCoordinate coordinate;
  final DateTime instantUtc;
  final String localDateTimeIso;
  final String timeZoneId;
  final Map<String, String> assumptions;

  Map<String, Object?> reproducibilityRecord() => Map.unmodifiable({
        'engineId': engineId,
        'engineVersion': engineVersion,
        'zodiacFrame': zodiacFrame.name,
        'houseSystemId': houseSystemId,
        'ayanamshaId': ayanamshaId,
        'nodeSystemId': nodeSystemId,
        'timeZoneDatabaseVersion': timeZoneDatabaseVersion,
        'latitude': coordinate.latitude,
        'longitude': coordinate.longitude,
        'instantUtc': instantUtc.toIso8601String(),
        'localDateTimeIso': localDateTimeIso,
        'timeZoneId': timeZoneId,
        'assumptions': assumptions,
      });
}

final class CalculationArtifact {
  CalculationArtifact({
    required this.id,
    required this.manifest,
    required this.payloadDigest,
  }) {
    _text(id, 'artifact id');
    _text(payloadDigest, 'payloadDigest');
  }
  final String id;
  final CalculationManifest manifest;
  final String payloadDigest;
}

final class InterpretationArtifact {
  InterpretationArtifact({
    required this.id,
    required this.calculationArtifactId,
    required this.interpreterId,
    required this.interpreterVersion,
    required this.contentDigest,
  }) {
    for (final entry in <String, String>{
      'id': id,
      'calculationArtifactId': calculationArtifactId,
      'interpreterId': interpreterId,
      'interpreterVersion': interpreterVersion,
      'contentDigest': contentDigest,
    }.entries) {
      _text(entry.value, entry.key);
    }
  }
  final String id;
  final String calculationArtifactId;
  final String interpreterId;
  final String interpreterVersion;
  final String contentDigest;
}

final class QaRecord {
  const QaRecord({
    this.calculation = QaVerdict.pending,
    this.interpretation = QaVerdict.pending,
  });

  final QaVerdict calculation;
  final QaVerdict interpretation;

  QaRecord recordCalculation(QaVerdict verdict) {
    if (verdict == QaVerdict.pending) throw ArgumentError('calculation verdict must be final');
    return QaRecord(calculation: verdict, interpretation: interpretation);
  }

  QaRecord recordInterpretation(QaVerdict verdict) {
    if (calculation == QaVerdict.pending) {
      throw StateError('Calculation QA must run before Interpretation QA');
    }
    if (verdict == QaVerdict.pending) throw ArgumentError('interpretation verdict must be final');
    return QaRecord(calculation: calculation, interpretation: verdict);
  }

  bool get calculationPassed => calculation == QaVerdict.passed;
  bool get interpretationPassed => interpretation == QaVerdict.passed;
  bool get fullyPassed => calculationPassed && interpretationPassed;
}

void _text(String value, String field) {
  if (value.trim().isEmpty) throw ArgumentError('$field cannot be blank');
}
