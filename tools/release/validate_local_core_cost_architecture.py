#!/usr/bin/env python3
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'governance/local_core_cost_contract.json'
NETWORK = ROOT / 'governance/network_call_inventory.json'
PUBSPEC = ROOT / 'pubspec.yaml'

FORBIDDEN_DEPENDENCY_PATTERNS = (
    re.compile(r'^\s*(firebase_(?:auth|database|firestore|functions)|cloud_firestore|supabase|appwrite|parse_server_sdk|dio|http)\s*:', re.M),
)
DIRECT_NETWORK_TOKENS = ('package:http/', 'package:dio/', 'HttpClient(', 'Socket.connect(', 'WebSocket.connect(')


def fail(message: str) -> None:
    raise SystemExit(f'RC1405_RC1420_FAIL: {message}')


def path_exists(spec: str) -> bool:
    path = ROOT / spec
    return path.exists()


def main() -> int:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    if contract.get('costTarget') != 'zero_ongoing_backend_or_paid_api_cost_for_core':
        fail('cost target is not exact')
    capabilities = contract.get('localCoreCapabilities')
    if not isinstance(capabilities, dict) or len(capabilities) != 10:
        fail('ten local core capability groups are required')
    missing_groups = []
    for capability, candidates in capabilities.items():
        if not isinstance(candidates, list) or not candidates or not any(path_exists(item) for item in candidates):
            missing_groups.append(capability)
    if missing_groups:
        fail(f'local capability evidence paths missing: {missing_groups}')

    pubspec = PUBSPEC.read_text(encoding='utf-8')
    for pattern in FORBIDDEN_DEPENDENCY_PATTERNS:
        match = pattern.search(pubspec)
        if match:
            fail(f'backend/network dependency requires explicit architectural review: {match.group(1)}')

    network = json.loads(NETWORK.read_text(encoding='utf-8'))
    for entry in network.get('directApplicationNetworkCalls', []):
        if bool(entry.get('coreRequired')):
            fail(f'direct network call marked coreRequired: {entry}')
    for entry in network.get('sdkManagedNetworkCapabilities', []):
        if bool(entry.get('coreRequired')):
            fail(f'SDK-managed network capability marked coreRequired: {entry}')

    # Defense in depth: direct networking primitives in production require the
    # dedicated RC-1345..1361 inventory gate. Here we additionally reject any
    # such primitive under the explicitly local core evidence roots.
    local_roots: set[Path] = set()
    for candidates in capabilities.values():
        for candidate in candidates:
            path = ROOT / candidate
            if path.exists():
                local_roots.add(path)
    offenders = []
    for root in sorted(local_roots):
        files = [root] if root.is_file() else list(root.rglob('*.dart'))
        for file in files:
            if not file.is_file() or file.suffix != '.dart':
                continue
            text = file.read_text(encoding='utf-8', errors='replace')
            if any(token in text for token in DIRECT_NETWORK_TOKENS):
                offenders.append(file.relative_to(ROOT).as_posix())
    if offenders:
        fail(f'direct network primitive found in local core roots: {sorted(set(offenders))}')

    identity = contract.get('releaseIdentity', {})
    if identity.get('required') != ['gitTag', 'commitSha', 'artifactSha256']:
        fail('release identity must require gitTag/commitSha/artifactSha256')
    if identity.get('exactArtifactMustMatchTestedCommit') is not True:
        fail('tested commit and artifact commit must match')

    print('RC1405_RC1420_LOCAL_CORE_ARCHITECTURE_OK')
    print(f'LOCAL_CAPABILITY_GROUPS={len(capabilities)}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
