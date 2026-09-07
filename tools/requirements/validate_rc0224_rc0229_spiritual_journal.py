#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
PRODUCTION = ROOT / 'lib/src/application/spiritual/spiritual_journal_core.dart'
TEST = ROOT / 'test/application/spiritual_journal_core_rc0224_rc0229_test.dart'
CONTRACT = ROOT / 'requirements/contracts/rc0224_rc0229_spiritual_journal_contract.json'
WORKFLOW = ROOT / '.github/workflows/rc0224-rc0229-spiritual-journal.yml'


def fail(message: str) -> None:
    raise SystemExit(f'RC0224_RC0229_FAIL: {message}')


def read(path: Path) -> str:
    if not path.is_file():
        fail(f'missing {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


def main() -> None:
    spec, production, test, contract_text, workflow = map(
        read, [SPEC, PRODUCTION, TEST, CONTRACT, WORKFLOW]
    )
    for clause in range(224, 230):
        if not re.search(rf'(?m)^\s*{clause}\.\s+', spec):
            fail(f'binding specification missing numbered clause {clause}')

    try:
        contract = json.loads(contract_text)
    except json.JSONDecodeError as exc:
        fail(f'invalid contract JSON: {exc}')
    expected_ids = [f'RC-{i:04d}' for i in range(224, 230)]
    actual_ids = [r.get('rc_id') for r in contract.get('requirements', [])]
    if actual_ids != expected_ids:
        fail(f'contract id/order mismatch: {actual_ids}')
    if [r.get('clause') for r in contract['requirements']] != list(range(224, 230)):
        fail('contract clause mapping mismatch')

    for token in [
        'enum ChakraId',
        'final class ChakraJournalEntry',
        'final class DreamJournalEntry',
        'final class AffirmationEntry',
        'final class GratitudeEntry',
        'final class RitualPlanEntry',
        'final class SpiritualJournalAggregate',
        'dreamsForDate',
        'localDateKey',
        '_requireDate',
        '_requireUtc',
        'List.unmodifiable',
    ]:
        if token not in production:
            fail(f'production token missing: {token}')

    for token in ['calculation_core/', 'Random(', 'dart:math']:
        if token in production:
            fail(f'journal domain crossed forbidden boundary: {token}')

    for token in [
        'RC-0224', 'RC-0225/0226', 'RC-0227', 'RC-0228', 'RC-0229',
        '2026-02-30', 'throwsArgumentError'
    ]:
        if token not in test:
            fail(f'regression evidence missing: {token}')

    if 'requirement-matrix-writers-rc0224-rc0229' not in workflow:
        fail('workflow lacks unique matrix concurrency group')
    for path in [
        'lib/src/application/spiritual/spiritual_journal_core.dart',
        'test/application/spiritual_journal_core_rc0224_rc0229_test.dart',
        'requirements/contracts/rc0224_rc0229_spiritual_journal_contract.json',
        'tools/requirements/validate_rc0224_rc0229_spiritual_journal.py',
    ]:
        if path not in workflow:
            fail(f'workflow binding missing {path}')
    if 'flutter test test/application/spiritual_journal_core_rc0224_rc0229_test.dart' not in workflow:
        fail('workflow does not execute dedicated regression')
    if 'for i in range(224,230)' not in workflow:
        fail('workflow matrix target set is not exact RC-0224..RC-0229')
    if "r['blocked']='YES'" not in workflow:
        fail('TESTED promotion must remain blocked')
    print('RC0224_RC0229_OK')


if __name__ == '__main__':
    main()
