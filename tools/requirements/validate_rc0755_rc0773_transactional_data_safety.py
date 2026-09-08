from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0755_rc0773_transactional_data_safety_contract.json'
PROD = ROOT / 'lib/src/data/local/data_safety_coordinator.dart'
DB = ROOT / 'lib/src/data/local/sqflite_local_database.dart'
EXPORT = ROOT / 'lib/src/backup/backup_application_service.dart'
TEST = ROOT / 'test/data/data_safety_coordinator_rc0755_rc0773_test.dart'

for path in (SPEC, CONTRACT, PROD, DB, EXPORT, TEST):
    if not path.exists():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
prod = PROD.read_text(encoding='utf-8')
db = DB.read_text(encoding='utf-8')
export = EXPORT.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for n in range(755, 774):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        raise SystemExit(f'binding requirement {n}. missing')
    rc = f'RC-{n:04d}'
    if rc not in contract.get('requirements', {}):
        raise SystemExit(f'{rc} missing from exact contract')

for token in [
    'NonDestructiveContext.appUpdate', 'NonDestructiveContext.localeChange',
    'NonDestructiveContext.themeChange', 'NonDestructiveContext.freeToPro',
    'NonDestructiveContext.proToFree', 'atomicMutate', 'startupIntegrityCheck',
    'createSnapshot', 'restoreSnapshot', 'LocalSnapshotStore', 'LocalDataSnapshot',
    'StartupIntegrityState.recoveryRequired'
]:
    if token not in prod:
        raise SystemExit(f'production evidence token missing: {token}')

for token in ['transaction<T>', 'PRAGMA integrity_check', 'clearTable', 'readTable']:
    if token not in db and token not in (ROOT / 'lib/src/data/local/local_database.dart').read_text(encoding='utf-8'):
        raise SystemExit(f'database evidence token missing: {token}')

if 'export' not in export.lower():
    raise SystemExit('portable export application evidence missing')

for phrase in [
    'app/locale/theme/tier transitions never mutate stored records',
    'related writes are atomic when a later mutation fails',
    'startup integrity failure exposes local recovery snapshots',
    'snapshot captures and restores complete affected tables atomically',
    'snapshot restore rejects incompatible schema before destructive work'
]:
    if phrase not in test:
        raise SystemExit(f'regression evidence missing: {phrase}')

if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('status ceiling must stay IMPLEMENTED before device/update/recovery/release evidence closes')

print('RC-0755..RC-0773 transactional data safety contract OK')
