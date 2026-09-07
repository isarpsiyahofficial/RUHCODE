/// RC-0159/0160 architectural boundary for a future Zi Wei Dou Shu implementation.
///
/// This contract intentionally lives outside the BaZi package and carries no
/// BaZi types. A production Zi Wei implementation must implement this engine as
/// its own calculation system rather than becoming a BaZi sub-feature.
abstract interface class ZiWeiDouShuEngine<I, O> {
  String get engineId;
  String get version;
  String get sourceId;

  O calculate(I input);
}

final class ZiWeiEngineDescriptor {
  ZiWeiEngineDescriptor({
    required this.engineId,
    required this.version,
    required this.sourceId,
  }) {
    if (engineId.trim().isEmpty || version.trim().isEmpty || sourceId.trim().isEmpty) {
      throw ArgumentError('Zi Wei engine metadata must not be empty.');
    }
  }

  final String engineId;
  final String version;
  final String sourceId;
}
