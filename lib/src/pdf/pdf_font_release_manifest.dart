/// Release-time provenance and readiness contract for packaged PDF fonts.
///
/// PDF rendering is intentionally fail-closed until the exact font binaries are
/// committed as application assets and their SHA-256 values are pinned. Keeping
/// this state in production code prevents a test-only renderer or an unverified
/// system font from silently becoming the release PDF path.
final class PdfFontReleaseManifest {
  const PdfFontReleaseManifest._();

  static const String familyName = 'Noto Sans';
  static const String licenseId = 'OFL-1.1';
  static const String upstreamRepository = 'https://github.com/google/fonts';
  static const String upstreamFamilyPath = 'ofl/notosans';

  static const String regularAssetPath =
      'assets/fonts/pdf/NotoSans-Regular.ttf';
  static const String boldAssetPath = 'assets/fonts/pdf/NotoSans-Bold.ttf';

  /// These values must only be replaced with lowercase 64-hex SHA-256 digests
  /// calculated from the exact binaries committed at [regularAssetPath] and
  /// [boldAssetPath]. Empty values deliberately keep production rendering off.
  static const String regularSha256 = '';
  static const String boldSha256 = '';

  static const bool binariesPackaged = false;

  static bool get isReleaseReady =>
      binariesPackaged &&
      _isSha256(regularSha256) &&
      _isSha256(boldSha256) &&
      regularAssetPath.isNotEmpty &&
      boldAssetPath.isNotEmpty &&
      familyName.isNotEmpty &&
      licenseId.isNotEmpty;

  static String get blockingReason {
    if (!binariesPackaged) {
      return 'Combined PDF byte rendering is unavailable: approved Unicode '
          'font binaries are not packaged in the release assets.';
    }
    if (!_isSha256(regularSha256) || !_isSha256(boldSha256)) {
      return 'Combined PDF byte rendering is unavailable: packaged Unicode '
          'font SHA-256 provenance is not pinned.';
    }
    return 'Combined PDF byte rendering is unavailable: PDF font release '
        'manifest is incomplete.';
  }

  static bool _isSha256(String value) =>
      RegExp(r'^[a-f0-9]{64}$').hasMatch(value);
}
