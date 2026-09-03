import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_asset_loader.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the exact packaged DE440s kernel offline with byte integrity', () async {
    const loader = De440sAssetLoader();
    final kernel = await loader.loadPackaged();

    expect(kernel.bytes.length, De440sAssetLoader.expectedByteSize);
    expect(kernel.sha256, De440sAssetLoader.expectedSha256);
    expect(String.fromCharCodes(kernel.bytes.take(7)), 'DAF/SPK');
  });
}
