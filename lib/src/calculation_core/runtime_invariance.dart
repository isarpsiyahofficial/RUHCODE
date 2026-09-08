/// Runtime invariants for RC-1040..RC-1058.
///
/// Calculation inputs must be explicit and canonical. Device model, UI locale,
/// decimal separator and ambient system timezone are deliberately absent from
/// this boundary so they cannot silently influence mathematical results.
class StoredCalculationContext {
  const StoredCalculationContext({
    required this.subjectId,
    required this.localDateTimeIso,
    required this.timezoneId,
    required this.utcInstant,
  }) {
    if (subjectId.trim().isEmpty) {
      throw ArgumentError('subjectId is required');
    }
    if (timezoneId.trim().isEmpty || !timezoneId.contains('/')) {
      throw ArgumentError('an explicit IANA timezoneId is required');
    }
    if (!utcInstant.isUtc) {
      throw ArgumentError('utcInstant must be UTC');
    }
    if (!_canonicalLocalDateTime.hasMatch(localDateTimeIso)) {
      throw ArgumentError('localDateTimeIso must be canonical YYYY-MM-DDTHH:mm:ss');
    }
  }

  final String subjectId;
  final String localDateTimeIso;
  final String timezoneId;
  final DateTime utcInstant;

  static final RegExp _canonicalLocalDateTime = RegExp(
    r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}$',
  );

  String get deterministicFingerprint =>
      '$subjectId|$localDateTimeIso|$timezoneId|${utcInstant.toIso8601String()}';
}

/// Explicit context for calculations whose meaning is genuinely "now".
///
/// Callers must resolve the current timezone and UTC instant before entering
/// the calculation core. The core never reaches into platform/system state.
class CurrentCalculationContext {
  const CurrentCalculationContext({
    required this.timezoneId,
    required this.utcNow,
  }) {
    if (timezoneId.trim().isEmpty || !timezoneId.contains('/')) {
      throw ArgumentError('an explicit IANA timezoneId is required');
    }
    if (!utcNow.isUtc) {
      throw ArgumentError('utcNow must be UTC');
    }
  }

  final String timezoneId;
  final DateTime utcNow;
}

/// Canonical decimal crossing the calculation-core boundary.
///
/// Localized text such as `12,5` must be normalized in the UI/input adapter,
/// not interpreted differently inside mathematical code according to locale.
class CanonicalDecimal {
  const CanonicalDecimal._(this.value, this.canonicalText);

  factory CanonicalDecimal.parse(String text) {
    final normalized = text.trim();
    if (!_canonicalPattern.hasMatch(normalized)) {
      throw FormatException(
        'calculation core accepts only locale-independent canonical decimals',
      );
    }
    final value = double.parse(normalized);
    if (!value.isFinite) {
      throw FormatException('non-finite numeric input is forbidden');
    }
    return CanonicalDecimal._(value, normalized);
  }

  final double value;
  final String canonicalText;

  static final RegExp _canonicalPattern = RegExp(r'^-?(?:\d+)(?:\.\d+)?$');
}

/// Snapshot used to prove that platform presentation settings are not part of
/// calculation identity. These fields may vary while [calculationKey] remains
/// unchanged for the same stored calculation.
class PresentationEnvironment {
  const PresentationEnvironment({
    required this.languageCode,
    required this.systemTimezoneId,
    required this.deviceModel,
    required this.decimalSeparator,
  });

  final String languageCode;
  final String systemTimezoneId;
  final String deviceModel;
  final String decimalSeparator;
}

class RuntimeInvariantCalculationKey {
  const RuntimeInvariantCalculationKey();

  String forStored({
    required StoredCalculationContext context,
    required String engineVersion,
    required String algorithmVersion,
    required List<CanonicalDecimal> numericInputs,
  }) {
    if (engineVersion.trim().isEmpty || algorithmVersion.trim().isEmpty) {
      throw ArgumentError('engine and algorithm versions are required');
    }
    final numbers = numericInputs.map((e) => e.canonicalText).join(',');
    return '$engineVersion|$algorithmVersion|${context.deterministicFingerprint}|$numbers';
  }
}

/// TR/EN localization parity is enforced with exact key equality.
class LocalizationCatalogPair {
  LocalizationCatalogPair({
    required Map<String, String> tr,
    required Map<String, String> en,
  })  : tr = Map.unmodifiable(tr),
        en = Map.unmodifiable(en) {
    _validate();
  }

  final Map<String, String> tr;
  final Map<String, String> en;

  void _validate() {
    final trKeys = tr.keys.toSet();
    final enKeys = en.keys.toSet();
    if (trKeys.length != tr.length || enKeys.length != en.length) {
      throw StateError('duplicate localization keys are forbidden');
    }
    final missingInEnglish = trKeys.difference(enKeys);
    final missingInTurkish = enKeys.difference(trKeys);
    if (missingInEnglish.isNotEmpty || missingInTurkish.isNotEmpty) {
      throw StateError(
        'TR/EN localization key parity failed: '
        'missingInEnglish=$missingInEnglish missingInTurkish=$missingInTurkish',
      );
    }
    for (final key in trKeys) {
      if (tr[key]!.trim().isEmpty || en[key]!.trim().isEmpty) {
        throw StateError('empty localized system text is forbidden: $key');
      }
    }
  }

  String systemText(String key, String languageCode) {
    final catalog = languageCode.toLowerCase() == 'tr' ? tr : en;
    final value = catalog[key];
    if (value == null) {
      throw StateError('missing localization key: $key');
    }
    return value;
  }
}

/// User-authored data is opaque content, never a localization key.
class UserDataLocalizationBoundary {
  const UserDataLocalizationBoundary();

  String preserveName(String value) => value;
  String preserveNote(String value) => value;
  String preserveUserText(String value) => value;
}
