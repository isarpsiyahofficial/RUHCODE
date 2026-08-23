import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/chinese/chinese_new_year_dataset.dart';
import 'package:ruh_code/src/calculation_core/chinese/chinese_year.dart';
import 'package:ruh_code/src/calculation_core/time/civil_calendar.dart';

void main() {
  Uint8List datasetBytes(List<Map<String, Object>> boundaries) {
    return Uint8List.fromList(
      utf8.encode(jsonEncode({
        'schemaVersion': 1,
        'boundaries': boundaries,
      })),
    );
  }

  ChineseNewYearDatasetManifest manifestFor(
    Uint8List bytes, {
    int minimumYear = 2024,
    int maximumYear = 2026,
  }) {
    return ChineseNewYearDatasetManifest(
      sourceId: 'reviewed-cny-fixture',
      dataVersion: 'fixture-v1',
      expectedSha256: sha256.convert(bytes).toString(),
      minimumGregorianYear: minimumYear,
      maximumGregorianYear: maximumYear,
    );
  }

  final completeBoundaries = <Map<String, Object>>[
    {'year': 2024, 'date': '2024-02-10'},
    {'year': 2025, 'date': '2025-01-29'},
    {'year': 2026, 'date': '2026-02-17'},
  ];

  test('loads a checksum-verified contiguous boundary dataset', () {
    final bytes = datasetBytes(completeBoundaries);
    final provider = ChineseNewYearDatasetLoader.load(
      bytes: bytes,
      manifest: manifestFor(bytes),
    );

    expect(provider.sourceId, 'reviewed-cny-fixture');
    expect(provider.dataVersion, 'fixture-v1');
    expect(provider.boundaryForGregorianYear(2024), CivilDate(2024, 2, 10));
    expect(provider.boundaryForGregorianYear(2025), CivilDate(2025, 1, 29));
    expect(provider.boundaryForGregorianYear(2026), CivilDate(2026, 2, 17));
  });

  test('rejects artifact bytes that do not match the immutable SHA-256 manifest', () {
    final original = datasetBytes(completeBoundaries);
    final tampered = Uint8List.fromList([...original, 0x20]);

    expect(
      () => ChineseNewYearDatasetLoader.load(
        bytes: tampered,
        manifest: manifestFor(original),
      ),
      throwsStateError,
    );
  });

  test('rejects incomplete year coverage even when checksum is valid', () {
    final bytes = datasetBytes([
      {'year': 2024, 'date': '2024-02-10'},
      {'year': 2026, 'date': '2026-02-17'},
    ]);

    expect(
      () => ChineseNewYearDatasetLoader.load(
        bytes: bytes,
        manifest: manifestFor(bytes),
      ),
      throwsStateError,
    );
  });

  test('rejects duplicate boundary years', () {
    final bytes = datasetBytes([
      {'year': 2024, 'date': '2024-02-10'},
      {'year': 2024, 'date': '2024-02-11'},
      {'year': 2025, 'date': '2025-01-29'},
    ]);

    expect(
      () => ChineseNewYearDatasetLoader.load(
        bytes: bytes,
        manifest: manifestFor(bytes, maximumYear: 2025),
      ),
      throwsFormatException,
    );
  });

  test('rejects a boundary date whose civil year disagrees with its key', () {
    final bytes = datasetBytes([
      {'year': 2024, 'date': '2025-01-01'},
    ]);

    expect(
      () => ChineseNewYearDatasetLoader.load(
        bytes: bytes,
        manifest: manifestFor(bytes, minimumYear: 2024, maximumYear: 2024),
      ),
      throwsFormatException,
    );
  });

  test('production coverage manifest cannot exceed Ruh Code supported civil years', () {
    const invalid = ChineseNewYearDatasetManifest(
      sourceId: 'fixture',
      dataVersion: 'fixture-v1',
      expectedSha256: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      minimumGregorianYear: 1889,
      maximumGregorianYear: 2110,
    );

    expect(invalid.validate, throwsRangeError);
  });

  test('loaded provider still fails closed outside declared coverage', () {
    final bytes = datasetBytes(completeBoundaries);
    final provider = ChineseNewYearDatasetLoader.load(
      bytes: bytes,
      manifest: manifestFor(bytes),
    );
    final engine = ChineseZodiacYearEngine(boundaries: provider);

    expect(
      () => engine.calculate(CivilDate(2027, 2, 1)),
      throwsStateError,
    );
  });
}
