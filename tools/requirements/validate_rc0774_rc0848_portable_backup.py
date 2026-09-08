from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0774_rc0848_portable_backup_contract.json'
FILES = [
    ROOT / 'lib/src/backup/backup_schema.dart',
    ROOT / 'lib/src/backup/csv_codec.dart',
    ROOT / 'lib/src/backup/backup_package_codec.dart',
    ROOT / 'lib/src/backup/backup_package_manifest.dart',
    ROOT / 'lib/src/backup/backup_schema_validator.dart',
    ROOT / 'lib/src/backup/backup_import_coordinator.dart',
    ROOT / 'lib/src/backup/verified_backup_restore.dart',
    ROOT / 'test/backup/csv_codec_test.dart',
    ROOT / 'test/backup/backup_package_codec_test.dart',
    ROOT / 'test/backup/backup_import_coordinator_test.dart',
    ROOT / 'test/backup/verified_backup_restore_rc0774_rc0848_test.dart',
]
for path in [SPEC, CONTRACT, *FILES]:
    if not path.exists():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
text = '\n'.join(path.read_text(encoding='utf-8') for path in FILES)

for n in range(774, 849):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        raise SystemExit(f'binding requirement {n}. missing')
    rc = f'RC-{n:04d}'
    if rc not in contract.get('requirements', {}):
        raise SystemExit(f'{rc} missing from exact contract')

for token in [
    'profiles.csv','clients.csv','consultations.csv','notes.csv','calculations.csv',
    'calculation_manifests.csv','journal_entries.csv','goals.csv','habits.csv',
    'tarot_sessions.csv','tarot_cards.csv','favorites.csv','settings.csv',
    'RuhCsvValueCodec','RuhCsvDocumentCodec','nullSentinel','utf8.encode',
    'BackupPackageManifestV1','recordCount','sha256Hex','verifyFile',
    'BackupSchemaValidator','validateForeignKeys','BackupImportPreview',
    'BackupImportMode.merge','BackupImportMode.replace','createSafetySnapshot',
    'restoreSafetySnapshot','upsertTable','VerifiedBackupRestoreCoordinator',
    'Post-import data integrity validation failed'
]:
    if token not in text:
        raise SystemExit(f'backup evidence token missing: {token}')

if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('status ceiling must stay IMPLEMENTED before clean-install/stress/exact-release evidence closes')

print('RC-0774..RC-0848 portable backup contract OK')
