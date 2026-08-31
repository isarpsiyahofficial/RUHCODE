import 'package:flutter/services.dart';

import 'pdf_local_renderer.dart';
import 'pdf_local_service.dart';

final class PdfFontAssetSpec {
  const PdfFontAssetSpec({
    required this.localeTag,
    required this.familyName,
    required this.licenseId,
    required this.regularAssetPath,
    required this.boldAssetPath,
    required this.regularSha256,
    required this.boldSha256,
  });

  final String localeTag;
  final String familyName;
  final String licenseId;
  final String regularAssetPath;
  final String boldAssetPath;
  final String regularSha256;
  final String boldSha256;

  void validateMetadata() {
    if (localeTag != 'tr' && localeTag != 'en') {
      throw FormatException('Unsupported PDF font locale: $localeTag.');
    }
    if (familyName.trim().isEmpty || licenseId.trim().isEmpty) {
      throw const FormatException('PDF font asset metadata requires family and license identifiers.');
    }
    if (regularAssetPath.trim().isEmpty || boldAssetPath.trim().isEmpty) {
      throw const FormatException('PDF font asset paths cannot be blank.');
    }
    final hash = RegExp(r'^[a-f0-9]{64}$');
    if (!hash.hasMatch(regularSha256) || !hash.hasMatch(boldSha256)) {
      throw const FormatException('PDF font asset SHA-256 values must be lowercase hex.');
    }
  }
}

final class PdfAssetFontBundleProvider implements PdfFontBundleProvider {
  PdfAssetFontBundleProvider({
    required this.bundle,
    required List<PdfFontAssetSpec> specs,
  }) : _specs = _indexSpecs(specs);

  final AssetBundle bundle;
  final Map<String, PdfFontAssetSpec> _specs;

  static Map<String, PdfFontAssetSpec> _indexSpecs(List<PdfFontAssetSpec> specs) {
    final result = <String, PdfFontAssetSpec>{};
    for (final spec in specs) {
      spec.validateMetadata();
      if (result.containsKey(spec.localeTag)) {
        throw FormatException('Duplicate PDF font asset locale: ${spec.localeTag}.');
      }
      result[spec.localeTag] = spec;
    }
    for (final locale in const <String>{'tr', 'en'}) {
      if (!result.containsKey(locale)) {
        throw FormatException('Missing PDF font asset specification for $locale.');
      }
    }
    return Map.unmodifiable(result);
  }

  @override
  Future<PdfFontBundle> loadForLocale(String localeTag) async {
    final spec = _specs[localeTag];
    if (spec == null) {
      throw FormatException('No bundled PDF font is configured for locale $localeTag.');
    }
    final regularData = await bundle.load(spec.regularAssetPath);
    final boldData = await bundle.load(spec.boldAssetPath);
    final result = PdfFontBundle(
      regularBytes: _copyBytes(regularData),
      boldBytes: _copyBytes(boldData),
      regularSha256: spec.regularSha256,
      boldSha256: spec.boldSha256,
      familyName: spec.familyName,
      licenseId: spec.licenseId,
    );
    result.validate();
    return result;
  }

  static Uint8List _copyBytes(ByteData data) => Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
}
