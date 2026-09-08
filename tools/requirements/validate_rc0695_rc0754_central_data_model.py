from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0695_rc0754_central_data_model_contract.json'
PROD = ROOT / 'lib/src/data/central_record_model.dart'
TEST = ROOT / 'test/data/central_record_model_rc0695_rc0754_test.dart'

for path in (SPEC, CONTRACT, PROD, TEST):
    if not path.exists():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
prod = PROD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for n in range(695, 755):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        raise SystemExit(f'binding requirement {n}. missing')
    rc = f'RC-{n:04d}'
    if rc not in contract.get('requirements', {}):
        raise SystemExit(f'{rc} missing from exact contract')

for token in [
    'OpaqueLocalId', 'RecordMetadata', 'RecordKind.user', 'RecordKind.profile', 'RecordKind.client',
    'RecordKind.consultation', 'RecordKind.calculation', 'RecordKind.note', 'RecordKind.journal',
    'RecordKind.tarotSession', 'BirthTimePrecision.unknown', 'BirthTimePrecision.approximate',
    'BirthTimePrecision.exact', 'BirthPlace', 'ianaTimezoneId', 'CalculationManifestRecord',
    'engineVersion', 'algorithmVersion', 'dataVersion', 'timezoneDatabaseVersion', 'houseSystem',
    'zodiacSystem', 'ayanamsha', 'nodeMode', 'professionalSettings', 'SavedCalculationRecord',
    'RecalculationComparison', 'DataEnvelope', 'schemaVersion', 'CopyFirstMigrationEngine'
]:
    if token not in prod:
        raise SystemExit(f'production evidence token missing: {token}')

for phrase in [
    'Same display name never implies same identity',
    'Unknown birth time cannot silently become midnight',
    'Approximate and exact birth times remain explicit states',
    'Sidereal manifest fails closed without ayanamsha',
    'Old and recalculated results can coexist and be compared',
    'Migration is copy-first and advances schema one step at a time',
    'Migration fails closed if an intermediate version is missing'
]:
    if phrase not in test:
        raise SystemExit(f'regression evidence missing: {phrase}')

if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('status ceiling must stay IMPLEMENTED before persistence/backup/golden/release evidence closes')

print('RC-0695..RC-0754 central data model contract OK')
