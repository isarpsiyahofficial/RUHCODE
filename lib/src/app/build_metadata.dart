/// Canonical application/build metadata consumed by portable artifacts.
///
/// `appVersion` mirrors pubspec.yaml and is structurally validated in CI so
/// backup manifests cannot silently drift from the installed application.
abstract final class RuhCodeBuildMetadata {
  static const appVersion = '0.1.0+1';
  static const engineVersion = 'ruh-core.v1';
}