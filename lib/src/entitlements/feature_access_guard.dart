import 'entitlement_service.dart';
import 'feature_catalog.dart';

enum FeatureAccessSurface { ui, menu, route, service }

enum FeatureAccessOutcome { allowed, locked }

final class FeatureAccessDecision {
  const FeatureAccessDecision({
    required this.featureId,
    required this.surface,
    required this.outcome,
  });

  final String featureId;
  final FeatureAccessSurface surface;
  final FeatureAccessOutcome outcome;

  bool get allowed => outcome == FeatureAccessOutcome.allowed;
}

/// Single access gate for UI visibility/interaction, menu visibility, route
/// entry and service execution. All surfaces resolve through the same
/// EntitlementService; local premium booleans are deliberately not accepted.
final class FeatureAccessGuard {
  const FeatureAccessGuard({required this.entitlements});

  final EntitlementService entitlements;

  Future<FeatureAccessDecision> forUi(String featureId) =>
      _check(featureId, FeatureAccessSurface.ui);

  Future<FeatureAccessDecision> forMenu(String featureId) =>
      _check(featureId, FeatureAccessSurface.menu);

  Future<FeatureAccessDecision> forRoute(String featureId) =>
      _check(featureId, FeatureAccessSurface.route);

  Future<FeatureAccessDecision> forService(String featureId) =>
      _check(featureId, FeatureAccessSurface.service);

  Future<T> runService<T>({
    required String featureId,
    required Future<T> Function() action,
  }) async {
    final decision = await forService(featureId);
    if (!decision.allowed) {
      throw FeatureAccessDeniedException(featureId);
    }
    return action();
  }

  Future<FeatureAccessDecision> _check(
    String featureId,
    FeatureAccessSurface surface,
  ) async {
    RuhFeatureCatalog.policyFor(featureId);
    final allowed = await entitlements.canUse(featureId);
    return FeatureAccessDecision(
      featureId: featureId,
      surface: surface,
      outcome: allowed ? FeatureAccessOutcome.allowed : FeatureAccessOutcome.locked,
    );
  }
}

final class FeatureAccessDeniedException implements Exception {
  const FeatureAccessDeniedException(this.featureId);

  final String featureId;

  @override
  String toString() => 'FeatureAccessDeniedException($featureId)';
}
