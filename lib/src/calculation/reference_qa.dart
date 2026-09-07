import 'calculation_manifest.dart';

/// Reference/golden calculation QA primitives for RC-0324..RC-0341.
///
/// This layer intentionally does not manufacture astronomical truth. It stores
/// independently sourced expectations and makes release-readiness fail closed
/// until the required corpus/coverage is actually present.
enum ReferenceEngine {
  western,
  vedic,
  planetaryHours,
  bazi,
  numerologyPythagorean,
  numerologyChaldean,
  numerologyLoShu,
}

enum ReferenceSourceKind { primaryMathematical, independentReference }

enum BoundaryTag {
  zodiacIngress,
  nakshatra,
  houseCusp,
  dstTransition,
  chineseNewYear,
  baziSolarTerm,
  leapYear,
  midnight,
  highLatitude,
}

final class ReferenceSource {
  ReferenceSource({
    required this.id,
    required this.version,
    required this.kind,
    required this.citation,
  }) {
    _nonBlank(id, 'source id');
    _nonBlank(version, 'source version');
    _nonBlank(citation, 'source citation');
  }

  final String id;
  final String version;
  final ReferenceSourceKind kind;
  final String citation;
}

final class ReferenceExpectation {
  ReferenceExpectation({required Map<String, String> values})
      : values = Map.unmodifiable(values) {
    if (this.values.isEmpty) {
      throw ArgumentError('reference expectation cannot be empty');
    }
    for (final entry in this.values.entries) {
      _nonBlank(entry.key, 'expectation key');
      _nonBlank(entry.value, 'expectation value');
    }
  }

  final Map<String, String> values;
}

final class ReferenceCase {
  ReferenceCase({
    required this.id,
    required this.engine,
    required this.manifest,
    required this.expectation,
    required Set<String> sourceIds,
    Set<BoundaryTag> boundaryTags = const {},
  })  : sourceIds = Set.unmodifiable(sourceIds),
        boundaryTags = Set.unmodifiable(boundaryTags) {
    _nonBlank(id, 'case id');
    if (this.sourceIds.isEmpty) {
      throw ArgumentError('reference case requires provenance');
    }
  }

  final String id;
  final ReferenceEngine engine;
  final CalculationManifest manifest;
  final ReferenceExpectation expectation;
  final Set<String> sourceIds;
  final Set<BoundaryTag> boundaryTags;
}

final class ReferenceSuite {
  ReferenceSuite({
    required this.id,
    required this.engine,
    required List<ReferenceSource> sources,
    required List<ReferenceCase> cases,
  })  : sources = List.unmodifiable(sources),
        cases = List.unmodifiable(cases) {
    _nonBlank(id, 'suite id');
    if (this.sources.isEmpty) throw ArgumentError('suite requires sources');
    if (this.cases.isEmpty) throw ArgumentError('suite requires cases');

    final sourceIds = <String>{};
    for (final source in this.sources) {
      if (!sourceIds.add(source.id)) {
        throw ArgumentError('duplicate source id: ${source.id}');
      }
    }
    final caseIds = <String>{};
    for (final testCase in this.cases) {
      if (testCase.engine != engine) {
        throw ArgumentError('case ${testCase.id} belongs to another engine');
      }
      if (!caseIds.add(testCase.id)) {
        throw ArgumentError('duplicate reference case id: ${testCase.id}');
      }
      final missing = testCase.sourceIds.difference(sourceIds);
      if (missing.isNotEmpty) {
        throw ArgumentError('case ${testCase.id} has unknown sources: $missing');
      }
    }
  }

  final String id;
  final ReferenceEngine engine;
  final List<ReferenceSource> sources;
  final List<ReferenceCase> cases;

  Set<BoundaryTag> get coveredBoundaries => {
        for (final testCase in cases) ...testCase.boundaryTags,
      };

  int get uniqueCoordinateCount => {
        for (final testCase in cases)
          '${testCase.manifest.coordinate.latitude.toStringAsFixed(6)},${testCase.manifest.coordinate.longitude.toStringAsFixed(6)}'
      }.length;

