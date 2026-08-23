import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../calculation_core/numerology/pythagorean_snapshot.dart';
import '../calculation_core/numerology/pythagorean_snapshot_fingerprint.dart';
import 'pdf_combined_report.dart';
import 'pdf_data_contract.dart';
import 'pdf_local_renderer.dart';
import 'pdf_report_contract.dart';
import 'persisted_calculation_pdf_source.dart';
import 'persisted_pythagorean_numerology_pdf.dart';
import 'persisted_western_natal_pdf.dart';
import 'persisted_western_natal_sections.dart';
import 'persisted_western_natal_snapshot.dart';

/// Production bridge from multiple persisted calculation records to one
/// combined professional-PDF projection.
///
/// It never recalculates astronomy or numerology. Each projector validates the
/// exact persisted snapshot and emits child sections bound to that snapshot
/// digest. [PdfCombinedReportBuilder] then seals the exact ordered member set.
final class PersistedCombinedPdfProjectionSource {
  const PersistedCombinedPdfProjectionSource({
    required this.snapshotSource,
    this.projectors = const <PersistedCombinedPdfMemberProjector>[
      PersistedWesternCombinedMemberProjector(),
      PersistedPythagoreanCombinedMemberProjector(),
    ],
    this.builder = const PdfCombinedReportBuilder(),
  });

  final ProfessionalPdfSnapshotSource<PersistedCalculationPdfSnapshot>
      snapshotSource;
  final List<PersistedCombinedPdfMemberProjector> projectors;
  final PdfCombinedReportBuilder builder;

  Future<PdfCombinedReportProjection> load({
    required Iterable<String> recordIds,
    required String localeTag,
  }) async {
    final locale = _normalizeLocale(localeTag);
    final ids = <String>[];
    final seen = <String>{};
    for (final raw in recordIds) {
      final id = raw.trim();
      if (id.isEmpty) {
        throw const FormatException(
          'Combined PDF calculation record IDs must not be blank.',
        );
      }
      if (!seen.add(id)) {
        throw FormatException('Duplicate combined PDF record ID: $id');
      }
      ids.add(id);
    }
    if (ids.length < 2) {
      throw const FormatException(
        'Combined PDF requires at least two persisted calculation records.',
      );
    }

    final members = <PdfCombinedMember>[];
    String? ownerEntityId;
    for (final id in ids) {
      final snapshot = await snapshotSource.loadByRecordId(id);
      if (snapshot == null) {
        throw StateError('Combined PDF calculation record not found: $id');
      }
      ownerEntityId ??= snapshot.ownerEntityId;
      if (snapshot.ownerEntityId != ownerEntityId) {
        throw const FormatException(
          'Combined PDF persisted records must belong to the same subject.',
        );
      }

      final projector = _projectorFor(snapshot.calculationType);
      final member = projector.project(snapshot: snapshot, localeTag: locale);
      if (member.systemId != projector.systemId) {
        throw const StateError('Combined PDF projector system ID drift detected.');
      }
      members.add(member);
    }

    final labels = _combinedLabels[locale]!;
    return builder.build(
      members: members,
      coverTitle: labels['coverTitle']!,
      technicalTitle: labels['technicalTitle']!,
      systemHeader: labels['systemHeader']!,
      fieldHeader: labels['fieldHeader']!,
      valueHeader: labels['valueHeader']!,
    );
  }

  PersistedCombinedPdfMemberProjector _projectorFor(String calculationType) {
    final matches = projectors
        .where((projector) => projector.calculationType == calculationType)
        .toList(growable: false);
    if (matches.isEmpty) {
      throw FormatException(
        'No combined PDF projector for calculation type: $calculationType',
      );
    }
    if (matches.length != 1) {
      throw StateError(
        'Duplicate combined PDF projectors for calculation type: $calculationType',
      );
    }
    return matches.single;
  }

  static String _normalizeLocale(String localeTag) {
    final language = localeTag.trim().split(RegExp('[-_]')).first.toLowerCase();
    if (language != 'tr' && language != 'en') {
      throw FormatException('Unsupported combined PDF locale: $localeTag');
    }
    return language;
  }

  static const _combinedLabels = <String, Map<String, String>>{
    'tr': <String, String>{
      'coverTitle': 'Kombine Danışmanlık Raporu',
      'technicalTitle': 'Hesaplama Kaynakları',
      'systemHeader': 'Sistem',
      'fieldHeader': 'Alan',
      'valueHeader': 'Değer',
    },
    'en': <String, String>{
      'coverTitle': 'Combined Consultation Report',
      'technicalTitle': 'Calculation Sources',
      'systemHeader': 'System',
      'fieldHeader': 'Field',
      'valueHeader': 'Value',
    },
  };
}

