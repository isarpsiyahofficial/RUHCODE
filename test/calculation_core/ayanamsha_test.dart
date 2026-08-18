import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/vedic/ayanamsha.dart';

void main() {
  group('TabulatedAyanamshaProvider', () {
    const sha = 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa';

    TabulatedAyanamshaProvider provider() => TabulatedAyanamshaProvider(
          sourceId: 'independent-lahiri-reference',
          sourceVersion: 'fixture-v1',
          dataSha256: sha,
          samples: const [
            AyanamshaSample(julianDayTt: 2451545.0, degrees: 23.85),
            AyanamshaSample(julianDayTt: 2451910.25, degrees: 23.864),
            AyanamshaSample(julianDayTt: 2452275.5, degrees: 23.878),
          ],
        );

    test('exact sample preserves provenance', () {
      final value = provider().atJulianDayTt(2451545.0);
      expect(value.degrees, 23.85);
      expect(value.sourceId, 'independent-lahiri-reference');
      expect(value.sourceVersion, 'fixture-v1');
      expect(value.dataSha256, sha);
    });

    test('interpolation is deterministic inside coverage', () {
      final value = provider().atJulianDayTt((2451545.0 + 2451910.25) / 2.0);
      expect(value.degrees, closeTo((23.85 + 23.864) / 2.0, 1e-12));
    });

    test('coverage extrapolation is forbidden', () {
      expect(() => provider().atJulianDayTt(2451544.99), throwsRangeError);
      expect(() => provider().atJulianDayTt(2452275.51), throwsRangeError);
    });

    test('samples must be strictly increasing', () {
      expect(
        () => TabulatedAyanamshaProvider(
          sourceId: 'source',
          sourceVersion: 'v1',
          dataSha256: sha,
          samples: const [
            AyanamshaSample(julianDayTt: 2, degrees: 24),
            AyanamshaSample(julianDayTt: 2, degrees: 24.1),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('checksum cannot be omitted or malformed', () {
      expect(
        () => TabulatedAyanamshaProvider(
          sourceId: 'source',
          sourceVersion: 'v1',
          dataSha256: 'not-a-sha',
          samples: const [
            AyanamshaSample(julianDayTt: 1, degrees: 24),
            AyanamshaSample(julianDayTt: 2, degrees: 24.1),
          ],
        ),
        throwsArgumentError,
      );
    });
  });
}
