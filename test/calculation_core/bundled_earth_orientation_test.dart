import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/bundled_earth_orientation.dart';

void main() {
  EarthOrientationDatasetMetadata metadata() => const EarthOrientationDatasetMetadata(
        sourceId: 'iers-test',
        dataVersion: 'fixture-1',
        checksumSha256: 'cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc',
      );

  test('interpolates UT1-UTC deterministically between daily UTC samples', () {
    final provider = BundledEarthOrientationProvider(
      metadata: metadata(),
      records: <EarthOrientationDailyRecord>[
        EarthOrientationDailyRecord(
          utcMidnight: DateTime.utc(2026, 8, 18),
          ut1MinusUtcSeconds: 0.10,
        ),
        EarthOrientationDailyRecord(
          utcMidnight: DateTime.utc(2026, 8, 19),
          ut1MinusUtcSeconds: 0.14,
        ),
      ],
    );

    final sample = provider.sampleAt(DateTime.utc(2026, 8, 18, 12));
    expect(sample.utcInstant, DateTime.utc(2026, 8, 18, 12));
    expect(sample.ut1MinusUtcSeconds, closeTo(0.12, 1e-12));
    expect(sample.sourceId, 'iers-test');
    expect(sample.dataVersion, 'fixture-1');
  });

  test('returns exact midnight sample without approximation', () {
    final provider = BundledEarthOrientationProvider(
      metadata: metadata(),
      records: <EarthOrientationDailyRecord>[
        EarthOrientationDailyRecord(
          utcMidnight: DateTime.utc(2026, 8, 18),
          ut1MinusUtcSeconds: -0.05,
        ),
        EarthOrientationDailyRecord(
          utcMidnight: DateTime.utc(2026, 8, 19),
          ut1MinusUtcSeconds: -0.04,
        ),
      ],
    );

    expect(
      provider.sampleAt(DateTime.utc(2026, 8, 18)).ut1MinusUtcSeconds,
      -0.05,
    );
  });

  test('rejects extrapolation beyond packaged coverage', () {
    final provider = BundledEarthOrientationProvider(
      metadata: metadata(),
      records: <EarthOrientationDailyRecord>[
        EarthOrientationDailyRecord(
          utcMidnight: DateTime.utc(2026, 8, 18),
          ut1MinusUtcSeconds: 0.10,
        ),
        EarthOrientationDailyRecord(
          utcMidnight: DateTime.utc(2026, 8, 19),
          ut1MinusUtcSeconds: 0.11,
        ),
      ],
    );

    expect(
      () => provider.sampleAt(DateTime.utc(2026, 8, 19, 0, 0, 1)),
      throwsRangeError,
    );
  });

  test('rejects oversized dataset gaps', () {
    expect(
      () => BundledEarthOrientationProvider(
        metadata: metadata(),
        records: <EarthOrientationDailyRecord>[
          EarthOrientationDailyRecord(
            utcMidnight: DateTime.utc(2026, 8, 18),
            ut1MinusUtcSeconds: 0.10,
          ),
          EarthOrientationDailyRecord(
            utcMidnight: DateTime.utc(2026, 8, 22),
            ut1MinusUtcSeconds: 0.11,
          ),
        ],
      ),
      throwsStateError,
    );
  });
}
