import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/bundled_earth_orientation.dart';
import 'package:ruh_code/src/calculation_core/time/earth_orientation_capability_policy.dart';

void main() {
  late BundledEarthOrientationProvider provider;
  late EarthOrientationCapabilityPolicy policy;

  setUp(() {
    provider = BundledEarthOrientationProvider(
      metadata: const EarthOrientationDatasetMetadata(
        sourceId: 'test-eop',
        dataVersion: '1',
        checksumSha256:
            'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
      ),
      records: [
        EarthOrientationDailyRecord(
          utcMidnight: DateTime.utc(2000, 1, 1),
          ut1MinusUtcSeconds: 0.10,
        ),
        EarthOrientationDailyRecord(
          utcMidnight: DateTime.utc(2000, 1, 2),
          ut1MinusUtcSeconds: 0.20,
        ),
      ],
    );
    policy = EarthOrientationCapabilityPolicy(provider);
  });

  test('product range is exactly 1890 through 2110', () {
    expect(
      policy.evaluate(DateTime.utc(1890, 1, 1)).status,
      EarthOrientationCapabilityStatus.unavailableWithinProductRange,
    );
    expect(
      policy.evaluate(DateTime.utc(2110, 12, 31, 23, 59, 59)).status,
      EarthOrientationCapabilityStatus.unavailableWithinProductRange,
    );
    expect(
      policy.evaluate(DateTime.utc(1889, 12, 31, 23, 59, 59)).status,
      EarthOrientationCapabilityStatus.outsideProductRange,
    );
    expect(
      policy.evaluate(DateTime.utc(2111, 1, 1)).status,
      EarthOrientationCapabilityStatus.outsideProductRange,
    );
  });

  test('published physical coverage is available without extrapolation', () {
    final capability = policy.evaluate(DateTime.utc(2000, 1, 1, 12));
    expect(capability.status, EarthOrientationCapabilityStatus.available);
    expect(capability.reasonCode, EarthOrientationCapabilityPolicy.availableReasonCode);

    final sample = policy.sampleRequiredAt(DateTime.utc(2000, 1, 1, 12));
    expect(sample.ut1MinusUtcSeconds, closeTo(0.15, 1e-12));
  });

  test('valid product date outside EOP coverage fails closed explicitly', () {
    final capability = policy.evaluate(DateTime.utc(1890, 1, 1));
    expect(
      capability.reasonCode,
      EarthOrientationCapabilityPolicy.unavailableReasonCode,
    );
    expect(capability.userMessageKey, isNotEmpty);

    expect(
      () => policy.sampleRequiredAt(DateTime.utc(1890, 1, 1)),
      throwsA(
        isA<EarthOrientationUnavailableException>().having(
          (error) => error.capability.reasonCode,
          'reasonCode',
          EarthOrientationCapabilityPolicy.unavailableReasonCode,
        ),
      ),
    );
  });

  test('outside product range is distinguished from missing EOP coverage', () {
    expect(
      () => policy.sampleRequiredAt(DateTime.utc(2111, 1, 1)),
      throwsA(
        isA<EarthOrientationUnavailableException>().having(
          (error) => error.capability.reasonCode,
          'reasonCode',
          EarthOrientationCapabilityPolicy.outsideProductRangeReasonCode,
        ),
      ),
    );
  });

  test('non-UTC instants are rejected', () {
    expect(
      () => policy.evaluate(DateTime(2000, 1, 1)),
      throwsArgumentError,
    );
  });
}
