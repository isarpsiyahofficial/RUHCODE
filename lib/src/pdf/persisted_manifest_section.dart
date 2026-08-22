import '../domain/models/core_models.dart';
import 'pdf_local_renderer.dart';
import 'pdf_report_contract.dart';

/// Projects persisted CalculationManifest metadata into the optional technical
/// PDF section. This is presentation-only: no timezone, coordinate, house or
/// astrology value is recalculated here.
abstract final class PersistedManifestSectionAdapter {
  static PdfRenderSection build({
    required CalculationManifest manifest,
    required String snapshotDigest,
    required String title,
    required String fieldHeader,
    required String valueHeader,
    required String Function(String fieldId) labelForField,
  }) {
    if (title.trim().isEmpty || fieldHeader.trim().isEmpty || valueHeader.trim().isEmpty) {
      throw const FormatException('Technical manifest PDF labels cannot be blank.');
    }
    if (!RegExp(r'^[0-9a-f]{64}$').hasMatch(snapshotDigest)) {
      throw const FormatException('Technical manifest section requires lowercase SHA-256 digest.');
    }

    final values = <String, String>{
      'engineId': manifest.engineId,
      'engineVersion': manifest.engineVersion,
      'algorithmVersion': manifest.algorithmVersion,
      'dataVersion': manifest.dataVersion,
      if (_nonBlank(manifest.timezoneDatabaseVersion))
        'timezoneDatabaseVersion': manifest.timezoneDatabaseVersion!,
      'localDateTime': manifest.localDateTime.toIso8601String(),
      'utcDateTime': manifest.utcDateTime.toIso8601String(),
      'locationLabel': manifest.location.label,
      'countryCode': manifest.location.countryCode,
      'latitude': manifest.location.latitude.toStringAsFixed(6),
      'longitude': manifest.location.longitude.toStringAsFixed(6),
      'ianaTimeZoneId': manifest.location.ianaTimeZoneId,
      'validity': manifest.validity.name,
      if (_nonBlank(manifest.houseSystemId)) 'houseSystemId': manifest.houseSystemId!,
      if (_nonBlank(manifest.zodiacSystemId)) 'zodiacSystemId': manifest.zodiacSystemId!,
      if (_nonBlank(manifest.ayanamshaId)) 'ayanamshaId': manifest.ayanamshaId!,
      if (_nonBlank(manifest.nodeModeId)) 'nodeModeId': manifest.nodeModeId!,
    };

    final rows = <List<String>>[
      <String>[fieldHeader, valueHeader],
      for (final entry in values.entries)
        <String>[
          _requiredLabel(labelForField(entry.key), entry.key),
          entry.value,
        ],
    ];

    return PdfRenderSection(
      sectionId: PdfSectionIds.technicalManifest,
      snapshotDigest: snapshotDigest,
      title: title,
      paragraphs: const <String>[],
      rows: List<List<String>>.unmodifiable(
        rows.map((row) => List<String>.unmodifiable(row)),
      ),
    );
  }

  static bool _nonBlank(String? value) => value != null && value.trim().isNotEmpty;

  static String _requiredLabel(String value, String fieldId) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw FormatException('Missing localized technical manifest label for $fieldId.');
    }
    return normalized;
  }
}
