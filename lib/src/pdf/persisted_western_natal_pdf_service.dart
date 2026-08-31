import 'pdf_cover_section.dart';
import 'pdf_data_contract.dart';
import 'pdf_local_renderer.dart';
import 'pdf_local_service.dart';
import 'pdf_report_contract.dart';
import 'pdf_service.dart';
import 'persisted_calculation_pdf_source.dart';
import 'persisted_manifest_section.dart';
import 'persisted_western_natal_pdf.dart';
import 'persisted_western_natal_sections.dart';
import 'persisted_western_natal_snapshot.dart';

/// Production professional-PDF handler for persisted Western natal records.
///
/// The handler never recomputes astronomy. It validates the sealed persisted
/// snapshot, projects placements/houses/aspects and the linked technical
/// manifest, then hands those immutable sections to the local PDF renderer.
final class PersistedWesternNatalPdfService
    implements PdfService<PersistedCalculationPdfSnapshot> {
  const PersistedWesternNatalPdfService({required this.fontProvider});

  final PdfFontBundleProvider fontProvider;

  @override
  Future<List<int>> buildReport({
    required PersistedCalculationPdfSnapshot snapshot,
    required PdfReportOptions options,
  }) {
    final parsed = PersistedWesternNatalPdfReader.read(snapshot);
    final adapter = _PersistedWesternNatalContentAdapter(
      localeTag: options.localeTag,
      parsed: parsed,
      persisted: snapshot,
    );
    return PdfLocalReportService<PersistedCalculationPdfSnapshot>(
      adapter: adapter,
      fontProvider: fontProvider,
    ).buildReport(snapshot: snapshot, options: options);
  }
}

