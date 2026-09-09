from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract_path = ROOT / 'requirements/contracts/rc1304_rc1344_golden_lifecycle_contract.json'
production_path = ROOT / 'lib/src/lifecycle/golden_lifecycle.dart'
test_path = ROOT / 'test/lifecycle/golden_lifecycle_rc1304_rc1344_test.dart'

contract = json.loads(contract_path.read_text(encoding='utf-8'))
requirements = contract.get('requirements', {})
expected_ids = [f'RC-{i:04d}' for i in range(1304, 1345)]
if list(requirements.keys()) != expected_ids:
    raise SystemExit('RC1304_RC1344_FAIL: exact requirement IDs/order mismatch')

production = production_path.read_text(encoding='utf-8')
test = test_path.read_text(encoding='utf-8')

required_production_tokens = [
    'enum GoldenModule',
    'westernNatal',
    'vedic',
    'numerology',
    'bazi',
    'planetaryHours',
    'professionalClient',
    'backup',
    'pdf',
    'enum ModuleCompletionGate',
    'calculation',
    'ui',
    'interpretation',
    'turkish',
    'english',
    'export',
    'cache',
    'tests',
    'enum GoldenLifecycleStage',
    'createClient',
    'calculateNatal',
    'calculateVedic',
    'calculateNumerology',
    'addNote',
    'createConsultation',
    'exportPdf',
    'exportCsvBackup',
    'clearApplicationData',
    'restoreBackup',
    'reopenSameClient',
    'verifyBirthData',
    'verifyCalculationResults',
    'verifyNotes',
    'verifyProfessionalSettings',
    'exportPdfAfterRestore',
    'verifyRestoreParity',
    'enum GoldenLocale { tr, en }',
    'enum GoldenEntitlement { free, pro }',
    'enum GoldenConnectivity { offline, online }',
    'enum GoldenInstallState { cleanInstall, upgrade }',
    'Golden Lifecycle must execute against a release build.',
    'Critical lifecycle tests are red.',
    'Critical lifecycle tests may not be skipped.',
    'Golden Lifecycle restore parity failed',
]
for token in required_production_tokens:
    if token not in production:
        raise SystemExit(f'RC1304_RC1344_FAIL: missing production token: {token}')

required_test_tokens = [
    'RC-1304..1315 requires every module and every completion gate',
    'RC-1316..1334 enforces ordered real release lifecycle and restore parity',
    'RC-1335..1342 covers TR/EN x Free/PRO x offline/online x clean/upgrade',
    'RC-1343..1344 rejects debug builds, red critical tests and skipped critical tests',
    'hasLength(16)',
]
for token in required_test_tokens:
    if token not in test:
        raise SystemExit(f'RC1304_RC1344_FAIL: missing regression evidence: {token}')

print('RC1304_RC1344_OK')