  int get uniqueTimeZoneCount => {
        for (final testCase in cases) testCase.manifest.timeZoneId,
      }.length;

  bool get hasPrimarySource =>
      sources.any((s) => s.kind == ReferenceSourceKind.primaryMathematical);

  bool get hasIndependentSource =>
      sources.any((s) => s.kind == ReferenceSourceKind.independentReference);

  bool get hasMultiSourceEvidence =>
      sources.map((s) => s.id).toSet().length >= 2 &&
      hasPrimarySource &&
      hasIndependentSource;

  bool everyCaseHasIndependentEvidence() {
    final independentIds = sources
        .where((s) => s.kind == ReferenceSourceKind.independentReference)
        .map((s) => s.id)
        .toSet();
    return cases.every((c) => c.sourceIds.intersection(independentIds).isNotEmpty);
  }
}

final class ReferenceQaCatalog {
  ReferenceQaCatalog({required List<ReferenceSuite> suites})
      : suites = List.unmodifiable(suites) {
    final engines = <ReferenceEngine>{};
    final ids = <String>{};
    for (final suite in this.suites) {
      if (!ids.add(suite.id)) throw ArgumentError('duplicate suite id: ${suite.id}');
      if (!engines.add(suite.engine)) {
        throw ArgumentError('duplicate suite for engine: ${suite.engine.name}');
      }
    }
  }

  final List<ReferenceSuite> suites;

  ReferenceSuite? suiteFor(ReferenceEngine engine) {
    for (final suite in suites) {
      if (suite.engine == engine) return suite;
    }
    return null;
  }

  bool hasSuiteForEveryEngine(Iterable<ReferenceEngine> engines) =>
      engines.every((engine) => suiteFor(engine) != null);
}

final class ReferenceReleasePolicy {
  const ReferenceReleasePolicy({
    this.minimumWesternCases = 1000,
    this.minimumVedicCases = 1000,
    this.minimumPlanetaryHourCoordinates = 20,
    this.minimumPlanetaryHourTimeZones = 10,
  });

  final int minimumWesternCases;
  final int minimumVedicCases;
  final int minimumPlanetaryHourCoordinates;
  final int minimumPlanetaryHourTimeZones;

  static const requiredBoundaryTags = <BoundaryTag>{
    BoundaryTag.zodiacIngress,
    BoundaryTag.nakshatra,
    BoundaryTag.houseCusp,
    BoundaryTag.dstTransition,
    BoundaryTag.chineseNewYear,
    BoundaryTag.baziSolarTerm,
    BoundaryTag.leapYear,
    BoundaryTag.midnight,
    BoundaryTag.highLatitude,
  };

  bool releaseReady(ReferenceQaCatalog catalog) {
    const requiredEngines = ReferenceEngine.values;
    if (!catalog.hasSuiteForEveryEngine(requiredEngines)) return false;

    for (final suite in catalog.suites) {
      if (!suite.hasMultiSourceEvidence ||
          !suite.everyCaseHasIndependentEvidence()) {
        return false;
      }
    }

    final western = catalog.suiteFor(ReferenceEngine.western)!;
    final vedic = catalog.suiteFor(ReferenceEngine.vedic)!;
    final planetary = catalog.suiteFor(ReferenceEngine.planetaryHours)!;
    if (western.cases.length < minimumWesternCases) return false;
    if (vedic.cases.length < minimumVedicCases) return false;
    if (planetary.uniqueCoordinateCount < minimumPlanetaryHourCoordinates ||
        planetary.uniqueTimeZoneCount < minimumPlanetaryHourTimeZones) {
      return false;
    }

    final covered = <BoundaryTag>{
      for (final suite in catalog.suites) ...suite.coveredBoundaries,
    };
    if (!covered.containsAll(requiredBoundaryTags)) return false;
    return true;
  }
}

void _nonBlank(String value, String field) {
  if (value.trim().isEmpty) throw ArgumentError('$field cannot be blank');
}
