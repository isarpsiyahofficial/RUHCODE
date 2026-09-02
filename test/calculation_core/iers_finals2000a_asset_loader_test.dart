import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/time/iers_finals2000a_asset_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the exact packaged IERS snapshot offline and exposes usable UT1 coverage', () async {
    const loader = IersFinals2000AAssetLoader();
    final provider = await loader.loadPackaged();

    expect(provider.metadata.sourceId, IersFinals2000AAssetLoader.sourceId);
    expect(provider.metadata.dataVersion, IersFinals2000AAssetLoader.dataVersion);
    expect(
      provider.metadata.checksumSha256,
      IersFinals2000AAssetLoader.expectedSha256,
    );
    expect(provider.coverageStartUtc, DateTime.utc(1973, 1, 2));
    expect(provider.coverageEndUtc.isAfter(DateTime.utc(2026, 9, 2)), isTrue);

    final instant = DateTime.utc(2026, 1, 1, 12);
    final sample = provider.sampleAt(instant);
    sample.validateFor(instant);
    expect(sample.ut1MinusUtcSeconds.abs(), lessThan(0.9));
    expect(sample.sourceId, IersFinals2000AAssetLoader.sourceId);
    expect(sample.dataVersion, IersFinals2000AAssetLoader.dataVersion);
  });

  test('packaged provider fails closed outside published UT1 coverage', () async {
    const loader = IersFinals2000AAssetLoader();
    final provider = await loader.loadPackaged();

    expect(
      () => provider.sampleAt(provider.coverageStartUtc.subtract(const Duration(seconds: 1))),
      throwsRangeError,
    );
    expect(
      () => provider.sampleAt(provider.coverageEndUtc.add(const Duration(seconds: 1))),
      throwsRangeError,
    );
  });
}
