from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract_path = ROOT / 'requirements/contracts/rc1286_rc1303_entitlement_transfer_contract.json'
production_path = ROOT / 'lib/src/entitlements/entitlement_scenario_matrix.dart'
test_path = ROOT / 'test/entitlements/entitlement_scenario_matrix_rc1286_rc1303_test.dart'

contract = json.loads(contract_path.read_text(encoding='utf-8'))
requirements = contract.get('requirements', {})
expected_ids = [f'RC-{i:04d}' for i in range(1286, 1304)]
if list(requirements.keys()) != expected_ids:
    raise SystemExit('RC1286_RC1303_FAIL: exact requirement IDs/order mismatch')

production = production_path.read_text(encoding='utf-8')
test = test_path.read_text(encoding='utf-8')
required_production_tokens = [
    'EntitlementScenario.free',
    'EntitlementScenario.pro',
    'EntitlementScenario.rewardedTemporary',
    'EntitlementScenario.offlinePro',
    'EntitlementScenario.purchaseRestore',
    'EntitlementScenario.reinstallRestore',
    'EntitlementScenario.deviceChangeRestore',
    'RuhFeatureIds.all',
    'ruhCodeAccountRequired => false',
    'emailPasswordRequiredForCoreUse => false',
    'accountBackendRequired => false',
    'csvBackupSupportsDeviceTransfer => true',
    'ruhCodeServerRequiredForTransfer => false',
    'userMayChooseExternalTransport => true',
    'ruhCodeManagesExternalCloudStorage => false',
    'automaticCloudBackupIsCoreRequirement => false',
    'primaryArchitectureIsOfflineFirst => true',
]
for token in required_production_tokens:
    if token not in production:
        raise SystemExit(f'RC1286_RC1303_FAIL: missing production token: {token}')

required_test_tokens = [
    'every Feature ID is covered exactly once in every scenario',
    'Free scenario follows the canonical catalog and PRO covers every feature',
    'rewarded temporary unlock never opens a non-rewardable PRO feature',
    'offline PRO and all restore scenarios preserve full PRO capability',
    'core use and device transfer stay server-account independent',
]
for token in required_test_tokens:
    if token not in test:
        raise SystemExit(f'RC1286_RC1303_FAIL: missing regression evidence: {token}')

print('RC1286_RC1303_OK')
