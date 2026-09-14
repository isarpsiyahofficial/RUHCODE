/// Zi Wei Dou Shu calculation boundary.
///
/// RC-0159/RC-0160: Zi Wei Dou Shu is intentionally modeled as an independent
/// engine family. It must not be implemented as a BaZi feature, mode, or output
/// variant. Concrete Zi Wei calculations can be added behind this contract
/// without importing or mutating the BaZi domain.
abstract interface class ZiWeiDouShuEngine<I, O> {
  String get engineId;
  String get version;
  String get sourceId;

  O calculate(I input);
}

final class ZiWeiDouShuResultEnvelope<T> {
  ZiWeiDouShuResultEnvelope({
    required this.engineId,
    required this.version,
    required this.sourceId,
    required this.value,
  }) {
    if (engineId.trim().isEmpty ||
        version.trim().isEmpty ||
        sourceId.trim().isEmpty) {
      throw ArgumentError(
        'Zi Wei Dou Shu result provenance must not be empty.',
      );
    }
  }

  final String engineId;
  final String version;
  final String sourceId;
  final T value;
}
