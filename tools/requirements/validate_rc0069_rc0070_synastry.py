#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0069_rc0070_synastry_contract.json'
RUNTIME = ROOT / 'lib/src/calculation_core/western/synastry.dart'
TEST = ROOT / 'test/calculation_core/western/synastry_test.dart'
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    spec = SPEC.read_text(encoding='utf-8')
    runtime = RUNTIME.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')

    require(contract['requirements']['RC-0069'] in spec, 'RC-0069 binding text mismatch.')
    require(contract['requirements']['RC-0070'] in spec, 'RC-0070 binding text mismatch.')
    for token in (
        'WesternSynastryComparison',
        'WesternSynastry',
        'personAJdTt',
        'personBJdTt',
        'AspectOrbPolicy',
        'matching ephemeris provenance',
        'WesternNatalAspects.phaseFor',
    ):
        require(token in runtime, f'Missing synastry runtime invariant token: {token}')
    require('DateTime.now' not in runtime, 'Synastry runtime must not depend on device current time.')
    require('http' not in runtime.lower(), 'Synastry runtime must not use network fallback.')
    require('RC-0069 and RC-0070' in test, 'Compiled synastry requirement regression is missing.')
    require('mismatched ephemeris provenance' in test, 'Fail-closed provenance regression is missing.')
    print('RC-0069/RC-0070 synastry contract: OK')


if __name__ == '__main__':
    main()
