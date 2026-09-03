import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';

/// Immutable proof that the packaged DE440s kernel passed byte-level runtime
/// integrity checks. This does not claim celestial-vector computation support;
/// the SPK evaluator and independent golden vectors remain separate RC-1437
/// release gates.
final class De440sKernelAsset {
  const De440sKernelAsset({
    required this.bytes,
    required this.sha256,
  });

  final Uint8List bytes;
  final String sha256;
}

final class De440sAssetLoader {
  const De440sAssetLoader({AssetBundle? bundle}) : _bundle = bundle;

  static const String assetPath = 'assets/data/ephemeris/de440s.bsp';
  static const String expectedSha256 =
      'c1c7feeab882263fc493a9d5a5b2ddd71b54826cdf65d8d17a76126b260a49f2';
  static const int expectedByteSize = 32726016;

  final AssetBundle? _bundle;

  Future<De440sKernelAsset> loadPackaged() async {
    final bundle = _bundle ?? rootBundle;
    final data = await bundle.load(assetPath);
    final bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    if (bytes.length != expectedByteSize) {
      throw StateError(
        'Packaged DE440s byte-size mismatch: expected $expectedByteSize, got ${bytes.length}.',
      );
    }
    if (bytes.length < 8 || String.fromCharCodes(bytes.take(7)) != 'DAF/SPK') {
      throw const FormatException('Packaged DE440s is not a DAF/SPK kernel.');
    }
    final digest = sha256.convert(bytes).toString();
    if (digest != expectedSha256) {
      throw StateError(
        'Packaged DE440s checksum mismatch: expected $expectedSha256, got $digest.',
      );
    }
    return De440sKernelAsset(bytes: bytes, sha256: digest);
  }
}
