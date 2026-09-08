from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0633_rc0673_local_first_contract.json'
PROD = ROOT / 'lib/src/architecture/local_first_runtime_contract.dart'
TEST = ROOT / 'test/architecture/local_first_runtime_contract_rc0633_rc0673_test.dart'

for path in (SPEC, CONTRACT, PROD, TEST):
    if not path.exists():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
prod = PROD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for n in range(633, 674):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        raise SystemExit(f'binding requirement {n}. missing')
    rc = f'RC-{n:04d}'
    if rc not in contract.get('requirements', {}):
        raise SystemExit(f'{rc} missing from exact contract')

for token in [
    'CoreCapability.westernAstrology', 'CoreCapability.vedicAstrology', 'CoreCapability.numerology',
    'CoreCapability.bazi', 'CoreCapability.planetaryHours', 'CoreCapability.dailyAstrology',
    'CoreCapability.dailyNumerology', 'CoreCapability.userProfiles', 'CoreCapability.professionalClients',
    'CoreCapability.consultationNotes', 'CoreCapability.personalGrowthRecords', 'CoreCapability.tarotSessionRecords',
    'CoreCapability.favorites', 'CoreCapability.notificationPlanning', 'CoreCapability.pdfExport',
    'CoreCapability.csvExport', 'CoreCapability.csvImport', 'RuntimeLocation.onDevice',
    'ExternalDependency.ownedApi', 'ExternalDependency.vps', 'ExternalDependency.databaseServer',
    'ExternalDependency.firebase', 'ExternalDependency.supabase', 'ExternalDependency.aws',
    'ExternalDependency.cloudflareDatabase', 'ExternalDependency.paidAstrologyApi',
    'ExternalDependency.paidNumerologyApi', 'ExternalDependency.paidTimezoneApi',
    'ExternalDependency.paidCitySearchApi', 'ExternalDependency.paidPdfApi', 'ExternalDependency.paidAiApi',
    'bundledInterpretationCatalog', 'aiIsOptional', 'canRunCoreWithoutNetwork', 'CoreCostModel',
    'DailyInterpretationRuntimePolicy'
]:
    if token not in prod:
        raise SystemExit(f'production evidence token missing: {token}')

for phrase in [
    'every core capability on-device', 'Remote core capability fails closed',
    'paid external dependencies cannot become core requirements', 'Core cost model rejects per-user server work',
    'optional AI are mandatory architecture boundaries', 'without per-view AI'
]:
    if phrase not in test:
        raise SystemExit(f'regression evidence missing: {phrase}')

if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('status ceiling must remain IMPLEMENTED until device/offline/release evidence exists')

print('RC-0633..RC-0673 local-first contract OK')
