enum CalculationValidity { valid, partial, unavailable, error }

enum CalculationFeature {
  ascendant,
  houses,
  vedicHourSensitive,
  planetaryHours,
  dateOnlyAstrology,
  numerology,
}

enum GoldenEdgeCase {
  signBoundary,
  longitudeNearTwentyNineFiftyNine,
  longitudeNearZero,
  nakshatraBoundary,
  padaBoundary,
  houseCuspBoundary,
  retrogradeStation,
  sunriseBoundary,
  sunsetBoundary,
  dstSpringForward,
  dstFallBack,
  historicalTimezoneChange,
  halfHourTimezone,
  fortyFiveMinuteTimezone,
  utcPlusFourteen,
  internationalDateLine,
  polarCircle,
  polarDayOrNight,
}

class CalculationOutcome<T> {
  CalculationOutcome._({
    required this.validity,
    required this.value,
    required this.reasonCode,
    required this.messageTr,
    required this.messageEn,
    required this.determinismKey,
  }) {
    _validate();
  }

  factory CalculationOutcome.valid({
    required T value,
    required String determinismKey,
  }) =>
      CalculationOutcome._(
        validity: CalculationValidity.valid,
        value: value,
        reasonCode: null,
        messageTr: null,
        messageEn: null,
        determinismKey: determinismKey,
      );

  factory CalculationOutcome.partial({
    required T value,
    required String reasonCode,
    required String messageTr,
    required String messageEn,
    required String determinismKey,
  }) =>
      CalculationOutcome._(
        validity: CalculationValidity.partial,
        value: value,
        reasonCode: reasonCode,
        messageTr: messageTr,
        messageEn: messageEn,
        determinismKey: determinismKey,
      );

  factory CalculationOutcome.unavailable({
    required String reasonCode,
    required String messageTr,
    required String messageEn,
    required String determinismKey,
  }) =>
      CalculationOutcome._(
        validity: CalculationValidity.unavailable,
        value: null,
        reasonCode: reasonCode,
        messageTr: messageTr,
        messageEn: messageEn,
        determinismKey: determinismKey,
      );

  factory CalculationOutcome.error({
    required String reasonCode,
    required String messageTr,
    required String messageEn,
    required String determinismKey,
  }) =>
      CalculationOutcome._(
        validity: CalculationValidity.error,
        value: null,
        reasonCode: reasonCode,
        messageTr: messageTr,
        messageEn: messageEn,
        determinismKey: determinismKey,
      );

  final CalculationValidity validity;
  final T? value;
  final String? reasonCode;
  final String? messageTr;
  final String? messageEn;
  final String determinismKey;

  bool get hasUsableValue =>
      validity == CalculationValidity.valid ||
      validity == CalculationValidity.partial;

  String localizedMessage(String languageCode) {
    final text = languageCode.toLowerCase() == 'tr' ? messageTr : messageEn;
    return _sanitizeUserText(text ?? '');
  }

  void _validate() {
    if (determinismKey.trim().isEmpty) {
      throw ArgumentError('determinismKey is required');
    }
    switch (validity) {
      case CalculationValidity.valid:
        if (value == null) {
          throw ArgumentError('valid outcome requires a value');
        }
        if (reasonCode != null || messageTr != null || messageEn != null) {
          throw ArgumentError('valid outcome cannot carry an error reason');
        }
      case CalculationValidity.partial:
        if (value == null ||
            reasonCode == null ||
            messageTr == null ||
            messageEn == null) {
          throw ArgumentError('partial outcome requires value and reason');
        }
      case CalculationValidity.unavailable:
      case CalculationValidity.error:
        if (value != null ||
            reasonCode == null ||
            messageTr == null ||
            messageEn == null) {
          throw ArgumentError(
            'unavailable/error outcome requires no value and a reason',
          );
        }
    }
  }

  static String _sanitizeUserText(String text) {
    final lower = text.trim().toLowerCase();
    if (lower == 'null' || lower == 'nan') {
      return '';
    }
    return text;
  }
}

class MissingBirthTimePolicy {
  const MissingBirthTimePolicy();

  CalculationOutcome<bool> availabilityFor({
    required CalculationFeature feature,
    required bool birthTimeKnown,
    required String determinismKey,
  }) {
    if (birthTimeKnown) {
      return CalculationOutcome.valid(
        value: true,
        determinismKey: determinismKey,
      );
    }

    switch (feature) {
      case CalculationFeature.ascendant:
      case CalculationFeature.houses:
      case CalculationFeature.vedicHourSensitive:
        return CalculationOutcome.unavailable(
          reasonCode: 'birth_time_required',
          messageTr:
              'Doğum saati bilinmediği için bu sonuç hesaplanamıyor.',
          messageEn:
              'This result is unavailable because the birth time is unknown.',
          determinismKey: determinismKey,
        );
      case CalculationFeature.planetaryHours:
      case CalculationFeature.dateOnlyAstrology:
      case CalculationFeature.numerology:
        return CalculationOutcome.partial(
          value: true,
          reasonCode: 'birth_time_unknown_but_feature_available',
          messageTr:
              'Doğum saati bilinmiyor; yalnız saat gerektirmeyen sonuçlar gösteriliyor.',
          messageEn:
              'Birth time is unknown; only results that do not require it are shown.',
          determinismKey: determinismKey,
        );
    }
  }
}

class SolarBoundaryObservation {
  const SolarBoundaryObservation({
    required this.sunriseUtc,
    required this.sunsetUtc,
    required this.reasonCode,
  });

  final DateTime? sunriseUtc;
  final DateTime? sunsetUtc;
  final String? reasonCode;

  bool get hasCompleteDaylightBoundary =>
      sunriseUtc != null && sunsetUtc != null;
}

class PlanetaryHourAvailabilityPolicy {
  const PlanetaryHourAvailabilityPolicy();

  CalculationOutcome<SolarBoundaryObservation> evaluate({
    required SolarBoundaryObservation observation,
    required String determinismKey,
  }) {
    if (observation.hasCompleteDaylightBoundary) {
      return CalculationOutcome.valid(
        value: observation,
        determinismKey: determinismKey,
      );
    }
    return CalculationOutcome.unavailable(
      reasonCode: observation.reasonCode ?? 'solar_boundary_unavailable',
      messageTr:
          'Bu konum ve tarihte güvenilir gün doğumu/gün batımı sınırı bulunamadığı için gezegen saati hesaplanamıyor.',
      messageEn:
          'Planetary hours are unavailable because a reliable sunrise/sunset boundary does not exist for this location and date.',
      determinismKey: determinismKey,
    );
  }
}

class CalculationDeterminismKey {
  const CalculationDeterminismKey({
    required this.engineVersion,
    required this.algorithmVersion,
    required this.inputFingerprint,
    required this.configurationFingerprint,
  });

  final String engineVersion;
  final String algorithmVersion;
  final String inputFingerprint;
  final String configurationFingerprint;

  String get value =>
      '$engineVersion|$algorithmVersion|$inputFingerprint|$configurationFingerprint';
}

class DeterminismGuard {
  const DeterminismGuard();

  void requireSameOutcome<T>(
    CalculationOutcome<T> first,
    CalculationOutcome<T> second,
  ) {
    if (first.determinismKey != second.determinismKey) {
      throw ArgumentError('determinism keys differ');
    }
    if (first.validity != second.validity ||
        first.value != second.value ||
        first.reasonCode != second.reasonCode) {
      throw StateError(
        'same input and engine version produced a different outcome',
      );
    }
  }
}
