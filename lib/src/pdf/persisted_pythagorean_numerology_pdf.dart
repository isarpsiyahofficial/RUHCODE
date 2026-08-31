import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../calculation_core/numerology/pythagorean_snapshot.dart';
import '../calculation_core/numerology/pythagorean_snapshot_fingerprint.dart';
import 'pdf_cover_section.dart';
import 'pdf_data_contract.dart';
import 'pdf_local_renderer.dart';
import 'pdf_local_service.dart';
import 'pdf_numerology_data.dart';
import 'pdf_numerology_section.dart';
import 'pdf_report_contract.dart';
import 'pdf_service.dart';
import 'persisted_calculation_pdf_source.dart';
import 'persisted_manifest_section.dart';

/// Production persisted-payload contract for canonical Pythagorean snapshots.
///
/// The calculation payload stores the exact canonical JSON used by
/// [PythagoreanSnapshotFingerprint]. PDF generation never recalculates the
/// numerology result from birth/name input. It validates the persisted digest
/// and projects the already-calculated metric values into the local renderer.
abstract final class PersistedPythagoreanNumerologyPdfContract {
  static const String calculationType = 'numerology.pythagorean';
  static const String payloadSchema = 'ruhcode.numerology.pythagorean.snapshot.v1';
  static const String payloadSchemaKey = 'snapshotSchema';
  static const String canonicalJsonKey = 'snapshotCanonicalJson';
  static const String digestKey = 'snapshotSha256';
  static const String subjectKindKey = 'subjectKind';
}

final class PersistedPythagoreanNumerologyPdfService
    implements PdfService<PersistedCalculationPdfSnapshot> {
  const PersistedPythagoreanNumerologyPdfService({required this.fontProvider});

  final PdfFontBundleProvider fontProvider;

  @override
  Future<List<int>> buildReport({
    required PersistedCalculationPdfSnapshot snapshot,
    required PdfReportOptions options,
  }) async {
    final parsed = _PersistedNumerologyPayload.parse(snapshot);
    final adapter = _PersistedNumerologyContentAdapter(
      localeTag: options.localeTag,
      parsed: parsed,
    );
    return PdfLocalReportService<PersistedCalculationPdfSnapshot>(
      adapter: adapter,
      fontProvider: fontProvider,
    ).buildReport(snapshot: snapshot, options: options);
  }
}

final class _PersistedNumerologyPayload {
  const _PersistedNumerologyPayload({
    required this.digest,
    required this.subjectKind,
    required this.rows,
  });

  final String digest;
  final PdfSubjectKind subjectKind;
  final List<PdfNumerologyMetricRow> rows;

