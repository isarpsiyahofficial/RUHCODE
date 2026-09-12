import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_font_release_manifest.dart';

void main() {
  group('PdfFontReleaseManifest', () {
    test('is either truthful fail-closed or fully hash-pinned', () {
      if (PdfFontReleaseManifest.binariesPackaged) {
        expect(
          PdfFontReleaseManifest.regularSha256,
          matches(RegExp(r'^[a-f0-9]{64}$')),
        );
        expect(
          PdfFontReleaseManifest.boldSha256,
          matches(RegExp(r'^[a-f0-9]{64}$')),
        );
        expect(
          PdfFontReleaseManifest.regularSha256,
          isNot(PdfFontReleaseManifest.boldSha256),
        );
        expect(PdfFontReleaseManifest.isReleaseReady, isTrue);
      } else {
        expect(PdfFontReleaseManifest.regularSha256, isEmpty);
        expect(PdfFontReleaseManifest.boldSha256, isEmpty);
        expect(PdfFontReleaseManifest.isReleaseReady, isFalse);
        expect(
          PdfFontReleaseManifest.blockingReason,
          contains('font binaries are not packaged'),
        );
      }
    });

    test('pins the approved offline asset, source and license contract', () {
      expect(PdfFontReleaseManifest.familyName, 'Noto Sans');
      expect(PdfFontReleaseManifest.licenseId, 'OFL-1.1');
      expect(
        PdfFontReleaseManifest.upstreamRepository,
        'https://github.com/notofonts/notofonts.github.io',
      );
      expect(
        PdfFontReleaseManifest.upstreamRevision,
        '66c4b351c58f99ace5a6265d329080d74b057909',
      );
      expect(
        PdfFontReleaseManifest.regularUpstreamBlobSha1,
        'f27f4ff59562d58480f1cb94194393484b8da9e9',
      );
      expect(
        PdfFontReleaseManifest.boldUpstreamBlobSha1,
        'aae7546dc1905b228aff70cde8c818b82f3a2bc4',
      );
      expect(
        PdfFontReleaseManifest.licenseUpstreamBlobSha1,
        '9651ea7d51c39a7778cc327a423fb200350aa948',
      );
      expect(
        PdfFontReleaseManifest.regularAssetPath,
        'assets/fonts/pdf/NotoSans-Regular.ttf',
      );
      expect(
        PdfFontReleaseManifest.boldAssetPath,
        'assets/fonts/pdf/NotoSans-Bold.ttf',
      );
      expect(PdfFontReleaseManifest.licenseAssetPath, 'assets/fonts/pdf/OFL.txt');
    });
  });
}
