import 'dart:convert';

import 'package:flutter/services.dart';

import 'ayanamsha.dart';
import 'ayanamsha_catalog.dart';
import 'vedic_engine.dart';

/// Packaged offline Lahiri/Chitrapaksha provider used by the Vedic engine.
///
/// Numerical values are generated independently with Swiss Ephemeris Lahiri
/// mode and are interpolated by [TabulatedAyanamshaProvider]. Extrapolation is
/// deliberately forbidden by the underlying provider.
final class BundledLahiriAyanamsha implements VedicAyanamshaProvider {
  BundledLahiriAyanamsha._(this._table);

  static const assetPath = 'assets/data/ayanamsha/lahiri_chitrapaksha_5y.json';

  final TabulatedAyanamshaProvider _table;

  static Future<BundledLahiriAyanamsha> load({AssetBundle? bundle}) async {
    final raw = await (bundle ?? rootBundle).loadString(assetPath);
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    if (decoded['schemaVersion'] != 1 ||
        decoded['id'] != VedicAyanamshaIds.lahiriChitrapaksha) {
      throw const FormatException('Invalid bundled Lahiri ayanamsha contract.');
    }
    final samples = (decoded['samples'] as List<dynamic>)
        .map((item) {
          final row = item as Map<String, dynamic>;
          return AyanamshaSample(
            julianDayTt: (row['julianDayTt'] as num).toDouble(),
            degrees: (row['degrees'] as num).toDouble(),
          );
        })
        .toList(growable: false);
    return BundledLahiriAyanamsha._(
      TabulatedAyanamshaProvider(
        sourceId: decoded['sourceId'] as String,
        sourceVersion: decoded['sourceVersion'] as String,
        dataSha256: decoded['dataSha256'] as String,
        samples: samples,
      ),
    );
  }

  @override
  String get id => VedicAyanamshaIds.lahiriChitrapaksha;

  @override
  String get dataVersion => '${_table.sourceVersion}:${_table.dataSha256}';

  @override
  double degreesAt(double jdTt) => _table.atJulianDayTt(jdTt).degrees;
}