  static _PersistedNumerologyPayload parse(
    PersistedCalculationPdfSnapshot snapshot,
  ) {
    if (snapshot.calculationType !=
        PersistedPythagoreanNumerologyPdfContract.calculationType) {
      throw FormatException(
        'Persisted Pythagorean PDF handler cannot consume ${snapshot.calculationType}.',
      );
    }
    final payload = snapshot.payload;
    if (_requiredString(payload,
            PersistedPythagoreanNumerologyPdfContract.payloadSchemaKey) !=
        PersistedPythagoreanNumerologyPdfContract.payloadSchema) {
      throw const FormatException('Unsupported persisted numerology snapshot schema.');
    }
    final canonicalJson = _requiredString(
      payload,
      PersistedPythagoreanNumerologyPdfContract.canonicalJsonKey,
    );
    final expectedDigest = _requiredString(
      payload,
      PersistedPythagoreanNumerologyPdfContract.digestKey,
    );
    if (!RegExp(r'^[a-f0-9]{64}$').hasMatch(expectedDigest)) {
      throw const FormatException('Persisted numerology snapshot digest is invalid.');
    }
    final actualDigest = sha256.convert(utf8.encode(canonicalJson)).toString();
    if (actualDigest != expectedDigest) {
      throw const FormatException('Persisted numerology snapshot digest mismatch.');
    }

    final decoded = jsonDecode(canonicalJson);
    if (decoded is! Map) {
      throw const FormatException('Canonical numerology snapshot must be a JSON object.');
    }
    final canonical = decoded.map<String, Object?>(
      (key, value) => MapEntry(key.toString(), value),
    );
    if (_requiredString(canonical, 'schemaVersion') !=
        PythagoreanSnapshotFingerprint.schemaVersion) {
      throw const FormatException('Canonical numerology fingerprint schema mismatch.');
    }
    if (_requiredString(canonical, 'engineId') !=
        PythagoreanNumerologySnapshotEngine.engineId) {
      throw const FormatException('Canonical numerology engine ID mismatch.');
    }
    if (_requiredString(canonical, 'engineVersion') !=
        PythagoreanNumerologySnapshotEngine.engineVersion) {
      throw const FormatException('Canonical numerology engine version mismatch.');
    }
    if (snapshot.manifest.engineVersion !=
        PythagoreanNumerologySnapshotEngine.engineVersion) {
      throw const FormatException('Calculation manifest/numerology engine version drift.');
    }

    final profile = _requiredMap(canonical, 'profile');
    final extended = _requiredMap(canonical, 'extendedName');
    final periods = _requiredMap(canonical, 'periods');
    final rows = <PdfNumerologyMetricRow>[
      _metric(profile, 'lifePath', 'life_path'),
      _metric(profile, 'expression', 'expression'),
      _metric(profile, 'soulUrge', 'soul_urge'),
      _metric(profile, 'personality', 'personality'),
      _metric(profile, 'birthday', 'birthday'),
      _metric(profile, 'maturity', 'maturity'),
      _metric(extended, 'balance', 'balance'),
      PdfNumerologyMetricRow(
        metricId: 'karmic_lessons',
        value: _requiredIntList(extended, 'karmicLessons').join(','),
      ),
      PdfNumerologyMetricRow(
        metricId: 'hidden_passions',
        value: _requiredIntList(extended, 'hiddenPassions').join(','),
      ),
      PdfNumerologyMetricRow(
        metricId: 'pinnacles',
        value: _requiredIntList(periods, 'pinnacles').join(','),
      ),
      PdfNumerologyMetricRow(
        metricId: 'challenges',
        value: _requiredIntList(periods, 'challenges').join(','),
      ),
    ];

    final cycles = canonical['cycles'];
    if (cycles != null) {
      if (cycles is! Map) {
        throw const FormatException('Canonical numerology cycles must be an object or null.');
      }
      final cycleMap = cycles.map<String, Object?>(
        (key, value) => MapEntry(key.toString(), value),
      );
      rows.addAll(<PdfNumerologyMetricRow>[
        _metric(cycleMap, 'personalYear', 'personal_year'),
        _metric(cycleMap, 'personalMonth', 'personal_month'),
        _metric(cycleMap, 'personalDay', 'personal_day'),
      ]);
    }

    final subjectKindRaw = _requiredString(
      payload,
      PersistedPythagoreanNumerologyPdfContract.subjectKindKey,
    );
    final subjectKind = switch (subjectKindRaw) {
      'profile' => PdfSubjectKind.profile,
      'client' => PdfSubjectKind.client,
      _ => throw const FormatException(
          'Persisted numerology PDF subjectKind must be profile or client.',
        ),
    };

    return _PersistedNumerologyPayload(
      digest: actualDigest,
      subjectKind: subjectKind,
      rows: List<PdfNumerologyMetricRow>.unmodifiable(rows),
    );
  }

  static PdfNumerologyMetricRow _metric(
    Map<String, Object?> map,
    String key,
    String metricId,
  ) => PdfNumerologyMetricRow(
        metricId: metricId,
        value: '${_requiredInt(map, key)}',
      );

