from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
LIB = ROOT / 'lib'
INVENTORY = ROOT / 'governance/network_call_inventory.json'
REQUIREMENT_STATE = ROOT / 'requirements/requirement_state.csv'

FORBIDDEN_TEXT = {
    'lorem ipsum': 'placeholder prose',
    'coming soon': 'mandatory feature placeholder',
    'placeholder interpretation': 'placeholder interpretation',
    'fake calculation': 'fake calculation result',
    'mock calculation': 'mock calculation result',
    'debug api': 'debug API endpoint',
}
NETWORK_PATTERNS = {
    "package:http": re.compile(r"package:http/"),
    "package:dio": re.compile(r"package:dio/"),
    "dart:io HttpClient": re.compile(r"\bHttpClient\s*\("),
    "dart:io Socket": re.compile(r"\bSocket\.(?:connect|startConnect)\s*\("),
    "dart:io WebSocket": re.compile(r"\bWebSocket\.connect\s*\("),
    "http URL literal": re.compile(r"https?://", re.IGNORECASE),
}


def production_files() -> list[Path]:
    return sorted(path for path in LIB.rglob('*.dart') if path.is_file())


def relative(path: Path) -> str:
    return path.relative_to(ROOT).as_posix()


def fail(message: str) -> None:
    raise SystemExit(f'RC1345_RC1361_FAIL: {message}')


if not INVENTORY.exists():
    fail('network inventory is missing')
inventory = json.loads(INVENTORY.read_text(encoding='utf-8'))
if inventory.get('directApplicationNetworkCalls') is None:
    fail('directApplicationNetworkCalls must be explicit')
if not isinstance(inventory.get('sdkManagedNetworkCapabilities'), list):
    fail('sdkManagedNetworkCapabilities must be explicit')

# RC-1345: skipped critical tests may never be used as final evidence.
critical_skip_patterns = [
    re.compile(r'\bskip\s*:\s*true\b'),
    re.compile(r'@Skip\b'),
]
for path in sorted((ROOT / 'test').rglob('*')) if (ROOT / 'test').exists() else []:
    if not path.is_file() or path.suffix not in {'.dart', '.py'}:
        continue
    text = path.read_text(encoding='utf-8', errors='replace')
    if any(pattern.search(text) for pattern in critical_skip_patterns):
        fail(f'skipped test evidence found: {relative(path)}')

# RC-1346: a mandatory requirement cannot be final while TODO remains in its lifecycle state.
if REQUIREMENT_STATE.exists():
    state = REQUIREMENT_STATE.read_text(encoding='utf-8', errors='replace')
    if ',DONE,' in state and re.search(r'(?im)^RC-\d{4},[^\n]*\bTODO\b', state):
        fail('DONE requirement contains TODO evidence/state text')

# RC-1347..1354: production sources must not contain release placeholders, fake data paths,
# hidden debug APIs, or common test-client fixtures.
for path in production_files():
    text = path.read_text(encoding='utf-8', errors='replace')
    lowered = text.lower()
    for token, meaning in FORBIDDEN_TEXT.items():
        if token in lowered:
            fail(f'{meaning} found in {relative(path)}')
    if re.search(r'(?i)\b(test|demo)[ _-]?client(?:id|name|record)?\b', text):
        fail(f'test/demo client marker found in production source: {relative(path)}')
    if re.search(r'(?i)\b(debug|dev)[ _-]?(menu|endpoint)\b', text):
        fail(f'hidden debug surface found in production source: {relative(path)}')

# RC-1355..1361: direct application network usage is inventory-controlled and forbidden for core paths.
discovered: list[dict[str, str]] = []
for path in production_files():
    text = path.read_text(encoding='utf-8', errors='replace')
    for primitive, pattern in NETWORK_PATTERNS.items():
        if pattern.search(text):
            discovered.append({'path': relative(path), 'primitive': primitive})

inventory_entries = inventory['directApplicationNetworkCalls']
inventory_keys = {
    (str(entry.get('path', '')), str(entry.get('primitive', ''))): entry
    for entry in inventory_entries
}
discovered_keys = {(item['path'], item['primitive']) for item in discovered}
if discovered_keys != set(inventory_keys):
    missing = sorted(discovered_keys - set(inventory_keys))
    stale = sorted(set(inventory_keys) - discovered_keys)
    fail(f'network inventory mismatch missing={missing} stale={stale}')

for key, entry in inventory_keys.items():
    reason = str(entry.get('reason', '')).strip()
    purpose = str(entry.get('purpose', '')).strip()
    if not reason or not purpose:
        fail(f'network entry lacks purpose/reason: {key}')
    if purpose in set(inventory.get('forbiddenNetworkPurposes', [])):
        fail(f'forbidden core network purpose: {purpose} at {key}')

print('RC1345_RC1361_OK')
print(f'PRODUCTION_DART_FILES={len(production_files())}')
print(f'DIRECT_NETWORK_CALLS={len(discovered)}')