abstract interface class PersistedCombinedPdfMemberProjector {
  String get calculationType;
  String get systemId;

  PdfCombinedMember project({
    required PersistedCalculationPdfSnapshot snapshot,
    required String localeTag,
  });
}

final class PersistedWesternCombinedMemberProjector
    implements PersistedCombinedPdfMemberProjector {
  const PersistedWesternCombinedMemberProjector();

  @override
  String get calculationType => persistedWesternNatalCalculationType;

  @override
  String get systemId => 'western.natal';

  @override
  PdfCombinedMember project({
    required PersistedCalculationPdfSnapshot snapshot,
    required String localeTag,
  }) {
    _requireLocale(localeTag);
    final parsed = PersistedWesternNatalPdfReader.read(snapshot);
    final envelope = PersistedWesternNatalEnvelope.seal(parsed.snapshot);
    if (envelope.snapshotSha256 != parsed.snapshotSha256) {
      throw const FormatException('Western combined PDF digest drift detected.');
    }
    final labels = _westernLabels[localeTag]!;
    final sections = PersistedWesternNatalSectionAdapter.build(
      envelope: envelope,
      placementsTitle: '${labels['system']!} — ${labels['placements']!}',
      housesTitle: '${labels['system']!} — ${labels['houses']!}',
      aspectsTitle: '${labels['system']!} — ${labels['aspects']!}',
      bodyHeader: labels['body']!,
      signHeader: labels['sign']!,
      degreeHeader: labels['degree']!,
      houseHeader: labels['house']!,
      motionHeader: labels['motion']!,
      cuspHeader: labels['cusp']!,
      aspectHeader: labels['aspect']!,
      separationHeader: labels['separation']!,
      orbHeader: labels['orb']!,
      bodyLabel: (id) => _bodyLabels[localeTag]?[id] ?? '',
      signLabel: (id) => _signLabels[localeTag]?[id] ?? '',
      motionLabel: (id) => _motionLabels[localeTag]?[id] ?? '',
      aspectLabel: (id) => _aspectLabels[localeTag]?[id] ?? '',
    );
    return PdfCombinedMember(
      systemId: systemId,
      identity: PdfSnapshotIdentity(
        subjectKind: PdfSubjectKind.profile,
        subjectId: snapshot.ownerEntityId,
        snapshotDigest: parsed.snapshotSha256,
        engineVersion: snapshot.manifest.engineVersion,
        algorithmVersion: snapshot.manifest.algorithmVersion,
        dataVersion: snapshot.manifest.dataVersion,
        calculationManifestId: snapshot.manifest.id.value,
      ),
      sections: sections,
    );
  }
}