  static String _requiredString(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('$key must be a non-empty string.');
    }
    return value;
  }

  static Map<String, Object?> _requiredMap(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is! Map) {
      throw FormatException('$key must be an object.');
    }
    return value.map<String, Object?>((k, v) => MapEntry(k.toString(), v));
  }

  static int _requiredInt(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is! int) {
      throw FormatException('$key must be an integer.');
    }
    return value;
  }

  static List<int> _requiredIntList(Map<String, Object?> map, String key) {
    final value = map[key];
    if (value is! List || value.any((item) => item is! int)) {
      throw FormatException('$key must be an integer list.');
    }
    return List<int>.unmodifiable(value.cast<int>());
  }
}

final class _PersistedNumerologyContentAdapter
    implements PdfReportContentAdapter<PersistedCalculationPdfSnapshot> {
  const _PersistedNumerologyContentAdapter({
    required this.localeTag,
    required this.parsed,
  });

  final String localeTag;
  final _PersistedNumerologyPayload parsed;

  @override
  PdfReportKind get reportKind => PdfReportKind.numerology;

  @override
  PdfDataOrigin get dataOrigin => PdfDataOrigin.user;

  @override
  PdfCoverStyle get coverStyle => PdfCoverStyle.professional;

  @override
  String documentTitle(PersistedCalculationPdfSnapshot snapshot, String locale) {
    _validateLocale(locale);
    if (locale != localeTag) {
      throw StateError('Numerology PDF adapter locale drift detected.');
    }
    return locale == 'tr' ? 'Numeroloji Raporu' : 'Numerology Report';
  }

  @override
  PdfReportDataset dataset(PersistedCalculationPdfSnapshot snapshot) {
    return PdfReportDataset(
      origin: PdfDataOrigin.user,
      identity: PdfSnapshotIdentity(
        subjectKind: parsed.subjectKind,
        subjectId: snapshot.ownerEntityId,
        snapshotDigest: parsed.digest,
        engineVersion: snapshot.manifest.engineVersion,
        algorithmVersion: snapshot.manifest.algorithmVersion,
        dataVersion: snapshot.manifest.dataVersion,
        calculationManifestId: snapshot.manifest.id.value,
      ),
      sections: <PdfSectionDataRef>[
        PdfCoverSectionAdapter.dataRef(snapshotDigest: parsed.digest),
        PdfSectionDataRef(
          sectionId: PdfSectionIds.numerology,
          snapshotDigest: parsed.digest,
          hasContent: parsed.rows.isNotEmpty,
        ),
        PdfSectionDataRef(
          sectionId: PdfSectionIds.technicalManifest,
          snapshotDigest: parsed.digest,
          hasContent: true,
        ),
      ],
    );
  }

  @override
  List<PdfRenderSection> sections(PersistedCalculationPdfSnapshot snapshot) {
    _validateLocale(localeTag);
    final labels = _labels[localeTag]!;
    final payload = PdfNumerologyPayload(
      dataset: dataset(snapshot),
      snapshotDigest: parsed.digest,
      metricRows: parsed.rows,
    );
    return <PdfRenderSection>[
      PdfCoverSectionAdapter.build(
        snapshotDigest: parsed.digest,
        title: labels['coverTitle']!,
      ),
      PdfNumerologySectionAdapter.build(
        payload: payload,
        title: labels['numerologyTitle']!,
        metricHeader: labels['metricHeader']!,
        valueHeader: labels['valueHeader']!,
        labelForMetric: (metricId) => _metricLabels[localeTag]![metricId] ?? '',
      ),
      PersistedManifestSectionAdapter.build(
        manifest: snapshot.manifest,
        snapshotDigest: parsed.digest,
        title: labels['technicalTitle']!,
        fieldHeader: labels['fieldHeader']!,
        valueHeader: labels['valueHeader']!,
        labelForField: (id) => _manifestFieldLabels[localeTag]?[id] ?? '',
      ),
    ];
  }

  static void _validateLocale(String locale) {
    if (locale != 'tr' && locale != 'en') {
      throw FormatException('Unsupported professional numerology PDF locale: $locale');
    }
  }

  static const Map<String, Map<String, String>> _labels = <String, Map<String, String>>{
    'tr': <String, String>{
      'coverTitle': 'Numeroloji Raporu',
      'numerologyTitle': 'Numeroloji Özeti',
      'metricHeader': 'Gösterge',
      'valueHeader': 'Değer',
      'technicalTitle': 'Hesaplama Bilgileri',
      'fieldHeader': 'Alan',
    },
    'en': <String, String>{
      'coverTitle': 'Numerology Report',
      'numerologyTitle': 'Numerology Summary',
      'metricHeader': 'Metric',
      'valueHeader': 'Value',
      'technicalTitle': 'Calculation Details',
      'fieldHeader': 'Field',
    },
  };

  static const Map<String, Map<String, String>> _metricLabels = <String, Map<String, String>>{
    'tr': <String, String>{
      'life_path': 'Yaşam Yolu',
      'expression': 'Kader / İfade',
      'soul_urge': 'Ruh Arzusu',
      'personality': 'Kişilik',
      'birthday': 'Doğum Günü',
      'maturity': 'Olgunluk',
      'balance': 'Denge',
      'karmic_lessons': 'Karmik Dersler',
      'hidden_passions': 'Gizli Tutkular',
      'pinnacles': 'Zirveler',
      'challenges': 'Zorluklar',
      'personal_year': 'Kişisel Yıl',
      'personal_month': 'Kişisel Ay',
      'personal_day': 'Kişisel Gün',
    },
    'en': <String, String>{
      'life_path': 'Life Path',
      'expression': 'Expression',
      'soul_urge': 'Soul Urge',
      'personality': 'Personality',
      'birthday': 'Birthday',
      'maturity': 'Maturity',
      'balance': 'Balance',
      'karmic_lessons': 'Karmic Lessons',
      'hidden_passions': 'Hidden Passions',
      'pinnacles': 'Pinnacles',
      'challenges': 'Challenges',
      'personal_year': 'Personal Year',
      'personal_month': 'Personal Month',
      'personal_day': 'Personal Day',
    },
  };

  static const _manifestFieldLabels = <String, Map<String, String>>{
    'tr': <String, String>{
      'engineId': 'Motor',
      'engineVersion': 'Motor Sürümü',
      'algorithmVersion': 'Algoritma Sürümü',
      'dataVersion': 'Veri Sürümü',
      'timezoneDatabaseVersion': 'Zaman Dilimi Verisi',
      'localDateTime': 'Yerel Tarih/Saat',
      'utcDateTime': 'UTC Tarih/Saat',
      'locationLabel': 'Konum',
      'countryCode': 'Ülke Kodu',
      'latitude': 'Enlem',
      'longitude': 'Boylam',
      'ianaTimeZoneId': 'IANA Zaman Dilimi',
      'validity': 'Geçerlilik',
      'houseSystemId': 'Ev Sistemi',
      'zodiacSystemId': 'Zodyak Sistemi',
      'ayanamshaId': 'Ayanamsha',
      'nodeModeId': 'Ay Düğümü Modu',
    },
    'en': <String, String>{
      'engineId': 'Engine',
      'engineVersion': 'Engine Version',
      'algorithmVersion': 'Algorithm Version',
      'dataVersion': 'Data Version',
      'timezoneDatabaseVersion': 'Time Zone Data',
      'localDateTime': 'Local Date/Time',
      'utcDateTime': 'UTC Date/Time',
      'locationLabel': 'Location',
      'countryCode': 'Country Code',
      'latitude': 'Latitude',
      'longitude': 'Longitude',
      'ianaTimeZoneId': 'IANA Time Zone',
      'validity': 'Validity',
      'houseSystemId': 'House System',
      'zodiacSystemId': 'Zodiac System',
      'ayanamshaId': 'Ayanamsha',
      'nodeModeId': 'Node Mode',
    },
  };
}
