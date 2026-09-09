from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract_path = ROOT / 'requirements/contracts/rc1345_rc1361_release_cleanliness_contract.json'
audit_path = ROOT / 'tools/release/audit_production_cleanliness.py'
inventory_path = ROOT / 'governance/network_call_inventory.json'

contract = json.loads(contract_path.read_text(encoding='utf-8'))
requirements = contract.get('requirements', {})
expected_ids = [f'RC-{i:04d}' for i in range(1345, 1362)]
if list(requirements.keys()) != expected_ids:
    raise SystemExit('RC1345_RC1361_FAIL: exact requirement IDs/order mismatch')

audit = audit_path.read_text(encoding='utf-8')
inventory = json.loads(inventory_path.read_text(encoding='utf-8'))
for token in [
    'skip\\s*:\\s*true',
    'lorem ipsum',
    'coming soon',
    'mock calculation',
    'debug api',
    'directApplicationNetworkCalls',
    'forbiddenNetworkPurposes',
    'network inventory mismatch',
    'forbidden core network purpose',
]:
    if token not in audit:
        raise SystemExit(f'RC1345_RC1361_FAIL: missing audit token: {token}')

for purpose in [
    'calculation',
    'pdf_generation',
    'csv_export',
    'csv_restore',
    'profile_open',
    'professional_client_local_crud',
]:
    if purpose not in inventory.get('forbiddenNetworkPurposes', []):
        raise SystemExit(f'RC1345_RC1361_FAIL: missing forbidden network purpose: {purpose}')

print('RC1345_RC1361_CONTRACT_OK')
