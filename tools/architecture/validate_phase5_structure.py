#!/usr/bin/env python3
from pathlib import Path
import sys

ROOT = Path(__file__).resolve().parents[2]

REQUIRED_FILES = {
    'pubspec.yaml': ('flutter:', 'flutter_localizations:', 'sqflite:', 'sqflite_common_ffi:'),
    'lib/main.dart': ('RuhCodeApp',),
    'lib/src/app/ruh_code_app.dart': ('MaterialApp', 'MainNavigationShell'),
    'lib/src/ui/navigation/main_navigation_shell.dart': ('Bugün', 'Araçlar', 'Kayıtlar', 'Profil'),
    'lib/src/domain/ids/entity_id.dart': ('EntityId', 'newV4'),
    'lib/src/domain/models/core_models.dart': (
        'Profile', 'BirthData', 'LocationRecord', 'Client', 'CalculationManifest',
        'Consultation', 'Note', 'JournalEntry', 'Goal', 'Habit', 'TarotSession',
        'ProfessionalPreset', 'InterpretationTemplate', 'FeatureEntitlement', 'BackupManifest'
    ),
    'lib/src/data/local/local_database.dart': ('transaction', 'migrate', 'integrityCheck'),
    'lib/src/data/local/sqflite_local_database.dart': (
        'SqfliteLocalDatabase', 'PRAGMA integrity_check', 'app_meta', 'records',
        '_SqfliteTransaction', 'ConflictAlgorithm.replace'
    ),
    'lib/src/data/local/json_record_repository.dart': (
        'JsonRecordRepository', 'save', 'findById', 'deleteById', 'replaceAtomically'
    ),
    'lib/src/data/local/core_repositories.dart': (
        'CoreRepositories', 'profiles', 'clients', 'calculationManifests', 'consultations',
        'notes', 'journalEntries', 'goals', 'habits', 'tarotSessions',
        'professionalPresets', 'interpretationTemplates'
    ),
    'lib/src/data/local/core_model_codecs.dart': (
        'profileToMap', 'profileFromMap', 'clientToMap', 'clientFromMap',
        'calculationManifestToMap', 'calculationManifestFromMap',
        'consultationToMap', 'consultationFromMap', 'noteToMap', 'noteFromMap',
        'journalEntryToMap', 'journalEntryFromMap', 'goalToMap', 'goalFromMap',
        'habitToMap', 'habitFromMap', 'tarotSessionToMap', 'tarotSessionFromMap',
        'professionalPresetToMap', 'professionalPresetFromMap',
        'interpretationTemplateToMap', 'interpretationTemplateFromMap',
        'featureEntitlementToMap', 'featureEntitlementFromMap',
        'backupManifestToMap', 'backupManifestFromMap'
    ),
    'test/data/local/sqflite_local_database_test.dart': (
        'sqfliteFfiInit', 'rolls back', 'integrity', 'inMemoryDatabasePath'
    ),
    'test/data/local/core_model_codecs_test.dart': (
        'profile round trip', 'client round trip', 'calculation manifest round trip',
        'consultation and note round trips', 'journal, goal and habit round trips',
        'tarot and professional preset round trips',
        'interpretation entitlement and backup manifest round trips'
    ),
    'test/data/json_record_repository_test.dart': (
        'save find and delete use transactional storage',
        'atomic replace moves an entity to a new id in one transaction',
        'failed atomic replace rolls the delete back'
    ),
    'lib/src/calculation_core/calculation_engine.dart': ('CalculationEngine', 'CalculationResult'),
    'lib/src/interpretation/interpretation_engine.dart': ('InterpretationEngine',),
    'lib/src/backup/backup_service.dart': ('BackupService', 'BackupImportMode'),
    'lib/src/pdf/pdf_service.dart': ('PdfService',),
    'lib/src/entitlements/entitlement_service.dart': ('EntitlementService',),
    '.github/workflows/flutter-quality.yml': ('flutter analyze --fatal-infos', 'flutter test'),
}

errors = []
for relative, tokens in REQUIRED_FILES.items():
    path = ROOT / relative
    if not path.is_file():
        errors.append(f'missing file: {relative}')
        continue
    text = path.read_text(encoding='utf-8')
    for token in tokens:
        if token not in text:
            errors.append(f'{relative}: missing contract token {token!r}')

if errors:
    print('Phase 5 architecture contract FAILED')
    for error in errors:
        print(f'- {error}')
    sys.exit(1)

print(f'Phase 5 architecture contract OK: {len(REQUIRED_FILES)} files checked')
print('SQLite adapter, transactional typed repositories, complete core-model codecs and Flutter quality gates are structurally present.')
print('NOTE: structural validation is not a substitute for a green Flutter Quality workflow or Android release proof.')