final class PersistedPythagoreanCombinedMemberProjector
    implements PersistedCombinedPdfMemberProjector {
  const PersistedPythagoreanCombinedMemberProjector();

  @override
  String get calculationType =>
      PersistedPythagoreanNumerologyPdfContract.calculationType;

  @override
  String get systemId => 'numerology.pythagorean';

  @override
  PdfCombinedMember project({
    required PersistedCalculationPdfSnapshot snapshot,
    required String localeTag,
  }) {
    _requireLocale(localeTag);
    if (snapshot.calculationType != calculationType) {
      throw FormatException(
        'Pythagorean combined projector cannot consume ${snapshot.calculationType}.',
      );
    }
    final payload = snapshot.payload;
    final schema = _requiredString(
      payload,
      PersistedPythagoreanNumerologyPdfContract.payloadSchemaKey,
    );
    if (schema != PersistedPythagoreanNumerologyPdfContract.payloadSchema) {
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
    final digest = sha256.convert(utf8.encode(canonicalJson)).toString();
    if (digest != expectedDigest || !RegExp(r'^[a-f0-9]{64}$').hasMatch(digest)) {
      throw const FormatException('Persisted numerology snapshot digest mismatch.');
    }
    final decoded = jsonDecode(canonicalJson);
    if (decoded is! Map) {
      throw const FormatException('Canonical numerology snapshot must be an object.');
    }
    final canonical = decoded.map<String, Object?>(
      (key, value) => MapEntry(key.toString(), value),
    );
    if (_requiredString(canonical, 'schemaVersion') !=
        PythagoreanSnapshotFingerprint.schemaVersion) {
      throw const FormatException('Canonical numerology fingerprint schema mismatch.');
    }
    if (_requiredString(canonical, 'engineId') !=
        PythagoreanNumerologySnapshotEngine.engineId ||
        _requiredString(canonical, 'engineVersion') !=
            PythagoreanNumerologySnapshotEngine.engineVersion ||
        snapshot.manifest.engineVersion !=
            PythagoreanNumerologySnapshotEngine.engineVersion) {
      throw const FormatException('Persisted numerology provenance mismatch.');
    }

    final profile = _requiredMap(canonical, 'profile');
    final extended = _requiredMap(canonical, 'extendedName');
    final periods = _requiredMap(canonical, 'periods');
    final labels = _numerologyLabels[localeTag]!;
    final rows = <List<String>>[
      <String>[labels['metric']!, labels['value']!],
      _metricRow(labels, 'lifePath', profile, 'lifePath'),
      _metricRow(labels, 'expression', profile, 'expression'),
      _metricRow(labels, 'soulUrge', profile, 'soulUrge'),
      _metricRow(labels, 'personality', profile, 'personality'),
      _metricRow(labels, 'birthday', profile, 'birthday'),
      _metricRow(labels, 'maturity', profile, 'maturity'),
      _metricRow(labels, 'balance', extended, 'balance'),
      <String>[
        labels['karmicLessons']!,
        _requiredIntList(extended, 'karmicLessons').join(','),
      ],
      <String>[
        labels['hiddenPassions']!,
        _requiredIntList(extended, 'hiddenPassions').join(','),
      ],
      <String>[labels['pinnacles']!, _requiredIntList(periods, 'pinnacles').join(',')],
      <String>[labels['challenges']!, _requiredIntList(periods, 'challenges').join(',')],
    ];
    final cycles = canonical['cycles'];
    if (cycles != null) {
      if (cycles is! Map) {
        throw const FormatException('Canonical numerology cycles must be an object or null.');
      }
      final cycleMap = cycles.map<String, Object?>(
        (key, value) => MapEntry(key.toString(), value),
      );
      rows.addAll(<List<String>>[
        _metricRow(labels, 'personalYear', cycleMap, 'personalYear'),
        _metricRow(labels, 'personalMonth', cycleMap, 'personalMonth'),
        _metricRow(labels, 'personalDay', cycleMap, 'personalDay'),
      ]);
    }

    final subjectKind = switch (_requiredString(
      payload,
      PersistedPythagoreanNumerologyPdfContract.subjectKindKey,
    )) {
      'profile' => PdfSubjectKind.profile,
      'client' => PdfSubjectKind.client,
      _ => throw const FormatException(
          'Persisted numerology subjectKind must be profile or client.',
        ),
    };

    return PdfCombinedMember(
      systemId: systemId,
      identity: PdfSnapshotIdentity(
        subjectKind: subjectKind,
        subjectId: snapshot.ownerEntityId,
        snapshotDigest: digest,
        engineVersion: snapshot.manifest.engineVersion,
        algorithmVersion: snapshot.manifest.algorithmVersion,
        dataVersion: snapshot.manifest.dataVersion,
        calculationManifestId: snapshot.manifest.id.value,
      ),
      sections: <PdfRenderSection>[
        PdfRenderSection(
          sectionId: PdfSectionIds.numerology,
          snapshotDigest: digest,
          title: '${labels['system']!} — ${labels['summary']!}',
          paragraphs: const <String>[],
          rows: List<List<String>>.unmodifiable(
            rows.map((row) => List<String>.unmodifiable(row)),
          ),
        ),
      ],
    );
  }
}

void _requireLocale(String localeTag) {
  if (localeTag != 'tr' && localeTag != 'en') {
    throw FormatException('Unsupported persisted combined PDF locale: $localeTag');
  }
}

String _requiredString(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$key must be a non-empty string.');
  }
  return value;
}

Map<String, Object?> _requiredMap(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! Map) {
    throw FormatException('$key must be an object.');
  }
  return value.map<String, Object?>((key, value) => MapEntry(key.toString(), value));
}

int _requiredInt(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! int) throw FormatException('$key must be an integer.');
  return value;
}

List<int> _requiredIntList(Map<String, Object?> map, String key) {
  final value = map[key];
  if (value is! List || value.any((item) => item is! int)) {
    throw FormatException('$key must be an integer list.');
  }
  return List<int>.unmodifiable(value.cast<int>());
}

List<String> _metricRow(
  Map<String, String> labels,
  String labelId,
  Map<String, Object?> map,
  String key,
) => <String>[labels[labelId]!, '${_requiredInt(map, key)}'];

