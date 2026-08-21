#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'lib/src/calculation_core/numerology/pythagorean_snapshot_fingerprint.dart'
TEST = ROOT / 'test/calculation_core/numerology/pythagorean_snapshot_fingerprint_test.dart'
EVIDENCE = ROOT / 'evidence/numerology/pythagorean_snapshot_fingerprint.json'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    for path in (SOURCE, TEST, EVIDENCE):
        require(path.exists(), f'Missing fingerprint contract file: {path}')

    source = SOURCE.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))

    for token in [
        "sha256.convert(utf8.encode(canonical)).toString()",
        "PythagoreanNumerologySnapshotEngine.engineId",
        "profileKarmicDebt",
        "cycleKarmicDebt",
        "targetDate",
        "canonicalJson",
    ]:
        require(token in source, f'Fingerprint source missing: {token}')

    for token in [
        'is deterministic for the same canonical snapshot',
        'changes when exact target date changes',
        'changes when normalized name calculation changes',
        'excludes translated interpretation text',
        "RegExp(r'^[a-f0-9]{64}$')",
    ]:
        require(token in test, f'Fingerprint test missing: {token}')

    require(evidence.get('done') is False, 'Fingerprint evidence cannot claim DONE yet')
    invariants = evidence.get('invariants', [])
    require(len(invariants) >= 5, 'Fingerprint evidence needs explicit invariants')
    blockers = evidence.get('notProvenYet', [])
    require(len(blockers) >= 3, 'Fingerprint evidence must retain production blockers')

    print('Pythagorean snapshot fingerprint contract: OK')


if __name__ == '__main__':
    main()
