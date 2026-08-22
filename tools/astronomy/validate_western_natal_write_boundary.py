#!/usr/bin/env python3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
RUNTIME = ROOT / 'lib/src/app/app_runtime.dart'
CORE = ROOT / 'lib/src/data/local/core_repositories.dart'
PERSISTENCE = ROOT / 'lib/src/pdf/western_natal_persistence_service.dart'

errors = []

for path in (RUNTIME, CORE, PERSISTENCE):
    if not path.is_file():
        errors.append(f'missing required source: {path.relative_to(ROOT)}')

if RUNTIME.is_file():
    text = RUNTIME.read_text(encoding='utf-8')
    required = [
        "import '../pdf/western_natal_persistence_service.dart';",
        'final WesternNatalPersistenceService westernNatalPersistence;',
        'final westernNatalPersistence = WesternNatalPersistenceService(',
        'westernNatalPersistence: westernNatalPersistence,',
    ]
    for token in required:
        if token not in text:
            errors.append(f'runtime is not composed through WesternNatalPersistenceService: {token}')

if CORE.is_file():
    text = CORE.read_text(encoding='utf-8')
    # A generic public calculations repository would allow production callers to
    # bypass the atomic CalculationManifest + sealed snapshot boundary.
    forbidden = [
        "table: 'calculations'",
        'final JsonRecordRepository<Calculation',
        ' calculations;',
    ]
    for token in forbidden:
        if token in text:
            errors.append(f'CoreRepositories must not expose a direct calculation write path: {token}')

if PERSISTENCE.is_file():
    text = PERSISTENCE.read_text(encoding='utf-8')
    required = [
        "table: 'calculation_manifests'",
        "table: 'calculations'",
        'await database.transaction<void>',
        '_validateManifestSnapshotParity(manifest, snapshot);',
        'PersistedWesternNatalEnvelope.seal(snapshot)',
        'Calculation ID already exists',
        'Calculation manifest ID already exists',
    ]
    for token in required:
        if token not in text:
            errors.append(f'atomic Western persistence invariant missing: {token}')

# Scan production Dart sources for explicit calculations-table writes. Backup
# restore is intentionally exempt because it restores an already validated
# portable package. The Western persistence service is the only calculation
# creation path allowed for western.natal.
allowed_explicit_writers = {
    Path('lib/src/pdf/western_natal_persistence_service.dart'),
    Path('lib/src/backup/local_database_backup_import_store.dart'),
}
for path in (ROOT / 'lib/src').rglob('*.dart'):
    rel = path.relative_to(ROOT)
    text = path.read_text(encoding='utf-8')
    touches_calculations = "table: 'calculations'" in text
    writes = ('put(' in text or '.put(' in text or 'delete(' in text or '.delete(' in text)
    if touches_calculations and writes and rel not in allowed_explicit_writers:
        errors.append(f'unapproved production calculations-table write path: {rel}')

if errors:
    for error in errors:
        print(f'ERROR: {error}')
    raise SystemExit(1)

print('Western natal write-boundary contract: OK')
