import '../data/local/core_repositories.dart';
import '../domain/models/core_models.dart';
import 'feature_access_guard.dart';
import 'feature_catalog.dart';
import 'guarded_record_repository.dart';

/// Production composition root for persisted professional-only data.
///
/// Application services must receive this bundle instead of reaching directly
/// into [CoreRepositories] for professional client/preset data. This keeps the
/// service layer behind the same entitlement boundary used by UI/routes.
final class ProfessionalRepositoryBundle {
  ProfessionalRepositoryBundle({
    required FeatureAccessGuard featureAccess,
    required CoreRepositories core,
  })  : clients = GuardedRecordRepository<Client>(
          featureAccess: featureAccess,
          featureId: RuhFeatureIds.professionalClients,
          delegate: core.clients,
        ),
        consultations = GuardedRecordRepository<Consultation>(
          featureAccess: featureAccess,
          featureId: RuhFeatureIds.professionalClients,
          delegate: core.consultations,
        ),
        notes = GuardedRecordRepository<Note>(
          featureAccess: featureAccess,
          featureId: RuhFeatureIds.professionalClients,
          delegate: core.notes,
        ),
        presets = GuardedRecordRepository<ProfessionalPreset>(
          featureAccess: featureAccess,
          featureId: RuhFeatureIds.professionalPresets,
          delegate: core.professionalPresets,
        ),
        interpretationTemplates = GuardedRecordRepository<InterpretationTemplate>(
          featureAccess: featureAccess,
          featureId: RuhFeatureIds.professionalPresets,
          delegate: core.interpretationTemplates,
        );

  final GuardedRecordRepository<Client> clients;
  final GuardedRecordRepository<Consultation> consultations;
  final GuardedRecordRepository<Note> notes;
  final GuardedRecordRepository<ProfessionalPreset> presets;
  final GuardedRecordRepository<InterpretationTemplate> interpretationTemplates;
}
