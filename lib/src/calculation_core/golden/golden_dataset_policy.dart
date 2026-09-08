import '../calculation_validity.dart';

enum GoldenDomain {
  akilesRegression,
  western,
  vedic,
  planetaryHours,
  bazi,
  pythagoreanNumerology,
  chaldeanNumerology,
  loShu,
}

class GoldenCaseDescriptor {
  const GoldenCaseDescriptor({
    required this.id,
    required this.domain,
    required this.inputFingerprint,
    required this.expectedFingerprint,
    required this.sourceId,
    required this.sourceVersion,
    required this.edgeCases,
    required this.authoritative,
  });

  final String id;
  final GoldenDomain domain;
  final String inputFingerprint;
  final String expectedFingerprint;
  final String sourceId;
  final String sourceVersion;
  final Set<GoldenEdgeCase> edgeCases;
  final bool authoritative;
}

class GoldenDatasetPolicy {
  const GoldenDatasetPolicy();

  static const requiredIndependentDomains = <GoldenDomain>{
    GoldenDomain.western,
    GoldenDomain.vedic,
    GoldenDomain.planetaryHours,
    GoldenDomain.bazi,
    GoldenDomain.pythagoreanNumerology,
    GoldenDomain.chaldeanNumerology,
    GoldenDomain.loShu,
  };

  static const requiredEdgeCases = <GoldenEdgeCase>{
    GoldenEdgeCase.signBoundary,
    GoldenEdgeCase.longitudeNearTwentyNineFiftyNine,
    GoldenEdgeCase.longitudeNearZero,
    GoldenEdgeCase.nakshatraBoundary,
    GoldenEdgeCase.padaBoundary,
    GoldenEdgeCase.houseCuspBoundary,
    GoldenEdgeCase.retrogradeStation,
    GoldenEdgeCase.sunriseBoundary,
    GoldenEdgeCase.sunsetBoundary,
    GoldenEdgeCase.dstSpringForward,
    GoldenEdgeCase.dstFallBack,
    GoldenEdgeCase.historicalTimezoneChange,
    GoldenEdgeCase.halfHourTimezone,
    GoldenEdgeCase.fortyFiveMinuteTimezone,
    GoldenEdgeCase.utcPlusFourteen,
    GoldenEdgeCase.internationalDateLine,
    GoldenEdgeCase.polarCircle,
    GoldenEdgeCase.polarDayOrNight,
  };

  void validateAuthoritativeCase(GoldenCaseDescriptor value) {
    if (!value.authoritative) {
      throw StateError('golden case is not authoritative');
    }
    if (value.id.trim().isEmpty ||
        value.inputFingerprint.trim().isEmpty ||
        value.expectedFingerprint.trim().isEmpty ||
        value.sourceId.trim().isEmpty ||
        value.sourceVersion.trim().isEmpty) {
      throw StateError('golden provenance/fingerprint is incomplete');
    }
    if (value.domain == GoldenDomain.akilesRegression &&
        !value.sourceId.toLowerCase().contains('akiles')) {
      throw StateError('AKILES regression case requires exact AKILES provenance');
    }
  }

  void validateReleaseCorpus(List<GoldenCaseDescriptor> cases) {
    for (final value in cases) {
      validateAuthoritativeCase(value);
    }
    final domains = cases.map((e) => e.domain).toSet();
    final missingDomains = requiredIndependentDomains.difference(domains);
    if (missingDomains.isNotEmpty) {
      throw StateError('missing independent golden domains: $missingDomains');
    }
    final edgeCoverage = <GoldenEdgeCase>{
      for (final value in cases) ...value.edgeCases,
    };
    final missingEdges = requiredEdgeCases.difference(edgeCoverage);
    if (missingEdges.isNotEmpty) {
      throw StateError('missing golden edge coverage: $missingEdges');
    }
  }
}
