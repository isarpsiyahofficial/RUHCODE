import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/pdf/pdf_asset_font_provider.dart';

final class _MemoryAssetBundle extends CachingAssetBundle {
  _MemoryAssetBundle(this.files);

  final Map<String, Uint8List> files;

  @override
  Future<ByteData> load(String key) async {
    final bytes = files[key];
    if (bytes == null) {
      throw FlutterError('Missing test asset: $key');
    }
    return ByteData.sublistView(bytes);
  }
}

PdfFontAssetSpec _spec({
  required String locale,
  required Uint8List regular,
  required Uint8List bold,
  String regularPath = 'fonts/regular.ttf',
  String boldPath = 'fonts/bold.ttf',
}) {
  return PdfFontAssetSpec(
    localeTag: locale,
    familyName: 'Ruh Test Sans',
    licenseId: 'TEST-LICENSE',
    regularAssetPath: regularPath,
    boldAssetPath: boldPath,
    regularSha256: sha256.convert(regular).toString(),
    boldSha256: sha256.convert(bold).toString(),
  );
}

void main() {
  final regular = Uint8List.fromList(utf8.encode('regular-font-contract-bytes'));
  final bold = Uint8List.fromList(utf8.encode('bold-font-contract-bytes'));

  test('provider requires an explicit TR and EN font specification', () {
    expect(
      () => PdfAssetFontBundleProvider(
        bundle: _MemoryAssetBundle(<String, Uint8List>{}),
        specs: <PdfFontAssetSpec>[
          _spec(locale: 'tr', regular: regular, bold: bold),
        ],
      ),
      throwsFormatException,
    );
  });

  test('provider rejects duplicate locale specifications', () {
    expect(
      () => PdfAssetFontBundleProvider(
        bundle: _MemoryAssetBundle(<String, Uint8List>{}),
        specs: <PdfFontAssetSpec>[
          _spec(locale: 'tr', regular: regular, bold: bold),
          _spec(locale: 'tr', regular: regular, bold: bold),
          _spec(locale: 'en', regular: regular, bold: bold),
        ],
      ),
      throwsFormatException,
    );
  });

  test('loaded font bytes must match the immutable declared SHA-256', () async {
    final provider = PdfAssetFontBundleProvider(
      bundle: _MemoryAssetBundle(<String, Uint8List>{
        'fonts/tr-regular.ttf': Uint8List.fromList(utf8.encode('tampered')),
        'fonts/tr-bold.ttf': bold,
        'fonts/en-regular.ttf': regular,
        'fonts/en-bold.ttf': bold,
      }),
      specs: <PdfFontAssetSpec>[
        _spec(
          locale: 'tr',
          regular: regular,
          bold: bold,
          regularPath: 'fonts/tr-regular.ttf',
          boldPath: 'fonts/tr-bold.ttf',
        ),
        _spec(
          locale: 'en',
          regular: regular,
          bold: bold,
          regularPath: 'fonts/en-regular.ttf',
          boldPath: 'fonts/en-bold.ttf',
        ),
      ],
    );

    await expectLater(provider.loadForLocale('tr'), throwsFormatException);
  });

  test('verified locale font bundle loads without changing declared provenance', () async {
    final provider = PdfAssetFontBundleProvider(
      bundle: _MemoryAssetBundle(<String, Uint8List>{
        'fonts/tr-regular.ttf': regular,
        'fonts/tr-bold.ttf': bold,
        'fonts/en-regular.ttf': regular,
        'fonts/en-bold.ttf': bold,
      }),
      specs: <PdfFontAssetSpec>[
        _spec(
          locale: 'tr',
          regular: regular,
          bold: bold,
          regularPath: 'fonts/tr-regular.ttf',
          boldPath: 'fonts/tr-bold.ttf',
        ),
        _spec(
          locale: 'en',
          regular: regular,
          bold: bold,
          regularPath: 'fonts/en-regular.ttf',
          boldPath: 'fonts/en-bold.ttf',
        ),
      ],
    );

    final bundle = await provider.loadForLocale('tr');
    expect(bundle.familyName, 'Ruh Test Sans');
    expect(bundle.licenseId, 'TEST-LICENSE');
    expect(bundle.regularBytes, orderedEquals(regular));
    expect(bundle.boldBytes, orderedEquals(bold));
  });
}
