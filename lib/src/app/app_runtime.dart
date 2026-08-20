import '../data/local/sqflite_local_database.dart';
import '../entitlements/entitlement_service.dart';
import '../entitlements/feature_access_guard.dart';
import '../entitlements/local_entitlement_snapshot_store.dart';
import '../entitlements/local_entitlement_time_anchor.dart';

final class RuhCodeRuntime {
  RuhCodeRuntime._({
    required this.database,
    required this.entitlements,
    required this.featureAccess,
  });

  final SqfliteLocalDatabase database;
  final EntitlementService entitlements;
  final FeatureAccessGuard featureAccess;

  static Future<RuhCodeRuntime> create() async {
    final database = SqfliteLocalDatabase();
    await database.open();

    final snapshotStore = LocalEntitlementSnapshotStore(database);
    final entitlementService = PolicyEntitlementService(
      snapshotProvider: snapshotStore,
      clock: LocalRollbackResistantEntitlementClock(database: database),
    );
    final featureAccess = FeatureAccessGuard(entitlements: entitlementService);

    return RuhCodeRuntime._(
      database: database,
      entitlements: entitlementService,
      featureAccess: featureAccess,
    );
  }

  Future<void> dispose() => database.close();
}
