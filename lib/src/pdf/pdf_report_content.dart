import '../data/central_record_model.dart';
import 'pdf_report_contract.dart';

enum PdfSubjectDetailLevel { clientFriendly, technical }

final class PdfSubjectReportData {
  PdfSubjectReportData({
    required this.displayName,
    required this.birthData,
    this.calculationManifest,
  }) {
    if (displayName.trim().isEmpty) {
      throw ArgumentError('PDF subject display name cannot be blank.');
    }
  }

  final String displayName;
  final BirthData birthData;
  final CalculationManifestRecord? calculationManifest;

  String birthDateLabel(String localeTag) {
    final d = birthData.birthDate;
    if (_isTr(localeTag)) {
      return '${_two(d.day)}.${_two(d.month)}.${d.year.toString().padLeft(4, '0')}';
    }
    return '${d.year.toString().padLeft(4, '0')}-${_two(d.month)}-${_two(d.day)}';
  }

  String birthTimeLabel(String localeTag) {
    if (birthData.timePrecision == BirthTimePrecision.unknown) {
      return _isTr(localeTag) ? 'Bilinmiyor' : 'Unknown';
    }
    final local = birthData.localBirthDateTime;
    if (local == null) {
      throw StateError('Known birth-time precision requires local birth date-time.');
    }
    final time = '${_two(local.hour)}:${_two(local.minute)}';
    if (birthData.timePrecision == BirthTimePrecision.approximate) {
      return _isTr(localeTag) ? 'Yaklaşık $time' : 'Approx. $time';
    }
    return time;
  }

  String get birthPlaceLabel => birthData.birthPlace.displayText;
  String get timezoneLabel => birthData.birthPlace.ianaTimezoneId;

  String coordinatesLabel() =>
      '${birthData.birthPlace.latitude.toStringAsFixed(6)}, ${birthData.birthPlace.longitude.toStringAsFixed(6)}';

  PdfCalculationManifestSummary? technicalSummary() {
    final manifest = calculationManifest;
    if (manifest == null) return null;
    return PdfCalculationManifestSummary.fromRecord(manifest);
  }

  static bool _isTr(String localeTag) => localeTag.toLowerCase().startsWith('tr');
  static String _two(int value) => value.toString().padLeft(2, '0');
}

final class PdfCalculationManifestSummary {
  const PdfCalculationManifestSummary({
    required this.engineVersion,
    required this.algorithmVersion,
    required this.dataVersion,
    required this.timezoneDatabaseVersion,
    required this.zodiacSystem,
    required this.houseSystem,
    required this.nodeMode,
    required this.utcDateTime,
    required this.localDateTimeIso,
    this.ayanamsha,
  });

  factory PdfCalculationManifestSummary.fromRecord(CalculationManifestRecord record) =>
      PdfCalculationManifestSummary(
        engineVersion: record.engineVersion,
        algorithmVersion: record.algorithmVersion,
        dataVersion: record.dataVersion,
        timezoneDatabaseVersion: record.timezoneDatabaseVersion,
        zodiacSystem: record.zodiacSystem,
        houseSystem: record.houseSystem,
        ayanamsha: record.ayanamsha,
        nodeMode: record.nodeMode,
        utcDateTime: record.utcDateTime,
        localDateTimeIso: record.localDateTimeIso,
      );

  final String engineVersion;
  final String algorithmVersion;
  final String dataVersion;
  final String timezoneDatabaseVersion;
  final String zodiacSystem;
  final String houseSystem;
  final String? ayanamsha;
  final String nodeMode;
  final DateTime utcDateTime;
  final String localDateTimeIso;

  Map<String, String> asFields() {
    final fields = <String, String>{
      'engineVersion': engineVersion,
      'algorithmVersion': algorithmVersion,
      'dataVersion': dataVersion,
      'timezoneDatabaseVersion': timezoneDatabaseVersion,
      'zodiacSystem': zodiacSystem,
      'houseSystem': houseSystem,
      'nodeMode': nodeMode,
      'utcDateTime': utcDateTime.toIso8601String(),
      'localDateTime': localDateTimeIso,
    };
    final value = ayanamsha;
    if (value != null && value.trim().isNotEmpty) fields['ayanamsha'] = value;
    return Map.unmodifiable(fields);
  }
}

