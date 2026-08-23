import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

import '../time/civil_calendar.dart';
import 'chinese_year.dart';

final class ChineseNewYearDatasetManifest {
  const ChineseNewYearDatasetManifest({
    required this.sourceId,
    required this.dataVersion,
    required this.expectedSha256,
    required this.minimumGregorianYear,
    required this.maximumGregorianYear,
  });

  final String sourceId;
  final String dataVersion;
  final String expectedSha256;
  final int minimumGregorianYear;
  final int maximumGregorianYear;

  void validate() {
    if (sourceId.trim().isEmpty) {
      throw ArgumentError.value(sourceId, 'sourceId', 'Must not be empty.');
    }
    if (dataVersion.trim().isEmpty) {
      throw ArgumentError.value(dataVersion, 'dataVersion', 'Must not be empty.');
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(expectedSha256)) {
      throw ArgumentError.value(
        expectedSha256,
        'expectedSha256',
        'Must be a lowercase SHA-256 hex digest.',
      );
    }
    if (minimumGregorianYear < CivilCalendar.minimumSupportedYear ||
        maximumGregorianYear > CivilCalendar.maximumSupportedYear ||
        minimumGregorianYear > maximumGregorianYear) {
      throw RangeError(
        'Chinese New Year dataset coverage must stay inside '
        '${CivilCalendar.minimumSupportedYear}..${CivilCalendar.maximumSupportedYear}.',
      );
    }
  }
}

/// Strict decoder for a bundled, versioned Chinese New Year boundary artifact.
///
/// JSON schema:
/// `{ "schemaVersion": 1, "boundaries": [{"year": 2024, "date": "2024-02-10"}] }`
///
/// The manifest is deliberately external to the artifact bytes so the bytes can
/// be authenticated by an immutable SHA-256 digest without a self-referential
/// checksum field.
abstract final class ChineseNewYearDatasetLoader {
  static TabulatedChineseNewYearBoundaryProvider load({
    required Uint8List bytes,
    required ChineseNewYearDatasetManifest manifest,
  }) {
    manifest.validate();
    if (bytes.isEmpty) {
      throw StateError('Chinese New Year dataset is empty.');
    }

    final actualSha256 = sha256.convert(bytes).toString();
    if (actualSha256 != manifest.expectedSha256) {
      throw StateError(
        'Chinese New Year dataset SHA-256 mismatch: '
        'expected=${manifest.expectedSha256} actual=$actualSha256.',
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(utf8.decode(bytes, allowMalformed: false));
    } on Object catch (error) {
      throw FormatException('Chinese New Year dataset is not valid UTF-8 JSON.', error);
    }
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Chinese New Year dataset root must be an object.');
    }
    if (decoded['schemaVersion'] != 1) {
      throw FormatException(
        'Unsupported Chinese New Year dataset schemaVersion: ${decoded['schemaVersion']}.',
      );
    }
    final rawBoundaries = decoded['boundaries'];
    if (rawBoundaries is! List) {
      throw const FormatException('Chinese New Year dataset boundaries must be a list.');
    }

    final boundaries = <int, CivilDate>{};
    for (final raw in rawBoundaries) {
      if (raw is! Map) {
        throw const FormatException('Chinese New Year boundary entry must be an object.');
      }
      final year = raw['year'];
      final date = raw['date'];
      if (year is! int || date is! String) {
        throw const FormatException('Chinese New Year boundary needs integer year and ISO date.');
      }
      if (year < manifest.minimumGregorianYear || year > manifest.maximumGregorianYear) {
        throw FormatException('Chinese New Year boundary year $year is outside manifest coverage.');
      }
      if (boundaries.containsKey(year)) {
        throw FormatException('Duplicate Chinese New Year boundary for $year.');
      }
      final parsed = CivilDate.parseIso(date);
      if (parsed.year != year) {
        throw FormatException('Chinese New Year boundary $date does not belong to $year.');
      }
      boundaries[year] = parsed;
    }

    final expectedCount = manifest.maximumGregorianYear - manifest.minimumGregorianYear + 1;
    if (boundaries.length != expectedCount) {
      throw StateError(
        'Chinese New Year dataset coverage is incomplete: '
        'expected=$expectedCount actual=${boundaries.length}.',
      );
    }
    for (var year = manifest.minimumGregorianYear;
        year <= manifest.maximumGregorianYear;
        year++) {
      if (!boundaries.containsKey(year)) {
        throw StateError('Chinese New Year dataset is missing boundary year $year.');
      }
    }

    return TabulatedChineseNewYearBoundaryProvider(
      sourceId: manifest.sourceId,
      dataVersion: manifest.dataVersion,
      boundaries: boundaries,
    );
  }
}
