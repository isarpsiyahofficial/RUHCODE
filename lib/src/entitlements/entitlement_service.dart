import '../domain/models/core_models.dart';

abstract interface class EntitlementService {
  Future<FeatureEntitlement> resolve(String featureId);
  Future<bool> canUse(String featureId);
}
