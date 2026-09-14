/// Release-time provenance and readiness contract for packaged PDF fonts.
///
/// PDF rendering is intentionally fail-closed until the exact font binaries are
/// committed as application assets. The approved SHA-256 values may be pinned
/// earlier from an independently verified materialization run, but that alone
/// never makes the renderer release-ready. Keeping both facts in production
/// code prevents a test-only renderer or an unverified system font from silently
/// becoming the release PDF path.
final class PdfFontReleaseManifest {
  const PdfFontReleaseManifest._();

  static const String familyName = 'Noto Sans';
  static const String licenseId = 'OFL-1.1';

  /// Canonical upstream is pinned to an immutable Noto monthly release commit.
  /// The per-file Git blob SHA-1 values are verified before materialization.
  static const String upstreamRepository =
      'https://github.com/notofonts/notofonts.github.io';
  static const String upstreamRevision =
      '66c4b351c58f99ace5a6265d329080d74b057909';
  static const String upstreamFamilyPath = 'fonts/NotoSans/hinted/ttf';
  static const String regularUpstreamBlobSha1 =
      'f27f4ff59562d58480f1cb94194393484b8da9e9';
  static const String boldUpstreamBlobSha1 =
      'aae7546dc1905b228aff70cde8c818b82f3a2bc4';
  static const String licenseUpstreamBlobSha1 =
      '9651ea7d51c39a7778cc327a423fb200350aa948';

  static const String regularAssetPath =
      'assets/fonts/pdf/NotoSans-Regular.ttf';
  static const String boldAssetPath = 'assets/fonts/pdf/NotoSans-Bold.ttf';
  static const String licenseAssetPath = 'assets/fonts/pdf/OFL.txt';

  /// Exact SHA-256 digests physically verified by the pinned materializer.
  ///
  /// These hashes identify the only approved Regular/Bold payloads. They do not
  /// imply that those payloads are already present in the repository or release
  /// bundle; [binariesPackaged] remains the independent packaging truth gate.
  static const String regularSha256 =
      '478c558ea716033cd60c03438f628dfa75694dcf6b5f6d505a2f05fd2b4f3823';
  static const String boldSha256 =
      '1df075a380fc7cb898acf64c1f7b3b4dd780de3caa860178bf929de35817a913';

  /// This flips to true only in the same change that commits the exact verified
  /// TTF assets into the application bundle. Hash knowledge alone is not enough.
  static const bool binariesPackaged = true;

  static bool get isReleaseReady =>
      binariesPackaged &&
      _isSha256(regularSha256) &&
      _isSha256(boldSha256) &&
      regularSha256 != boldSha256 &&
      regularAssetPath.isNotEmpty &&
      boldAssetPath.isNotEmpty &&
      licenseAssetPath.isNotEmpty &&
      familyName.isNotEmpty &&
      licenseId.isNotEmpty &&
      _isGitSha1(upstreamRevision) &&
      _isGitSha1(regularUpstreamBlobSha1) &&
      _isGitSha1(boldUpstreamBlobSha1) &&
      _isGitSha1(licenseUpstreamBlobSha1);

  static String get blockingReason {
    if (!binariesPackaged) {
      return 'Combined PDF byte rendering is unavailable: approved Unicode '
          'font binaries are not packaged in the release assets.';
    }
    if (!_isSha256(regularSha256) || !_isSha256(boldSha256)) {
      return 'Combined PDF byte rendering is unavailable: packaged Unicode '
          'font SHA-256 provenance is not pinned.';
    }
    if (regularSha256 == boldSha256) {
      return 'Combined PDF byte rendering is unavailable: Regular and Bold '
          'font binaries must be distinct verified assets.';
    }
    return 'Combined PDF byte rendering is unavailable: PDF font release '
        'manifest is incomplete.';
  }

  static bool _isSha256(String value) =>
      RegExp(r'^[a-f0-9]{64}$').hasMatch(value);

  static bool _isGitSha1(String value) =>
      RegExp(r'^[a-f0-9]{40}$').hasMatch(value);
}
