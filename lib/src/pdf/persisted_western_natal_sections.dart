import 'pdf_local_renderer.dart';
import 'pdf_report_contract.dart';
import 'persisted_western_natal_snapshot.dart';

/// Pure presentation projection for historical Western natal PDF sections.
///
/// It consumes only the sealed persisted snapshot. No ephemeris, transit,
/// house-engine or natal calculation service is imported or invoked here.
abstract final class PersistedWesternNatalSectionAdapter {
  static List<PdfRenderSection> build({
    required PersistedWesternNatalEnvelope envelope,
    required String placementsTitle,
    required String housesTitle,
    required String aspectsTitle,
    required String bodyHeader,
    required String signHeader,
    required String degreeHeader,
    required String houseHeader,
    required String motionHeader,
    required String cuspHeader,
    required String aspectHeader,
    required String separationHeader,
    required String orbHeader,
    required String Function(String bodyId) bodyLabel,
    required String Function(String signId) signLabel,
    required String Function(String motionId) motionLabel,
    required String Function(String aspectId) aspectLabel,
  }) {
    final labels = <String>[
      placementsTitle,
      housesTitle,
      aspectsTitle,
      bodyHeader,
      signHeader,
      degreeHeader,
      houseHeader,
      motionHeader,
      cuspHeader,
      aspectHeader,
      separationHeader,
      orbHeader,
    ];
    if (labels.any((value) => value.trim().isEmpty)) {
      throw const FormatException('Western PDF section labels cannot be blank.');
    }

    final snapshot = envelope.snapshot;
    final digest = envelope.snapshotSha256;
    if (digest != snapshot.sha256Hex) {
      throw const FormatException('Western PDF envelope digest drift detected.');
    }

    final placements = snapshot.placements.toList()
      ..sort((a, b) => a.body.compareTo(b.body));
    final placementRows = <List<String>>[
      <String>[bodyHeader, signHeader, degreeHeader, houseHeader, motionHeader],
      for (final placement in placements)
        <String>[
          _requiredLabel(bodyLabel(placement.body), placement.body),
          _requiredLabel(signLabel(_signId(placement.longitudeDeg)), _signId(placement.longitudeDeg)),
          _degreeWithinSign(placement.longitudeDeg),
          placement.houseNumber.toString(),
          _requiredLabel(motionLabel(placement.motion), placement.motion),
        ],
    ];

    final houseRows = <List<String>>[
      <String>[houseHeader, cuspHeader, signHeader],
      for (var index = 0; index < snapshot.houseCuspsDeg.length; index++)
        <String>[
          '${index + 1}',
          _formatDegrees(snapshot.houseCuspsDeg[index]),
          _requiredLabel(
            signLabel(_signId(snapshot.houseCuspsDeg[index])),
            _signId(snapshot.houseCuspsDeg[index]),
          ),
        ],
    ];

    final aspects = snapshot.aspects.toList()
      ..sort((a, b) {
        final first = a.bodyA.compareTo(b.bodyA);
        return first != 0 ? first : a.bodyB.compareTo(b.bodyB);
      });
    final aspectRows = <List<String>>[
      <String>[bodyHeader, bodyHeader, aspectHeader, separationHeader, orbHeader],
      for (final aspect in aspects)
        <String>[
          _requiredLabel(bodyLabel(aspect.bodyA), aspect.bodyA),
          _requiredLabel(bodyLabel(aspect.bodyB), aspect.bodyB),
          _requiredLabel(aspectLabel(aspect.type), aspect.type),
          _formatDegrees(aspect.separationDeg),
          _formatDegrees(aspect.deltaFromExactDeg),
        ],
    ];

    return List<PdfRenderSection>.unmodifiable(<PdfRenderSection>[
      PdfRenderSection(
        sectionId: PdfSectionIds.placements,
        snapshotDigest: digest,
        title: placementsTitle,
        paragraphs: const <String>[],
        rows: _freezeRows(placementRows),
      ),
      PdfRenderSection(
        sectionId: PdfSectionIds.houses,
        snapshotDigest: digest,
        title: housesTitle,
        paragraphs: const <String>[],
        rows: _freezeRows(houseRows),
      ),
      PdfRenderSection(
        sectionId: PdfSectionIds.aspects,
        snapshotDigest: digest,
        title: aspectsTitle,
        paragraphs: const <String>[],
        rows: _freezeRows(aspectRows),
      ),
    ]);
  }

  static List<List<String>> _freezeRows(List<List<String>> rows) =>
      List<List<String>>.unmodifiable(
        rows.map((row) => List<String>.unmodifiable(row)),
      );

  static String _requiredLabel(String value, String id) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw FormatException('Missing localized Western PDF label for $id.');
    }
    return normalized;
  }

  static String _degreeWithinSign(double longitude) {
    final value = longitude % 30.0;
    return _formatDegrees(value < 0 ? value + 30.0 : value);
  }

  static String _formatDegrees(double value) => '${value.toStringAsFixed(2)}°';

  static String _signId(double longitude) {
    const signs = <String>[
      'aries',
      'taurus',
      'gemini',
      'cancer',
      'leo',
      'virgo',
      'libra',
      'scorpio',
      'sagittarius',
      'capricorn',
      'aquarius',
      'pisces',
    ];
    final normalized = ((longitude % 360.0) + 360.0) % 360.0;
    return signs[(normalized / 30.0).floor() % 12];
  }
}
