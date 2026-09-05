#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0068_transit_timeline_contract.json'
RUNTIME = ROOT / 'lib/src/calculation_core/western/transit_timeline.dart'
TEST = ROOT / 'test/calculation_core/western/transit_timeline_test.dart'
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    spec = SPEC.read_text(encoding='utf-8')
    runtime = RUNTIME.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')
    require(contract['requirements']['RC-0068'] in spec, 'RC-0068 binding text mismatch.')
    for token in (
        'ImportantTransitEvent',
        'ImportantTransitPolicy',
        'WesternTransitTimeline',
        'comparison.transitJdTt',
        'share ephemeris provenance',
        'events.sort',
    ):
        require(token in runtime, f'Missing RC-0068 runtime invariant token: {token}')
    require('DateTime.now' not in runtime, 'Transit timeline must not depend on device current time.')
    require('http' not in runtime.lower(), 'Transit timeline must not use network fallback.')
    require('RC-0068' in test, 'Compiled RC-0068 regression is missing.')
    require('mixed ephemeris provenance' in test, 'Fail-closed provenance regression is missing.')
    print('RC-0068 transit timeline contract: OK')


if __name__ == '__main__':
    main()
