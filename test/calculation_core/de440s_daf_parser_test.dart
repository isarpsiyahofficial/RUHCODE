import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_asset_loader.dart';
import 'package:ruh_code/src/calculation_core/ephemeris/de440s_daf_parser.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('packaged DE440s exposes a structurally valid DAF/SPK segment index', () async {
    final kernel = await const De440sAssetLoader().loadPackaged();
    final index = De440sDafIndex.parse(kernel.bytes);

    expect(index.nd, 2);
    expect(index.ni, 6);
    expect(index.binaryFormat, anyOf('LTL-IEEE', 'BIG-IEEE'));
    expect(index.firstSummaryRecord, greaterThan(0));
    expect(index.lastSummaryRecord, greaterThanOrEqualTo(index.firstSummaryRecord));
    expect(index.firstFreeAddress, greaterThan(0));
    expect(index.segments, isNotEmpty);

    for (final segment in index.segments) {
      expect(segment.startEtSeconds, lessThanOrEqualTo(segment.endEtSeconds));
      expect(segment.dataType, greaterThan(0));
      expect(segment.startAddress, greaterThan(0));
      expect(segment.endAddress, greaterThanOrEqualTo(segment.startAddress));
      expect(segment.endAddress, lessThan(index.firstFreeAddress));
      expect(segment.name.trim(), isNotEmpty);
    }

    // DE440s is expected to contain at least one segment applicable at the
    // J2000 epoch. This checks directory coverage without yet claiming that
    // numerical type evaluation or geocentric chaining is proven.
    expect(index.segments.any((segment) => segment.containsEt(0)), isTrue);
  });

  test('parser fails closed for a non-DAF/SPK payload', () {
    expect(
      () => De440sDafIndex.parse(Uint8List(1024)),
      throwsFormatException,
    );
  });
}
