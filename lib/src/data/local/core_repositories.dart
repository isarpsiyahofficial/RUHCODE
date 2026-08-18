import '../../domain/models/core_models.dart';
import 'core_model_codecs.dart';
import 'json_record_repository.dart';
import 'local_database.dart';

final class CoreRepositories {
  CoreRepositories(LocalDatabase database)
      : profiles = JsonRecordRepository<Profile>(
          database: database,
          table: 'profiles',
          idOf: (value) => value.id.value,
          encode: CoreModelCodecs.profileToMap,
          decode: CoreModelCodecs.profileFromMap,
        ),
        clients = JsonRecordRepository<Client>(
          database: database,
          table: 'clients',
          idOf: (value) => value.id.value,
          encode: CoreModelCodecs.clientToMap,
          decode: CoreModelCodecs.clientFromMap,
        ),
        calculationManifests = JsonRecordRepository<CalculationManifest>(
          database: database,
          table: 'calculation_manifests',
          idOf: (value) => value.id.value,
          encode: CoreModelCodecs.calculationManifestToMap,
          decode: CoreModelCodecs.calculationManifestFromMap,
        ),
        consultations = JsonRecordRepository<Consultation>(
          database: database,
          table: 'consultations',
          idOf: (value) => value.id.value,
          encode: CoreModelCodecs.consultationToMap,
          decode: CoreModelCodecs.consultationFromMap,
        ),
        notes = JsonRecordRepository<Note>(
          database: database,
          table: 'notes',
          idOf: (value) => value.id.value,
          encode: CoreModelCodecs.noteToMap,
          decode: CoreModelCodecs.noteFromMap,
        ),
        journalEntries = JsonRecordRepository<JournalEntry>(
          database: database,
          table: 'journal_entries',
          idOf: (value) => value.id.value,
          encode: CoreModelCodecs.journalEntryToMap,
          decode: CoreModelCodecs.journalEntryFromMap,
        ),
        goals = JsonRecordRepository<Goal>(
          database: database,
          table: 'goals',
          idOf: (value) => value.id.value,
          encode: CoreModelCodecs.goalToMap,
          decode: CoreModelCodecs.goalFromMap,
        ),
        habits = JsonRecordRepository<Habit>(
          database: database,
          table: 'habits',
          idOf: (value) => value.id.value,
          encode: CoreModelCodecs.habitToMap,
          decode: CoreModelCodecs.habitFromMap,
        ),
        tarotSessions = JsonRecordRepository<TarotSession>(
          database: database,
          table: 'tarot_sessions',
          idOf: (value) => value.id.value,
          encode: CoreModelCodecs.tarotSessionToMap,
          decode: CoreModelCodecs.tarotSessionFromMap,
        ),
        professionalPresets = JsonRecordRepository<ProfessionalPreset>(
          database: database,
          table: 'professional_presets',
          idOf: (value) => value.id.value,
          encode: CoreModelCodecs.professionalPresetToMap,
          decode: CoreModelCodecs.professionalPresetFromMap,
        ),
        interpretationTemplates = JsonRecordRepository<InterpretationTemplate>(
          database: database,
          table: 'interpretation_templates',
          idOf: (value) => value.id.value,
          encode: CoreModelCodecs.interpretationTemplateToMap,
          decode: CoreModelCodecs.interpretationTemplateFromMap,
        );

  final JsonRecordRepository<Profile> profiles;
  final JsonRecordRepository<Client> clients;
  final JsonRecordRepository<CalculationManifest> calculationManifests;
  final JsonRecordRepository<Consultation> consultations;
  final JsonRecordRepository<Note> notes;
  final JsonRecordRepository<JournalEntry> journalEntries;
  final JsonRecordRepository<Goal> goals;
  final JsonRecordRepository<Habit> habits;
  final JsonRecordRepository<TarotSession> tarotSessions;
  final JsonRecordRepository<ProfessionalPreset> professionalPresets;
  final JsonRecordRepository<InterpretationTemplate> interpretationTemplates;
}
