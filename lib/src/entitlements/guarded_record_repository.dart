import '../data/local/json_record_repository.dart';
import 'feature_access_guard.dart';

/// Service-layer wrapper for feature-gated persisted records.
///
/// This prevents callers from bypassing route/UI locks and mutating or reading
/// a protected repository directly through application services.
final class GuardedRecordRepository<T> {
  const GuardedRecordRepository({
    required this.featureAccess,
    required this.featureId,
    required this.delegate,
  });

  final FeatureAccessGuard featureAccess;
  final String featureId;
  final JsonRecordRepository<T> delegate;

  Future<void> save(T value) => featureAccess.runService<void>(
        featureId: featureId,
        action: () => delegate.save(value),
      );

  Future<T?> findById(String id) => featureAccess.runService<T?>(
        featureId: featureId,
        action: () => delegate.findById(id),
      );

  Future<void> deleteById(String id) => featureAccess.runService<void>(
        featureId: featureId,
        action: () => delegate.deleteById(id),
      );

  Future<void> replaceAtomically({required T oldValue, required T newValue}) =>
      featureAccess.runService<void>(
        featureId: featureId,
        action: () => delegate.replaceAtomically(
          oldValue: oldValue,
          newValue: newValue,
        ),
      );
}
