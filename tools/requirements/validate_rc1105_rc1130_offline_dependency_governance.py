#!/usr/bin/env python3
from pathlib import Path
import json
import re
import sys

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1105_rc1130_offline_dependency_governance_contract.json'
INVENTORY = ROOT / 'governance/runtime_license_inventory.json'
PUBSPEC = ROOT / 'pubspec.yaml'
LOCKFILE = ROOT / 'pubspec.lock'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
PROD = ROOT / 'lib/src/architecture/offline_startup_and_dependency_governance.dart'
LOCAL_FIRST = ROOT / 'lib/src/architecture/local_first_runtime_contract.dart'
TEST = ROOT / 'test/architecture/offline_startup_dependency_governance_rc1105_rc1130_test.dart'
RELEASE_MODE = '--release' in sys.argv


def fail(msg: str) -> None:
    raise SystemExit(f'RC1105_RC1130_FAIL: {msg}')


for path in (CONTRACT, INVENTORY, PUBSPEC, MASTER, PROD, LOCAL_FIRST, TEST):
    if not path.exists():
        fail(f'missing evidence file: {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = [f'RC-{i:04d}' for i in range(1105, 1131)]
if list(contract.get('requirements', {}).keys()) != expected:
    fail('contract must preserve exact RC-1105..RC-1130 order with no omissions')

master = MASTER.read_text(encoding='utf-8')
for n in range(1105, 1131):
    if f'{n}.' not in master:
        fail(f'binding master requirement {n} not found')

pubspec = PUBSPEC.read_text(encoding='utf-8')
# Parse simple dependency declarations from dependency/dev_dependency blocks.
section = None
declared = {}
for raw in pubspec.splitlines():
    if raw == 'dependencies:':
        section = 'runtime'
        continue
    if raw == 'dev_dependencies:':
        section = 'dev'
        continue
    if raw.startswith('flutter:') and not raw.startswith('  '):
        section = None
    if section and re.match(r'^  [A-Za-z0-9_]+:', raw):
        key, value = raw.strip().split(':', 1)
        value = value.strip()
        if value:
            declared[key] = (value, section)

for name, (constraint, _) in declared.items():
    if constraint.lower() in {'any', 'latest', '*'}:
        fail(f'uncontrolled dependency constraint forbidden: {name}={constraint}')

inventory = json.loads(INVENTORY.read_text(encoding='utf-8'))
inv_deps = {item['id']: item for item in inventory.get('dependencies', [])}
sdk_deps = {item['id']: item for item in inventory.get('sdkDependencies', [])}
for name in declared:
    if name in {'flutter', 'flutter_localizations', 'flutter_test'}:
        if name not in sdk_deps:
            fail(f'SDK dependency missing from license inventory: {name}')
    elif name not in inv_deps:
        fail(f'dependency missing from license inventory: {name}')

required_dataset_paths = {
    'assets/data/cities/cities500.catalog.jsonl.gz',
    'assets/data/eop/finals2000A.all',
    'assets/data/ephemeris/de440s.bsp',
}
datasets = inventory.get('datasets', [])
inventory_paths = {item.get('path') for item in datasets}
missing_datasets = required_dataset_paths - inventory_paths
if missing_datasets:
    fail(f'bundled dataset missing from license inventory: {sorted(missing_datasets)}')

for item in datasets:
    path = ROOT / item['path']
    if not path.exists():
        fail(f'inventoried runtime dataset is missing: {item["path"]}')
    if item.get('attributionRequired') is True:
        attribution = item.get('attributionPath')
        if not attribution or not (ROOT / attribution).exists():
            fail(f'required attribution artifact missing for {item["id"]}')

refs = {item.get('id'): item for item in inventory.get('verificationReferences', [])}
for name in ('AKILES', 'Swiss Ephemeris'):
    item = refs.get(name)
    if not item or item.get('role') != 'development_qa_reference_only' or item.get('runtimeApproved') is not False:
        fail(f'{name} must remain QA-only until separately runtime-approved')

combined = PROD.read_text(encoding='utf-8') + '\n' + LOCAL_FIRST.read_text(encoding='utf-8')
for token in (
    'OfflineStartupPlan', 'canBecomeLocallyReadyOffline', 'DependencyChangeGate',
    'lockfilePresent', 'VerificationReferencePolicy', 'canRunCoreWithoutNetwork',
    'paidCitySearchApi', 'paidAstrologyApi',
):
    if token not in combined:
        fail(f'governance evidence token missing: {token}')

if RELEASE_MODE:
    if not LOCKFILE.exists():
        fail('release requires committed pubspec.lock')
    unresolved = []
    for item in datasets:
        if item.get('licenseStatus') != 'approved' or item.get('commercialRedistributionApproved') is not True:
            unresolved.append(item['id'])
    for item in inventory.get('dependencies', []):
        if item.get('licenseStatus') != 'approved':
            unresolved.append(f'dependency:{item["id"]}')
    for item in inventory.get('sdkDependencies', []):
        if item.get('licenseStatus') not in {'approved', 'sdk_managed_approved'}:
            unresolved.append(f'sdk:{item["id"]}')
    if unresolved:
        fail(f'release licensing remains unresolved: {sorted(unresolved)}')

print('RC1105_RC1130_OK' + ('_RELEASE' if RELEASE_MODE else ''))