const _numerologyLabels = <String, Map<String, String>>{
  'tr': <String, String>{
    'system': 'Numeroloji', 'summary': 'Pythagorean Özeti', 'metric': 'Gösterge',
    'value': 'Değer', 'lifePath': 'Yaşam Yolu', 'expression': 'Kader / İfade',
    'soulUrge': 'Ruh Arzusu', 'personality': 'Kişilik', 'birthday': 'Doğum Günü',
    'maturity': 'Olgunluk', 'balance': 'Denge', 'karmicLessons': 'Karmik Dersler',
    'hiddenPassions': 'Gizli Tutkular', 'pinnacles': 'Zirveler',
    'challenges': 'Zorluklar', 'personalYear': 'Kişisel Yıl',
    'personalMonth': 'Kişisel Ay', 'personalDay': 'Kişisel Gün',
  },
  'en': <String, String>{
    'system': 'Numerology', 'summary': 'Pythagorean Summary', 'metric': 'Metric',
    'value': 'Value', 'lifePath': 'Life Path', 'expression': 'Expression',
    'soulUrge': 'Soul Urge', 'personality': 'Personality', 'birthday': 'Birthday',
    'maturity': 'Maturity', 'balance': 'Balance', 'karmicLessons': 'Karmic Lessons',
    'hiddenPassions': 'Hidden Passions', 'pinnacles': 'Pinnacles',
    'challenges': 'Challenges', 'personalYear': 'Personal Year',
    'personalMonth': 'Personal Month', 'personalDay': 'Personal Day',
  },
};

const _westernLabels = <String, Map<String, String>>{
  'tr': <String, String>{
    'system': 'Batı Astrolojisi', 'placements': 'Gezegen Yerleşimleri',
    'houses': 'Ev Başlangıçları', 'aspects': 'Açılar', 'body': 'Gezegen',
    'sign': 'Burç', 'degree': 'Derece', 'house': 'Ev', 'motion': 'Hareket',
    'cusp': 'Başlangıç', 'aspect': 'Açı', 'separation': 'Ayrım', 'orb': 'Orb',
  },
  'en': <String, String>{
    'system': 'Western Astrology', 'placements': 'Planet Placements',
    'houses': 'House Cusps', 'aspects': 'Aspects', 'body': 'Planet',
    'sign': 'Sign', 'degree': 'Degree', 'house': 'House', 'motion': 'Motion',
    'cusp': 'Cusp', 'aspect': 'Aspect', 'separation': 'Separation', 'orb': 'Orb',
  },
};

const _bodyLabels = <String, Map<String, String>>{
  'tr': <String, String>{
    'sun': 'Güneş', 'moon': 'Ay', 'mercury': 'Merkür', 'venus': 'Venüs',
    'mars': 'Mars', 'jupiter': 'Jüpiter', 'saturn': 'Satürn', 'uranus': 'Uranüs',
    'neptune': 'Neptün', 'pluto': 'Plüton', 'northNode': 'Kuzey Ay Düğümü',
    'southNode': 'Güney Ay Düğümü',
  },
  'en': <String, String>{
    'sun': 'Sun', 'moon': 'Moon', 'mercury': 'Mercury', 'venus': 'Venus',
    'mars': 'Mars', 'jupiter': 'Jupiter', 'saturn': 'Saturn', 'uranus': 'Uranus',
    'neptune': 'Neptune', 'pluto': 'Pluto', 'northNode': 'North Node',
    'southNode': 'South Node',
  },
};
const _signLabels = <String, Map<String, String>>{
  'tr': <String, String>{
    'aries': 'Koç', 'taurus': 'Boğa', 'gemini': 'İkizler', 'cancer': 'Yengeç',
    'leo': 'Aslan', 'virgo': 'Başak', 'libra': 'Terazi', 'scorpio': 'Akrep',
    'sagittarius': 'Yay', 'capricorn': 'Oğlak', 'aquarius': 'Kova', 'pisces': 'Balık',
  },
  'en': <String, String>{
    'aries': 'Aries', 'taurus': 'Taurus', 'gemini': 'Gemini', 'cancer': 'Cancer',
    'leo': 'Leo', 'virgo': 'Virgo', 'libra': 'Libra', 'scorpio': 'Scorpio',
    'sagittarius': 'Sagittarius', 'capricorn': 'Capricorn', 'aquarius': 'Aquarius',
    'pisces': 'Pisces',
  },
};
const _motionLabels = <String, Map<String, String>>{
  'tr': <String, String>{'direct': 'Direkt', 'retrograde': 'Retro', 'stationary': 'Durağan'},
  'en': <String, String>{'direct': 'Direct', 'retrograde': 'Retrograde', 'stationary': 'Stationary'},
};
const _aspectLabels = <String, Map<String, String>>{
  'tr': <String, String>{
    'conjunction': 'Kavuşum', 'sextile': 'Sekstil', 'square': 'Kare',
    'trine': 'Üçgen', 'opposition': 'Karşıt',
  },
  'en': <String, String>{
    'conjunction': 'Conjunction', 'sextile': 'Sextile', 'square': 'Square',
    'trine': 'Trine', 'opposition': 'Opposition',
  },
};
