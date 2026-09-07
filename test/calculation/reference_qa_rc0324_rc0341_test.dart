import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation/calculation_manifest.dart';
import 'package:ruh_code/src/calculation/reference_qa.dart';

void main() {
  CalculationManifest manifest(String id, {double lat = 36.89, double lon = 30.70, String tz = 'Europe/Istanbul'}) =>
      CalculationManifest(
        id: id,
        engineId: 'reference-fixture',
        engineVersion: 'fixture-v1',
        zodiacFrame: ZodiacFrame.tropical,
        houseSystemId: 'placidus',
        ayanamshaId: null,
        nodeSystemId: 'true-node',
        timeZoneDatabaseVersion: '2026b',
        coordinate: GeoCoordinate(latitude: lat, longitude: lon),
        instantUtc: DateTime.utc(2026, 9, 7, 12),
        localDateTimeIso: '2026-09-07T15:00:00+03:00',
        timeZoneId: tz,
        assumptions: const {'fixture': 'not-production-golden-data'},
      );

  final primary = ReferenceSource(
    id: 'primary',
    version: 'v1',
    kind: ReferenceSourceKind.primaryMathematical,
    citation: 'primary mathematical source fixture',
  );
  final independent = ReferenceSource(
    id: 'independent',
    version: 'v1',
    kind: ReferenceSourceKind.independentReference,
    citation: 'independent comparison fixture',
  );

  ReferenceSuite suite(
    ReferenceEngine engine,
    Set<BoundaryTag> tags, {
    double lat = 36.89,
    double lon = 30.70,
    String tz = 'Europe/Istanbul',
  }) =>
      ReferenceSuite(
        id: 'suite-${engine.name}',
        engine: engine,
        sources: [primary, independent],
        cases: [
          ReferenceCase(
            id: 'case-${engine.name}',
            engine: engine,
            manifest: manifest('manifest-${engine.name}', lat: lat, lon: lon, tz: tz),
            expectation: ReferenceExpectation(values: const {'expected': 'fixture'}),
            sourceIds: const {'primary', 'independent'},
            boundaryTags: tags,
          ),
        ],
      );

  ReferenceQaCatalog completeSmallCatalog() => ReferenceQaCatalog(suites: [
        suite(ReferenceEngine.western, const {
          BoundaryTag.zodiacIngress,
          BoundaryTag.houseCusp,
          BoundaryTag.dstTransition,
        }),
        suite(ReferenceEngine.vedic, const {BoundaryTag.nakshatra}),
        suite(
          ReferenceEngine.planetaryHours,
          const {BoundaryTag.highLatitude},
          lat: 69.65,
          lon: 18.96,
          tz: 'Europe/Oslo',
        ),
        suite(ReferenceEngine.bazi, const {
          BoundaryTag.chineseNewYear,
          BoundaryTag.baziSolarTerm,
          BoundaryTag.midnight,
        }),
        suite(ReferenceEngine.numerologyPythagorean, const {BoundaryTag.leapYear}),
        suite(ReferenceEngine.numerologyChaldean, const {}),
        suite(ReferenceEngine.numerologyLoShu, const {}),
      ]);

  test('catalog requires one unambiguous suite per registered engine', () {
    final catalog = completeSmallCatalog();
    expect(catalog.hasSuiteForEveryEngine(ReferenceEngine.values), isTrue);
    expect(
      () => ReferenceQaCatalog(suites: [
        suite(ReferenceEngine.western, const {}),
        suite(ReferenceEngine.western, const {}),
      ]),
      throwsArgumentError,
    );
  });

  test('reference cases reject unknown provenance and cross-engine reuse', () {
    expect(
      () => ReferenceSuite(
        id: 'bad-source',
        engine: ReferenceEngine.western,
        sources: [primary],
        cases: [
          ReferenceCase(
            id: 'bad',
            engine: ReferenceEngine.western,
            manifest: manifest('m-bad'),
            expectation: ReferenceExpectation(values: const {'x': '1'}),
            sourceIds: const {'missing'},
          ),
        ],
      ),
      throwsArgumentError,
    );
    expect(
      () => ReferenceSuite(
        id: 'bad-engine',
        engine: ReferenceEngine.western,
        sources: [primary, independent],
        cases: [
          ReferenceCase(
            id: 'vedic-case',
            engine: ReferenceEngine.vedic,
            manifest: manifest('m-cross'),
            expectation: ReferenceExpectation(values: const {'x': '1'}),
            sourceIds: const {'primary', 'independent'},
          ),
        ],
      ),
      throwsArgumentError,
    );
  });

  test('single-source evidence can never satisfy release policy', () {
    final onlyIndependent = ReferenceSuite(
      id: 'western-single-source',
      engine: ReferenceEngine.western,
      sources: [independent],
      cases: [
        ReferenceCase(
          id: 'single',
          engine: ReferenceEngine.western,
          manifest: manifest('m-single'),
          expectation: ReferenceExpectation(values: const {'longitude': '12.3'}),
          sourceIds: const {'independent'},
        ),
      ],
    );
    expect(onlyIndependent.hasMultiSourceEvidence, isFalse);
  });

  test('all mandated boundary classes are machine-readable and coverable', () {
    final catalog = completeSmallCatalog();
    final covered = <BoundaryTag>{
      for (final s in catalog.suites) ...s.coveredBoundaries,
    };
    expect(covered, containsAll(ReferenceReleasePolicy.requiredBoundaryTags));
  });

  test('small fixtures prove harness behavior but cannot fake thousand-case release evidence', () {
    final catalog = completeSmallCatalog();
    expect(const ReferenceReleasePolicy().releaseReady(catalog), isFalse);

    const harnessOnlyPolicy = ReferenceReleasePolicy(
      minimumWesternCases: 1,
      minimumVedicCases: 1,
      minimumPlanetaryHourCoordinates: 1,
      minimumPlanetaryHourTimeZones: 1,
    );
    expect(harnessOnlyPolicy.releaseReady(catalog), isTrue);
  });

  test('planetary-hour global coverage is based on distinct coordinates and timezones', () {
    final s = suite(
      ReferenceEngine.planetaryHours,
      const {BoundaryTag.highLatitude},
      lat: -54.80,
      lon: -68.30,
      tz: 'America/Argentina/Ushuaia',
    );
    expect(s.uniqueCoordinateCount, 1);
    expect(s.uniqueTimeZoneCount, 1);
  });
}
