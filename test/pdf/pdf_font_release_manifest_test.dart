import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_font_release_manifest.dart';

void main() {
  group('PdfFontReleaseManifest', () {
    test('stays fail-closed until exact packaged font hashes are pinned', () {
      expect(PdfFontReleaseManifest.binariesPackaged, isFalse);
      expect(PdfFontReleaseManifest.regularSha256, isEmpty);
      expect(PdfFontReleaseManifest.boldSha256, isEmpty);
      expect(PdfFontReleaseManifest.isReleaseReady, isFalse);
      expect(
        PdfFontReleaseManifest.blockingReason,
        contains('font binaries are not packaged'),
      );
    });

    test('pins the approved offline asset and license contract', () {
      expect(PdfFontReleaseManifest.familyName, 'Noto Sans');
      expect(PdfFontReleaseManifest.licenseId, 'OFL-1.1');
      expect(
        PdfFontReleaseManifest.upstreamRepository,
        'https://github.com/google/fonts',
      );
      expect(PdfFontReleaseManifest.upstreamFamilyPath, 'ofl/notosans');
      expect(
        PdfFontReleaseManifest.regularAssetPath,
        'assets/fonts/pdf/NotoSans-Regular.ttf',
      );
      expect(
        PdfFontReleaseManifest.boldAssetPath,
        'assets/fonts/pdf/NotoSans-Bold.ttf',
      );
    });
  });
}