final class _PersistedWesternNatalContentAdapter
    implements PdfReportContentAdapter<PersistedCalculationPdfSnapshot> {
  const _PersistedWesternNatalContentAdapter({
    required this.localeTag,
    required this.parsed,
    required this.persisted,
  });

  final String localeTag;
  final PersistedWesternNatalPdfData parsed;
  final PersistedCalculationPdfSnapshot persisted;

  @override
  PdfReportKind get reportKind => PdfReportKind.western;

  @override
  PdfDataOrigin get dataOrigin => PdfDataOrigin.user;

  @override
  PdfCoverStyle get coverStyle => PdfCoverStyle.professional;

  @override
  String documentTitle(PersistedCalculationPdfSnapshot snapshot, String locale) {
    _validateLocale(locale);
    if (locale != localeTag) {
      throw StateError('Western PDF adapter locale drift detected.');
    }
    return locale == 'tr' ? 'Batı Astrolojisi Doğum Haritası Raporu' : 'Western Natal Chart Report';
  }

  @override
  PdfReportDataset dataset(PersistedCalculationPdfSnapshot snapshot) {
    _requireSameRecord(snapshot);
    final digest = parsed.snapshotSha256;
    return PdfReportDataset(
      origin: PdfDataOrigin.user,
      identity: PdfSnapshotIdentity(
        subjectKind: PdfSubjectKind.profile,
        subjectId: snapshot.ownerEntityId,
        snapshotDigest: digest,
        engineVersion: snapshot.manifest.engineVersion,
        algorithmVersion: snapshot.manifest.algorithmVersion,
        dataVersion: snapshot.manifest.dataVersion,
        calculationManifestId: snapshot.manifest.id.value,
      ),
      sections: <PdfSectionDataRef>[
        PdfCoverSectionAdapter.dataRef(snapshotDigest: digest),
        PdfSectionDataRef(
          sectionId: PdfSectionIds.placements,
          snapshotDigest: digest,
          hasContent: parsed.snapshot.placements.isNotEmpty,
        ),
        PdfSectionDataRef(
          sectionId: PdfSectionIds.houses,
          snapshotDigest: digest,
          hasContent: parsed.snapshot.houseCuspsDeg.isNotEmpty,
        ),
        PdfSectionDataRef(
          sectionId: PdfSectionIds.aspects,
          snapshotDigest: digest,
          hasContent: parsed.snapshot.aspects.isNotEmpty,
        ),
        PdfSectionDataRef(
          sectionId: PdfSectionIds.technicalManifest,
          snapshotDigest: digest,
          hasContent: true,
        ),
      ],
    );
  }

  @override
  List<PdfRenderSection> sections(PersistedCalculationPdfSnapshot snapshot) {
    _validateLocale(localeTag);
    _requireSameRecord(snapshot);
    final labels = _labels[localeTag]!;
    final envelope = PersistedWesternNatalEnvelope.seal(parsed.snapshot);
    if (envelope.snapshotSha256 != parsed.snapshotSha256) {
      throw const FormatException('Western persisted snapshot digest drift detected.');
    }

    final sections = PersistedWesternNatalSectionAdapter.build(
      envelope: envelope,
      placementsTitle: labels['placementsTitle']!,
      housesTitle: labels['housesTitle']!,
      aspectsTitle: labels['aspectsTitle']!,
      bodyHeader: labels['bodyHeader']!,
      signHeader: labels['signHeader']!,
      degreeHeader: labels['degreeHeader']!,
      houseHeader: labels['houseHeader']!,
      motionHeader: labels['motionHeader']!,
      cuspHeader: labels['cuspHeader']!,
      aspectHeader: labels['aspectHeader']!,
      separationHeader: labels['separationHeader']!,
      orbHeader: labels['orbHeader']!,
      bodyLabel: (id) => _bodyLabels[localeTag]?[id] ?? '',
      signLabel: (id) => _signLabels[localeTag]?[id] ?? '',
      motionLabel: (id) => _motionLabels[localeTag]?[id] ?? '',
      aspectLabel: (id) => _aspectLabels[localeTag]?[id] ?? '',
    );

    return List<PdfRenderSection>.unmodifiable(<PdfRenderSection>[
      PdfCoverSectionAdapter.build(
        snapshotDigest: parsed.snapshotSha256,
        title: labels['coverTitle']!,
      ),
      ...sections,
      PersistedManifestSectionAdapter.build(
        manifest: snapshot.manifest,
        snapshotDigest: parsed.snapshotSha256,
        title: labels['technicalTitle']!,
        fieldHeader: labels['fieldHeader']!,
        valueHeader: labels['valueHeader']!,
        labelForField: (id) => _manifestFieldLabels[localeTag]?[id] ?? '',
      ),
    ]);
  }

  void _requireSameRecord(PersistedCalculationPdfSnapshot snapshot) {
    if (snapshot.recordId != parsed.recordId ||
        snapshot.ownerEntityId != parsed.ownerEntityId ||
        snapshot.calculationType != persistedWesternNatalCalculationType ||
        snapshot.recordId != persisted.recordId) {
      throw StateError('Western PDF persisted record identity drift detected.');
    }
  }

  static void _validateLocale(String locale) {
    if (locale != 'tr' && locale != 'en') {
      throw FormatException('Unsupported professional Western PDF locale: $locale');
    }
  }

  static const _labels = <String, Map<String, String>>{
    'tr': <String, String>{
      'coverTitle': 'Batı Astrolojisi Doğum Haritası Raporu',
      'placementsTitle': 'Gezegen Yerleşimleri',
      'housesTitle': 'Ev Başlangıçları',
      'aspectsTitle': 'Açılar',
      'bodyHeader': 'Gezegen',
      'signHeader': 'Burç',
      'degreeHeader': 'Derece',
      'houseHeader': 'Ev',
      'motionHeader': 'Hareket',
      'cuspHeader': 'Başlangıç',
      'aspectHeader': 'Açı',
      'separationHeader': 'Ayrım',
      'orbHeader': 'Orb',
      'technicalTitle': 'Hesaplama Bilgileri',
      'fieldHeader': 'Alan',
      'valueHeader': 'Değer',
    },
    'en': <String, String>{
      'coverTitle': 'Western Natal Chart Report',
      'placementsTitle': 'Planet Placements',
      'housesTitle': 'House Cusps',
      'aspectsTitle': 'Aspects',
      'bodyHeader': 'Planet',
      'signHeader': 'Sign',
      'degreeHeader': 'Degree',
      'houseHeader': 'House',
      'motionHeader': 'Motion',
      'cuspHeader': 'Cusp',
      'aspectHeader': 'Aspect',
      'separationHeader': 'Separation',
      'orbHeader': 'Orb',
      'technicalTitle': 'Calculation Details',
      'fieldHeader': 'Field',
      'valueHeader': 'Value',
    },
  };

  static const _bodyLabels = <String, Map<String, String>>{
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

  static const _signLabels = <String, Map<String, String>>{
    'tr': <String, String>{
      'aries': 'Koç', 'taurus': 'Boğa', 'gemini': 'İkizler', 'cancer': 'Yengeç',
      'leo': 'Aslan', 'virgo': 'Başak', 'libra': 'Terazi', 'scorpio': 'Akrep',
      'sagittarius': 'Yay', 'capricorn': 'Oğlak', 'aquarius': 'Kova', 'pisces': 'Balık',
    },
    'en': <String, String>{
      'aries': 'Aries', 'taurus': 'Taurus', 'gemini': 'Gemini', 'cancer': 'Cancer',
      'leo': 'Leo', 'virgo': 'Virgo', 'libra': 'Libra', 'scorpio': 'Scorpio',
      'sagittarius': 'Sagittarius', 'capricorn': 'Capricorn', 'aquarius': 'Aquarius', 'pisces': 'Pisces',
    },
  };

  static const _motionLabels = <String, Map<String, String>>{
    'tr': <String, String>{'direct': 'Direkt', 'retrograde': 'Retro', 'stationary': 'Durağan'},
    'en': <String, String>{'direct': 'Direct', 'retrograde': 'Retrograde', 'stationary': 'Stationary'},
  };

  static const _aspectLabels = <String, Map<String, String>>{
    'tr': <String, String>{
      'conjunction': 'Kavuşum', 'sextile': 'Sekstil', 'square': 'Kare',
      'trine': 'Üçgen', 'opposition': 'Karşıt',
    },
    'en': <String, String>{
      'conjunction': 'Conjunction', 'sextile': 'Sextile', 'square': 'Square',
      'trine': 'Trine', 'opposition': 'Opposition',
    },
  };

  static const _manifestFieldLabels = <String, Map<String, String>>{
    'tr': <String, String>{
      'engineId': 'Motor', 'engineVersion': 'Motor Sürümü', 'algorithmVersion': 'Algoritma Sürümü',
      'dataVersion': 'Veri Sürümü', 'timezoneDatabaseVersion': 'Zaman Dilimi Verisi',
      'localDateTime': 'Yerel Tarih/Saat', 'utcDateTime': 'UTC Tarih/Saat',
      'locationLabel': 'Konum', 'countryCode': 'Ülke Kodu', 'latitude': 'Enlem',
      'longitude': 'Boylam', 'ianaTimeZoneId': 'IANA Zaman Dilimi', 'validity': 'Geçerlilik',
      'houseSystemId': 'Ev Sistemi', 'zodiacSystemId': 'Zodyak Sistemi',
      'ayanamshaId': 'Ayanamsha', 'nodeModeId': 'Ay Düğümü Modu',
    },
    'en': <String, String>{
      'engineId': 'Engine', 'engineVersion': 'Engine Version', 'algorithmVersion': 'Algorithm Version',
      'dataVersion': 'Data Version', 'timezoneDatabaseVersion': 'Time Zone Data',
      'localDateTime': 'Local Date/Time', 'utcDateTime': 'UTC Date/Time',
      'locationLabel': 'Location', 'countryCode': 'Country Code', 'latitude': 'Latitude',
      'longitude': 'Longitude', 'ianaTimeZoneId': 'IANA Time Zone', 'validity': 'Validity',
      'houseSystemId': 'House System', 'zodiacSystemId': 'Zodiac System',
      'ayanamshaId': 'Ayanamsha', 'nodeModeId': 'Node Mode',
    },
  };
}
