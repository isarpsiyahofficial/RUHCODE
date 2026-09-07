#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
PRODUCTION = ROOT / 'lib/src/application/spiritual/spiritual_tools_core.dart'
TEST = ROOT / 'test/application/spiritual_tools_core_rc0212_rc0223_test.dart'
CONTRACT = ROOT / 'requirements/contracts/rc0212_rc0223_spiritual_tools_contract.json'
WORKFLOW = ROOT / '.github/workflows/rc0212-rc0223-spiritual-tools.yml'


def fail(message: str) -> None:
    raise SystemExit(f'RC0212_RC0223_FAIL: {message}')


def require_file(path: Path) -> str:
    if not path.is_file():
        fail(f'missing {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


def main() -> None:
    spec = require_file(SPEC)
    production = require_file(PRODUCTION)
    test = require_file(TEST)
    contract_text = require_file(CONTRACT)
    workflow = require_file(WORKFLOW)

    for clause in range(212, 224):
        if not re.search(rf'(?m)^\s*{clause}\.\s+', spec):
            fail(f'binding specification no longer contains numbered clause {clause}')

    try:
        contract = json.loads(contract_text)
    except json.JSONDecodeError as exc:
        fail(f'invalid JSON contract: {exc}')

    expected_ids = [f'RC-{i:04d}' for i in range(212, 224)]
    actual_ids = [entry.get('rc_id') for entry in contract.get('requirements', [])]
    if actual_ids != expected_ids:
        fail(f'contract ids/order mismatch: {actual_ids}')

    expected_clauses = list(range(212, 224))
    actual_clauses = [entry.get('clause') for entry in contract.get('requirements', [])]
    if actual_clauses != expected_clauses:
        fail(f'contract clause mapping mismatch: {actual_clauses}')

    required_production_tokens = [
        'enum SpiritualToolKind',
        'final class SpiritualToolsRegistry',
        'final class TarotDeckDefinition',
        'final class TarotSpreadDefinition',
        'TarotSpreadDefinition.oneCard',
        'TarotSpreadDefinition.threeCard',
        'final class TarotDrawEngine',
        'final class TarotInterpretationEntry',
        'editorialPolicyId',
        'abstract interface class IChingReadingProvider',
        'final class MoonCycleGuidance',
        'astronomySourceId',
        'editorialSourceId',
        'final class IntentionPractice',
        'final class DailyIntention',
        'final class MeditationContent',
        'final class BreathworkContent',
        'safetyNoteKey',
    ]
    for token in required_production_tokens:
        if token not in production:
            fail(f'production binding token missing: {token}')

    expected_kinds = ['tarot', 'iChing', 'moonCycle', 'intention', 'meditation', 'breathwork']
    enum_match = re.search(r'enum SpiritualToolKind\s*\{([^}]*)\}', production, re.S)
    if not enum_match:
        fail('SpiritualToolKind enum is unreadable')
    enum_body = enum_match.group(1)
    for kind in expected_kinds:
        if not re.search(rf'\b{re.escape(kind)}\b', enum_body):
            fail(f'SpiritualToolKind missing {kind}')

    forbidden_production_tokens = [
        "dart:math",
        'Random(',
        'calculation_core/',
        'WesternNatal',
        'VedicRashi',
    ]
    for token in forbidden_production_tokens:
        if token in production:
            fail(f'spiritual application domain crossed a forbidden boundary: {token}')

    if 'orderedCardIds' not in production:
        fail('Tarot draw is not caller-ordered/deterministic')
    if 'List.unmodifiable' not in production:
        fail('domain collections are not protected from external mutation')

    required_test_tokens = [
        'RC-0212/0213/0218-0223',
        'RC-0214',
        'RC-0215',
        'RC-0216',
        'RC-0217',
        'RC-0218',
        'RC-0219',
        'RC-0220/0221',
        'RC-0222',
        'RC-0223',
        'throwsArgumentError',
    ]
    for token in required_test_tokens:
        if token not in test:
            fail(f'regression evidence missing: {token}')

    if 'requirement-matrix-writers-rc0212-rc0223' not in workflow:
        fail('workflow lacks unique requirement-matrix concurrency group')
    for path in [
        'lib/src/application/spiritual/spiritual_tools_core.dart',
        'test/application/spiritual_tools_core_rc0212_rc0223_test.dart',
        'requirements/contracts/rc0212_rc0223_spiritual_tools_contract.json',
        'tools/requirements/validate_rc0212_rc0223_spiritual_tools.py',
    ]:
        if path not in workflow:
            fail(f'workflow path/test binding missing: {path}')
    if 'flutter test test/application/spiritual_tools_core_rc0212_rc0223_test.dart' not in workflow:
        fail('workflow does not execute dedicated compiled regression')
    if 'Promote RC-0212 through RC-0223 to TESTED' not in workflow:
        fail('workflow lacks physical TESTED promotion step')
    if "r['blocked']='YES'" not in workflow:
        fail('workflow promotion must remain blocked after TESTED')
    if 'for i in range(212,224)' not in workflow:
        fail('workflow matrix target set is not exact RC-0212..RC-0223')

    print('RC0212_RC0223_OK')


if __name__ == '__main__':
    main()
