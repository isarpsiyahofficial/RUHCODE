import 'dart:io';

import 'package:path/path.dart' as p;

import '../backup/backup_application_service.dart';
import '../backup/backup_import_coordinator.dart';
import '../backup/backup_platform_gateway.dart';
import '../backup/local_database_backup_exporter.dart';
import '../backup/local_database_backup_import_store.dart';
import '../data/local/core_repositories.dart';
import '../data/local/sqflite_local_database.dart';
import '../entitlements/entitlement_service.dart';
import '../entitlements/feature_access_guard.dart';
import '../entitlements/google_play_lifetime_ownership.dart';
import '../entitlements/local_entitlement_snapshot_store.dart';
import '../entitlements/local_entitlement_time_anchor.dart';
import '../entitlements/professional_repository_bundle.dart';
import '../pdf/combined_professional_pdf_application_service.dart';
import '../pdf/combined_professional_pdf_delivery_service.dart';
import '../pdf/pdf_combined_report.dart';
import '../pdf/pdf_platform_gateway.dart';
import '../pdf/persisted_calculation_pdf_source.dart';
import '../pdf/persisted_combined_pdf_projection.dart';
import '../pdf/unavailable_pdf_service.dart';
import '../pdf/western_natal_persistence_service.dart';

final class RuhCodeRuntime {
  RuhCodeRuntime._({
    required this.database,
    required this.coreRepositories,
    required this.professionalRepositories,
    required this.entitlements,
    required this.featureAccess,
    required this.backupActions,
    required this.professionalPdfSnapshotSource,
    required this.combinedProfessionalPdf,
    required this.combinedProfessionalPdfDelivery,
    required this.westernNatalPersistence,
    required this.startupOwnershipSync,
  });

  final SqfliteLocalDatabase database;
  final CoreRepositories coreRepositories;
  final ProfessionalRepositoryBundle professionalRepositories;
  final EntitlementService entitlements;
  final FeatureAccessGuard featureAccess;
  final BackupApplicationActions backupActions;

  /// Production persisted-calculation source shared by professional PDF
  /// selection and build composition. It reads calculation + manifest in one
  /// LocalDatabase transaction and never fabricates a snapshot from UI input.
  final LocalDatabaseProfessionalPdfSnapshotSource professionalPdfSnapshotSource;

  /// Combined-report application boundary. Catalog and preflight preview are
  /// production-wired now. Byte rendering remains explicitly fail-closed until
  /// the approved Unicode font/render chain is available.
  final CombinedProfessionalPdfApplicationService combinedProfessionalPdf;

  /// Native Save As/share delivery boundary for the exact sealed combined
  /// preview token. It still calls [combinedProfessionalPdf] before delivery,
  /// therefore rendering remains fail-closed while approved fonts are absent.
  final CombinedProfessionalPdfDeliveryService combinedProfessionalPdfDelivery;

  /// The single production persistence boundary for verified Western natal
  /// snapshots. CalculationManifest + sealed snapshot are committed atomically
  /// to the same LocalDatabase instance used by the PDF snapshot source.
  final WesternNatalPersistenceService westernNatalPersistence;

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

    final backupExporter = LocalDatabaseBackupExporter(database: database);
    final backupImportStore = LocalDatabaseBackupImportStore(
      database: database,
      snapshotDirectory: Directory(
        p.join(
          p.dirname(database.openedDatabasePath),
          'ruh_code_backup_safety_snapshots',
        ),
      ),
    );
    final backupActions = BackupApplicationService(
      packageSource: LocalDatabaseBackupPackageSource(backupExporter),
      platformGateway: const NativeBackupPlatformGateway(),
      importCoordinator: BackupImportCoordinator(store: backupImportStore),
    );

    final professionalPdfSnapshotSource =
        LocalDatabaseProfessionalPdfSnapshotSource(database: database);
    final combinedProjectionSource = PersistedCombinedPdfProjectionSource(
      snapshotSource: professionalPdfSnapshotSource,
    );
    final combinedProfessionalPdf = CombinedProfessionalPdfApplicationService(
      featureAccess: featureAccess,
      recordCatalog: professionalPdfSnapshotSource,
      snapshotSource: professionalPdfSnapshotSource,
      projectionSource: combinedProjectionSource,
      pdfService: const UnavailablePdfService<PdfCombinedReportProjection>(
        'Combined PDF byte rendering is unavailable until the approved Unicode font/render chain is production-ready.',
      ),
    );
    final combinedProfessionalPdfDelivery = CombinedProfessionalPdfDeliveryService(
      application: combinedProfessionalPdf,
      platform: const NativePdfPlatformGateway(),
    );
    final westernNatalPersistence = WesternNatalPersistenceService(
      database: database,
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
      backupActions: backupActions,
      professionalPdfSnapshotSource: professionalPdfSnapshotSource,
      combinedProfessionalPdf: combinedProfessionalPdf,
      combinedProfessionalPdfDelivery: combinedProfessionalPdfDelivery,
      westernNatalPersistence: westernNatalPersistence,
      startupOwnershipSync: startupOwnershipSync,
    );
  }

  Future<void> dispose() => database.close();
}
