import 'earth_orientation.dart';

final class EarthOrientationDatasetMetadata {
  const EarthOrientationDatasetMetadata({
    required this.sourceId,
    required this.dataVersion,
    required this.checksumSha256,
  });

  final String sourceId;
  final String dataVersion;
  final String checksumSha256;

  void validate() {
    if (sourceId.trim().isEmpty || dataVersion.trim().isEmpty) {
      throw StateError('Earth-orientation dataset source/version is required.');
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(checksumSha256)) {
      throw StateError('Earth-orientation SHA-256 must be lowercase 64-character hex.');
    }
  }
}

final class EarthOrientationDailyRecord {
  const EarthOrientationDailyRecord({
    required this.utcMidnight,
    required this.ut1MinusUtcSeconds,
  });

  final DateTime utcMidnight;
  final double ut1MinusUtcSeconds;

  void validate() {
    if (!utcMidnight.isUtc ||
        utcMidnight.hour != 0 ||
        utcMidnight.minute != 0 ||
        utcMidnight.second != 0 ||
        utcMidnight.millisecond != 0 ||
        utcMidnight.microsecond != 0) {
      throw StateError('EOP daily records must be exact UTC midnight samples.');
    }
    if (!ut1MinusUtcSeconds.isFinite || ut1MinusUtcSeconds.abs() >= 0.9) {
      throw RangeError('UT1-UTC daily record must be finite and within ±0.9 s.');
    }
  }
}

final class BundledEarthOrientationProvider implements EarthOrientationProvider {
  BundledEarthOrientationProvider({
    required this.metadata,
    required Iterable<EarthOrientationDailyRecord> records,
    this.maximumGap = const Duration(days: 2),
  }) : _records = records.toList(growable: false) {
    metadata.validate();
    if (maximumGap <= Duration.zero) {
      throw RangeError('maximumGap must be positive.');
    }
    if (_records.length < 2) {
      throw StateError('At least two EOP daily records are required for interpolation.');
    }
    for (final record in _records) {
      record.validate();
    }
    _records.sort((a, b) => a.utcMidnight.compareTo(b.utcMidnight));
    for (var i = 1; i < _records.length; i++) {
      final previous = _records[i - 1];
      final current = _records[i];
      if (!current.utcMidnight.isAfter(previous.utcMidnight)) {
        throw StateError('EOP records must have unique increasing UTC midnights.');
      }
      if (current.utcMidnight.difference(previous.utcMidnight) > maximumGap) {
        throw StateError('EOP dataset contains a gap larger than maximumGap.');
      }
    }
  }

  final EarthOrientationDatasetMetadata metadata;
  final List<EarthOrientationDailyRecord> _records;
  final Duration maximumGap;

  DateTime get coverageStartUtc => _records.first.utcMidnight;
  DateTime get coverageEndUtc => _records.last.utcMidnight;

  @override
  EarthOrientationSample sampleAt(DateTime utcInstant) {
    if (!utcInstant.isUtc) {
      throw ArgumentError.value(utcInstant, 'utcInstant', 'Expected UTC.');
    }
    if (utcInstant.isBefore(coverageStartUtc) || utcInstant.isAfter(coverageEndUtc)) {
      throw RangeError('Requested UTC instant is outside packaged EOP coverage.');
    }

    final exactIndex = _records.indexWhere((record) => record.utcMidnight == utcInstant);
    if (exactIndex >= 0) {
      return _sample(utcInstant, _records[exactIndex].ut1MinusUtcSeconds);
    }

    var upperIndex = 1;
    while (upperIndex < _records.length && !_records[upperIndex].utcMidnight.isAfter(utcInstant)) {
      upperIndex++;
    }
    if (upperIndex >= _records.length) {
      throw RangeError('Cannot interpolate beyond packaged EOP coverage.');
    }
    final lower = _records[upperIndex - 1];
    final upper = _records[upperIndex];
    final spanMicros = upper.utcMidnight.difference(lower.utcMidnight).inMicroseconds;
    final offsetMicros = utcInstant.difference(lower.utcMidnight).inMicroseconds;
    final fraction = offsetMicros / spanMicros;
    final interpolated = lower.ut1MinusUtcSeconds +
        (upper.ut1MinusUtcSeconds - lower.ut1MinusUtcSeconds) * fraction;
    return _sample(utcInstant, interpolated);
  }

  EarthOrientationSample _sample(DateTime utcInstant, double value) => EarthOrientationSample(
        utcInstant: utcInstant,
        ut1MinusUtcSeconds: value,
        sourceId: metadata.sourceId,
        dataVersion: metadata.dataVersion,
      );
}
