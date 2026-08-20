import '../data/local/core_repositories.dart';
import '../data/local/sqflite_local_database.dart';
import '../entitlements/entitlement_service.dart';
import '../entitlements/feature_access_guard.dart';
import '../entitlements/google_play_lifetime_ownership.dart';
import '../entitlements/local_entitlement_snapshot_store.dart';
import '../entitlements/local_entitlement_time_anchor.dart';
import '../entitlements/professional_repository_bundle.dart';

final class RuhCodeRuntime {
  RuhCodeRuntime._({
    required this.database,
    required this.coreRepositories,
    required this.professionalRepositories,
    required this.entitlements,
    required this.featureAccess,
    required this.startupOwnershipSync,
  });

  final SqfliteLocalDatabase database;
  final CoreRepositories coreRepositories;
  final ProfessionalRepositoryBundle professionalRepositories;
  final EntitlementService entitlements;
  final FeatureAccessGuard featureAccess;

  /// Best-effort Google Play ownership refresh performed during startup.
  ///
  /// A null value means the platform query threw before it could return a
  /// typed result. Startup still succeeds and cached ownership remains usable.
  final GooglePlayOwnershipSyncResult? startupOwnershipSync;

  static Future<RuhCodeRuntime> create({
    LifetimeOwnershipQuery? lifetimeOwnershipQuery,
  }) async {
    final database = SqfliteLocalDatabase();
    await database.open();

    final localSnapshotStore = LocalEntitlementSnapshotStore(database);
    final ownershipCache = GooglePlayOwnershipCache(database);
    final clock = LocalRollbackResistantEntitlementClock(database: database);

    final compositeSnapshotProvider = CompositeEntitlementSnapshotProvider(
      localProvider: localSnapshotStore,
      googlePlayCache: ownershipCache,
    );
    final entitlementService = PolicyEntitlementService(
      snapshotProvider: compositeSnapshotProvider,
      clock: clock,
    );
    final featureAccess = FeatureAccessGuard(entitlements: entitlementService);

    final coreRepositories = CoreRepositories(database);
    final professionalRepositories = ProfessionalRepositoryBundle(
      featureAccess: featureAccess,
      core: coreRepositories,
    );

    final ownershipSynchronizer = GooglePlayLifetimeOwnershipSynchronizer(
      query: lifetimeOwnershipQuery ?? const GooglePlayLifetimeOwnershipQuery(),
      cache: ownershipCache,
      clock: clock,
    );

    GooglePlayOwnershipSyncResult? startupOwnershipSync;
    try {
      startupOwnershipSync = await ownershipSynchronizer.synchronize();
    } catch (_) {
      // Store/plugin failures must never prevent the offline-first application
      // from starting or revoke an already-confirmed cached lifetime purchase.
      startupOwnershipSync = null;
    }

    return RuhCodeRuntime._(
      database: database,
      coreRepositories: coreRepositories,
      professionalRepositories: professionalRepositories,
      entitlements: entitlementService,
      featureAccess: featureAccess,
      startupOwnershipSync: startupOwnershipSync,
    );
  }

  Future<void> dispose() => database.close();
}
