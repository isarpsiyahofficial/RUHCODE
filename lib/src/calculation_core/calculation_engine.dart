import '../domain/models/core_models.dart';

abstract interface class CalculationEngine<TInput, TResult> {
  String get engineId;
  String get engineVersion;

  Future<CalculationResult<TResult>> calculate(TInput input);
}

final class CalculationResult<T> {
  const CalculationResult({required this.manifest, required this.value});
  final CalculationManifest manifest;
  final T value;
}
