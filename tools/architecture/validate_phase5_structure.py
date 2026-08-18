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
    'test/data/local/sqflite_local_database_test.dart': (
        'sqfliteFfiInit', 'rolls back', 'integrity', 'inMemoryDatabasePath'
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
print('SQLite adapter/test/Flutter quality gates are structurally present.')
print('NOTE: structural validation is not a substitute for a green Flutter Quality workflow or Android release proof.')
