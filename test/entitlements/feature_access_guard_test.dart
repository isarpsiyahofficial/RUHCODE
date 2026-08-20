import 'package:flutter_test/flutter_test.dart';
import 'package:ruh_code/src/domain/models/core_models.dart';
import 'package:ruh_code/src/entitlements/entitlement_service.dart';
import 'package:ruh_code/src/entitlements/feature_access_guard.dart';
import 'package:ruh_code/src/entitlements/feature_catalog.dart';

void main() {
  test('UI route and service surfaces use the same EntitlementService result', () async {
    final service = _RecordingEntitlementService(
      allowed: <String, bool>{RuhFeatureIds.pdfProfessionalExport: false},
    );
    final guard = FeatureAccessGuard(entitlements: service);

    final ui = await guard.forUi(RuhFeatureIds.pdfProfessionalExport);
    final route = await guard.forRoute(RuhFeatureIds.pdfProfessionalExport);
    final backend = await guard.forService(RuhFeatureIds.pdfProfessionalExport);

    expect(ui.allowed, isFalse);
    expect(route.allowed, isFalse);
    expect(backend.allowed, isFalse);
    expect(ui.surface, FeatureAccessSurface.ui);
    expect(route.surface, FeatureAccessSurface.route);
    expect(backend.surface, FeatureAccessSurface.service);
    expect(
      service.canUseCalls,
      <String>[
        RuhFeatureIds.pdfProfessionalExport,
        RuhFeatureIds.pdfProfessionalExport,
        RuhFeatureIds.pdfProfessionalExport,
      ],
    );
  });

  test('runService never executes a locked action', () async {
    final service = _RecordingEntitlementService(
      allowed: <String, bool>{RuhFeatureIds.professionalClients: false},
    );
    final guard = FeatureAccessGuard(entitlements: service);
    var executed = false;

    await expectLater(
      guard.runService<void>(
        featureId: RuhFeatureIds.professionalClients,
        action: () async {
          executed = true;
        },
      ),
      throwsA(isA<FeatureAccessDeniedException>()),
    );
    expect(executed, isFalse);
  });

  test('runService executes exactly once when access is allowed', () async {
    final service = _RecordingEntitlementService(
      allowed: <String, bool>{RuhFeatureIds.westernNatalBasic: true},
    );
    final guard = FeatureAccessGuard(entitlements: service);
    var executions = 0;

    final value = await guard.runService<int>(
      featureId: RuhFeatureIds.westernNatalBasic,
      action: () async {
        executions += 1;
        return 42;
      },
    );

    expect(value, 42);
    expect(executions, 1);
  });

  test('invented feature IDs fail closed before entitlement lookup', () async {
    final service = _RecordingEntitlementService(allowed: const <String, bool>{});
    final guard = FeatureAccessGuard(entitlements: service);

    await expectLater(
      guard.forRoute('made.up.feature'),
      throwsA(isA<ArgumentError>()),
    );
    expect(service.canUseCalls, isEmpty);
  });
}

final class _RecordingEntitlementService implements EntitlementService {
  _RecordingEntitlementService({required this.allowed});

  final Map<String, bool> allowed;
  final List<String> canUseCalls = <String>[];

  @override
  Future<bool> canUse(String featureId) async {
    canUseCalls.add(featureId);
    return allowed[featureId] ?? false;
  }

  @override
  Future<FeatureEntitlement> resolve(String featureId) async {
    final canUseFeature = allowed[featureId] ?? false;
    return FeatureEntitlement(
      featureId: featureId,
      tier: canUseFeature ? EntitlementTier.pro : EntitlementTier.free,
    );
  }
}
