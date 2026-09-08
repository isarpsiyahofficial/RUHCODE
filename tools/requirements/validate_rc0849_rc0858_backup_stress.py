from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0849_rc0858_backup_stress_contract.json'
STRESS = ROOT / 'test/backup/backup_stress_rc0849_rc0858_test.dart'
LEGACY = ROOT / 'test/backup/legacy_backup_v0_migrator_test.dart'

for path in (SPEC, CONTRACT, STRESS, LEGACY):
    if not path.exists():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
stress = STRESS.read_text(encoding='utf-8')
legacy = LEGACY.read_text(encoding='utf-8')

for n in range(849, 859):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        raise SystemExit(f'binding requirement {n}. missing')
    rc = f'RC-{n:04d}'
    if rc not in contract.get('requirements', {}):
        raise SystemExit(f'{rc} missing from exact contract')

for token in [
    '1500', 'greaterThanOrEqualTo(4500)', 'İbrahim Şahin', 'Alex Smith',
    'ç, ğ, ı, İ, ö, ş, ü', 'Emoji 😀✨', 'Uzun not', "contains('\\n')",
    "'unknown'", 'isNull'
]:
    if token not in stress:
        raise SystemExit(f'stress evidence missing: {token}')

if 'legacy' not in legacy.lower() and 'migrat' not in legacy.lower():
    raise SystemExit('legacy-schema migration regression evidence missing')

if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('status ceiling must stay IMPLEMENTED until CI and exact-release gates are physically proven')

print('RC-0849..RC-0858 backup stress contract OK')
