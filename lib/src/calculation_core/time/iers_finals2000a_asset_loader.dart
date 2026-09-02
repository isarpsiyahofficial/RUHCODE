import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

import 'bundled_earth_orientation.dart';

/// Loads the exact IERS finals2000A snapshot packaged with the application.
///
/// This loader is deliberately offline and fail-closed. It validates the
/// packaged bytes against the release snapshot SHA-256 before parsing any EOP
/// values. Rows without a published UT1-UTC value are not treated as usable
/// coverage, and requests outside the resulting provider coverage fail in
/// [BundledEarthOrientationProvider].
final class IersFinals2000AAssetLoader {
  const IersFinals2000AAssetLoader({AssetBundle? bundle}) : _bundle = bundle;

  static const String assetPath = 'assets/data/eop/finals2000A.all';
  static const String sourceId = 'IERS finals2000A.all';
  static const String dataVersion = '2026-09-02';
  static const String expectedSha256 =
      'e3905ff7a74b791744704aa3e900a2161e96db97a30095d8fc442b04e4cfe058';

  final AssetBundle? _bundle;

  Future<BundledEarthOrientationProvider> loadPackaged() async {
    final bundle = _bundle ?? rootBundle;
    final data = await bundle.load(assetPath);
    final bytes = _bytes(data);
    final digest = sha256.convert(bytes).toString();
    if (digest != expectedSha256) {
      throw StateError(
        'Packaged IERS EOP checksum mismatch: expected $expectedSha256, got $digest.',
      );
    }
    final text = ascii.decode(bytes, allowInvalid: false);
    return parse(
      text,
      metadata: const EarthOrientationDatasetMetadata(
        sourceId: sourceId,
        dataVersion: dataVersion,
        checksumSha256: expectedSha256,
      ),
    );
  }

  static BundledEarthOrientationProvider parse(
    String text, {
    required EarthOrientationDatasetMetadata metadata,
  }) {
    final records = <EarthOrientationDailyRecord>[];
    double? previousMjd;

    final lines = const LineSplitter().convert(text);
    for (var index = 0; index < lines.length; index++) {
      final line = lines[index];
      if (line.trim().isEmpty) continue;
      if (line.length < 15) {
        throw FormatException('IERS row ${index + 1} is shorter than the MJD field.');
      }

      final mjd = double.tryParse(line.substring(7, 15).trim());
      if (mjd == null || !mjd.isFinite) {
        throw FormatException('IERS row ${index + 1} has an invalid MJD.');
      }
      if (previousMjd != null && mjd <= previousMjd) {
        throw FormatException('IERS MJD sequence is not strictly increasing at row ${index + 1}.');
      }
      previousMjd = mjd;

      // finals2000A fixed-width UT1-UTC field: columns 59-68 (1-based).
      // Some trailing source rows can carry date/MJD without a published UT1
      // value; they are intentionally excluded from usable runtime coverage.
      if (line.length < 68) continue;
      final rawUt1MinusUtc = line.substring(58, 68).trim();
      if (rawUt1MinusUtc.isEmpty) continue;
      final ut1MinusUtc = double.tryParse(rawUt1MinusUtc);
      if (ut1MinusUtc == null || !ut1MinusUtc.isFinite) {
        throw FormatException('IERS row ${index + 1} has an invalid UT1-UTC value.');
      }

      records.add(
        EarthOrientationDailyRecord(
          utcMidnight: _utcMidnightFromMjd(mjd, rowNumber: index + 1),
          ut1MinusUtcSeconds: ut1MinusUtc,
        ),
      );
    }

    if (records.length < 10000) {
      throw StateError(
        'Packaged IERS EOP has too few usable UT1-UTC rows: ${records.length}.',
      );
    }
    return BundledEarthOrientationProvider(metadata: metadata, records: records);
  }

  static DateTime _utcMidnightFromMjd(double mjd, {required int rowNumber}) {
    final rounded = mjd.roundToDouble();
    if ((mjd - rounded).abs() > 1e-9) {
      throw FormatException('IERS row $rowNumber MJD is not an exact UTC-midnight day.');
    }
    const unixEpochMjd = 40587;
    return DateTime.utc(1970, 1, 1).add(Duration(days: rounded.toInt() - unixEpochMjd));
  }

  static Uint8List _bytes(ByteData data) => data.buffer.asUint8List(
        data.offsetInBytes,
        data.lengthInBytes,
      );
}
