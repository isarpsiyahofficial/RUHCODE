enum TerminologyId {
  ascendant,
  midheaven,
  house,
  natalChart,
  transit,
  aspect,
  conjunction,
  opposition,
  square,
  trine,
  sextile,
  retrograde,
  tropical,
  sidereal,
  lagna,
  nakshatra,
  pada,
  dasha,
  mahadasha,
  antardasha,
  ayanamsha,
  tithi,
  karana,
  lifePath,
  expressionNumber,
  soulUrge,
  personalityNumber,
  birthdayNumber,
  maturityNumber,
  personalYear,
  personalMonth,
  personalDay,
  karmicDebt,
  compatibility,
}

final class TerminologyEntry {
  const TerminologyEntry({
    required this.id,
    required this.en,
    required this.tr,
    required this.category,
    this.preferredTechnicalLabel,
  });

  final TerminologyId id;
  final String en;
  final String tr;
  final String category;

  /// Optional professional label retained when translating the term would make
  /// it less precise. UI may show `tr` plus this label, never replace the
  /// canonical translation with an unrelated synonym.
  final String? preferredTechnicalLabel;
}

abstract final class RuhTerminologyGlossary {
  static const String version = 'terminology.v1';

  static const Map<TerminologyId, TerminologyEntry> entries =
      <TerminologyId, TerminologyEntry>{
    TerminologyId.ascendant: TerminologyEntry(
      id: TerminologyId.ascendant,
      en: 'Ascendant',
      tr: 'Yükselen',
      category: 'western',
      preferredTechnicalLabel: 'ASC',
    ),
    TerminologyId.midheaven: TerminologyEntry(
      id: TerminologyId.midheaven,
      en: 'Midheaven',
      tr: 'Tepe Noktası',
      category: 'western',
      preferredTechnicalLabel: 'MC',
    ),
    TerminologyId.house: TerminologyEntry(
      id: TerminologyId.house,
      en: 'House',
      tr: 'Ev',
      category: 'western',
    ),
    TerminologyId.natalChart: TerminologyEntry(
      id: TerminologyId.natalChart,
      en: 'Natal Chart',
      tr: 'Doğum Haritası',
      category: 'western',
    ),
    TerminologyId.transit: TerminologyEntry(
      id: TerminologyId.transit,
      en: 'Transit',
      tr: 'Transit',
      category: 'western',
    ),
    TerminologyId.aspect: TerminologyEntry(
      id: TerminologyId.aspect,
      en: 'Aspect',
      tr: 'Açı',
      category: 'western',
    ),
    TerminologyId.conjunction: TerminologyEntry(
      id: TerminologyId.conjunction,
      en: 'Conjunction',
      tr: 'Kavuşum',
      category: 'western',
    ),
    TerminologyId.opposition: TerminologyEntry(
      id: TerminologyId.opposition,
      en: 'Opposition',
      tr: 'Karşıt',
      category: 'western',
    ),
    TerminologyId.square: TerminologyEntry(
      id: TerminologyId.square,
      en: 'Square',
      tr: 'Kare',
      category: 'western',
    ),
    TerminologyId.trine: TerminologyEntry(
      id: TerminologyId.trine,
      en: 'Trine',
      tr: 'Üçgen',
      category: 'western',
    ),
    TerminologyId.sextile: TerminologyEntry(
      id: TerminologyId.sextile,
      en: 'Sextile',
      tr: 'Sekstil',
      category: 'western',
    ),
    TerminologyId.retrograde: TerminologyEntry(
      id: TerminologyId.retrograde,
      en: 'Retrograde',
      tr: 'Retrograd',
      category: 'western',
    ),
    TerminologyId.tropical: TerminologyEntry(
      id: TerminologyId.tropical,
      en: 'Tropical Zodiac',
      tr: 'Tropikal Zodyak',
      category: 'western',
    ),
    TerminologyId.sidereal: TerminologyEntry(
      id: TerminologyId.sidereal,
      en: 'Sidereal Zodiac',
      tr: 'Sidereal Zodyak',
      category: 'vedic',
    ),
    TerminologyId.lagna: TerminologyEntry(
      id: TerminologyId.lagna,
      en: 'Lagna',
      tr: 'Lagna',
      category: 'vedic',
      preferredTechnicalLabel: 'Lagna / Ascendant',
    ),
    TerminologyId.nakshatra: TerminologyEntry(
      id: TerminologyId.nakshatra,
      en: 'Nakshatra',
      tr: 'Nakshatra',
      category: 'vedic',
    ),
    TerminologyId.pada: TerminologyEntry(
      id: TerminologyId.pada,
      en: 'Pada',
      tr: 'Pada',
      category: 'vedic',
    ),
    TerminologyId.dasha: TerminologyEntry(
      id: TerminologyId.dasha,
      en: 'Dasha',
      tr: 'Dasha',
      category: 'vedic',
    ),
    TerminologyId.mahadasha: TerminologyEntry(
      id: TerminologyId.mahadasha,
      en: 'Mahadasha',
      tr: 'Mahadasha',
      category: 'vedic',
    ),
    TerminologyId.antardasha: TerminologyEntry(
      id: TerminologyId.antardasha,
      en: 'Antardasha',
      tr: 'Antardasha',
      category: 'vedic',
    ),
    TerminologyId.ayanamsha: TerminologyEntry(
      id: TerminologyId.ayanamsha,
      en: 'Ayanamsha',
      tr: 'Ayanamsha',
      category: 'vedic',
    ),
    TerminologyId.tithi: TerminologyEntry(
      id: TerminologyId.tithi,
      en: 'Tithi',
      tr: 'Tithi',
      category: 'vedic',
    ),
    TerminologyId.karana: TerminologyEntry(
      id: TerminologyId.karana,
      en: 'Karana',
      tr: 'Karana',
      category: 'vedic',
    ),
    TerminologyId.lifePath: TerminologyEntry(
      id: TerminologyId.lifePath,
      en: 'Life Path',
      tr: 'Yaşam Yolu',
      category: 'numerology',
    ),
    TerminologyId.expressionNumber: TerminologyEntry(
      id: TerminologyId.expressionNumber,
      en: 'Expression Number',
      tr: 'İfade Sayısı',
      category: 'numerology',
      preferredTechnicalLabel: 'Expression / Destiny',
    ),
    TerminologyId.soulUrge: TerminologyEntry(
      id: TerminologyId.soulUrge,
      en: 'Soul Urge',
      tr: 'Ruh Arzusu',
      category: 'numerology',
    ),
    TerminologyId.personalityNumber: TerminologyEntry(
      id: TerminologyId.personalityNumber,
      en: 'Personality Number',
      tr: 'Kişilik Sayısı',
      category: 'numerology',
    ),
    TerminologyId.birthdayNumber: TerminologyEntry(
      id: TerminologyId.birthdayNumber,
      en: 'Birthday Number',
      tr: 'Doğum Günü Sayısı',
      category: 'numerology',
    ),
    TerminologyId.maturityNumber: TerminologyEntry(
      id: TerminologyId.maturityNumber,
      en: 'Maturity Number',
      tr: 'Olgunluk Sayısı',
      category: 'numerology',
    ),
    TerminologyId.personalYear: TerminologyEntry(
      id: TerminologyId.personalYear,
      en: 'Personal Year',
      tr: 'Kişisel Yıl',
      category: 'numerology',
    ),
    TerminologyId.personalMonth: TerminologyEntry(
      id: TerminologyId.personalMonth,
      en: 'Personal Month',
      tr: 'Kişisel Ay',
      category: 'numerology',
    ),
    TerminologyId.personalDay: TerminologyEntry(
      id: TerminologyId.personalDay,
      en: 'Personal Day',
      tr: 'Kişisel Gün',
      category: 'numerology',
    ),
    TerminologyId.karmicDebt: TerminologyEntry(
      id: TerminologyId.karmicDebt,
      en: 'Karmic Debt',
      tr: 'Karmik Borç',
      category: 'numerology',
    ),
    TerminologyId.compatibility: TerminologyEntry(
      id: TerminologyId.compatibility,
      en: 'Compatibility',
      tr: 'Uyumluluk',
      category: 'numerology',
    ),
  };

  static String label(TerminologyId id, String localeTag) {
    final entry = entries[id];
    if (entry == null) {
      throw StateError('Missing terminology entry: ${id.name}');
    }
    return switch (localeTag) {
      'tr' => entry.tr,
      'en' => entry.en,
      _ => throw ArgumentError.value(
          localeTag,
          'localeTag',
          'Terminology v1 supports only tr and en.',
        ),
    };
  }

  static void validateComplete() {
    if (entries.length != TerminologyId.values.length) {
      throw StateError('Every TerminologyId must have exactly one entry.');
    }
    for (final id in TerminologyId.values) {
      final entry = entries[id];
      if (entry == null || entry.id != id) {
        throw StateError('Terminology entry mismatch: ${id.name}');
      }
      if (entry.tr.trim().isEmpty || entry.en.trim().isEmpty) {
        throw StateError('Terminology labels cannot be blank: ${id.name}');
      }
      if (entry.category.trim().isEmpty) {
        throw StateError('Terminology category cannot be blank: ${id.name}');
      }
    }
  }
}