final class PdfSectionPreference {
  const PdfSectionPreference({
    required this.id,
    required this.enabled,
    required this.order,
  });

  final String id;
  final bool enabled;
  final int order;
}

final class PdfSectionComposition {
  const PdfSectionComposition({
    required this.sectionIds,
    required this.previewSectionIds,
  });

  final List<String> sectionIds;
  final List<String> previewSectionIds;
}

final class PdfSectionCompositionPlanner {
  const PdfSectionCompositionPlanner();

  PdfSectionComposition compose({
    required List<PdfSectionPreference> preferences,
    required Map<String, bool> contentAvailability,
    required PdfSubjectDetailLevel detailLevel,
  }) {
    final seen = <String>{};
    final orders = <int>{};
    for (final preference in preferences) {
      if (!PdfSectionIds.all.contains(preference.id)) {
        throw FormatException('Unknown PDF section preference: ${preference.id}.');
      }
      if (!seen.add(preference.id)) {
        throw FormatException('Duplicate PDF section preference: ${preference.id}.');
      }
      if (!orders.add(preference.order)) {
        throw FormatException('Duplicate PDF section order: ${preference.order}.');
      }
    }

    for (final id in contentAvailability.keys) {
      if (!PdfSectionIds.all.contains(id)) {
        throw FormatException('Unknown PDF content section: $id.');
      }
    }

    final enabled = preferences
        .where((item) => item.enabled && contentAvailability[item.id] == true)
        .where((item) =>
            detailLevel == PdfSubjectDetailLevel.technical ||
            item.id != PdfSectionIds.technicalManifest)
        .toList(growable: false)
      ..sort((a, b) => a.order.compareTo(b.order));

    final ids = enabled.map((item) => item.id).toList(growable: true);

    if (contentAvailability[PdfSectionIds.subject] != true) {
      throw const FormatException('PDF report requires non-empty customer/account information.');
    }
    ids.remove(PdfSectionIds.subject);

    final coverIndex = ids.indexOf(PdfSectionIds.cover);
    if (coverIndex >= 0) {
      ids.removeAt(coverIndex);
      ids.insert(0, PdfSectionIds.cover);
      ids.insert(1, PdfSectionIds.subject);
    } else {
      ids.insert(0, PdfSectionIds.subject);
    }

    if (ids.where((id) => id != PdfSectionIds.cover && id != PdfSectionIds.subject).isEmpty) {
      throw const FormatException('PDF report requires at least one selected non-empty report section.');
    }

    final immutable = List<String>.unmodifiable(ids);
    // Preview and final PDF intentionally consume the same ordered section model.
    return PdfSectionComposition(sectionIds: immutable, previewSectionIds: immutable);
  }
}

final class PdfReportContentGuard {
  const PdfReportContentGuard();

  void validateSubject({
    required PdfSubjectReportData subject,
    required PdfSubjectDetailLevel detailLevel,
  }) {
    if (subject.displayName.trim().isEmpty) {
      throw const FormatException('Customer/account information is missing.');
    }
    if (subject.birthPlaceLabel.trim().isEmpty || subject.timezoneLabel.trim().isEmpty) {
      throw const FormatException('Birth place and timezone must be preserved in PDF source data.');
    }
    if (detailLevel == PdfSubjectDetailLevel.technical && subject.calculationManifest == null) {
      throw const FormatException('Technical PDF requires a Calculation Manifest summary.');
    }
    final manifest = subject.calculationManifest;
    if (manifest != null && manifest.zodiacSystem.toLowerCase() == 'sidereal') {
      final ayanamsha = manifest.ayanamsha;
      if (ayanamsha == null || ayanamsha.trim().isEmpty) {
        throw const FormatException('Sidereal technical report requires ayanamsha.');
      }
    }
  }
}
