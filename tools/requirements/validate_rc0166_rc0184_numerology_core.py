from pathlib import Path

SPEC = Path('RUH_CODE_MASTER_SARTNAME.md')
PROD = Path('lib/src/calculation_core/numerology/numerology_core.dart')
TEST = Path('test/calculation_core/numerology_core_rc0166_rc0184_test.dart')
CONTRACT = Path('requirements/contracts/rc0166_rc0184_numerology_core_contract.json')


def fail(message: str) -> None:
    raise SystemExit(f'RC0166_RC0184_FAIL: {message}')

for p in (SPEC, PROD, TEST, CONTRACT):
    if not p.exists():
        fail(f'missing {p}')

spec_lines = SPEC.read_text(encoding='utf-8').splitlines()
for i in range(166, 185):
    prefix = f'{i}.'
    if not any(line.startswith(prefix) for line in spec_lines):
        fail(f'binding specification missing numbered entry {i}')

prod = PROD.read_text(encoding='utf-8')
required_tokens = [
    'lifePath(', 'birthday(', 'nameNumbers(', 'maturity(', 'karmicDebtNumbers(',
    'personalYear(', 'personalMonth(', 'personalDay(', 'periods(',
    'NumerologyCompatibilityEngine', 'NumerologyNameNormalizer',
    'static NumerologyAlphabet pythagorean(', 'static NumerologyAlphabet chaldean(',
    "if (!alphabet.id.startsWith('pythagorean'))",
    "'Ç':'C'", "'Ğ':'G'", "'İ':'I'", "'Ş':'S'", "'Ü':'U'",
    '_balanceInitialTotal(',
]
for token in required_tokens:
    if token not in prod:
        fail(f'production binding missing token: {token}')

if "id: 'chaldean-latin'" not in prod or "'F':8" not in prod:
    fail('Chaldean table is missing or no longer structurally distinct')

text = TEST.read_text(encoding='utf-8')
# Every binding requirement must have an explicit marker. Nearby or grouped
# requirements must never be accepted as a substitute for a missing RC.
for i in range(166, 185):
    marker = f'RC-{i:04d}'
    if marker not in text:
        fail(f'test evidence does not explicitly cover {marker}')

for required_fixture in (
    "expect(ada.balance, 4)",
    "expect(ipek.balance, 1)",
    "expect(r.karmicLessons, <int>{3, 4, 6, 8})",
    "expect(r.hiddenPassion, <int>{5})",
    "expect(r.pinnacles, <int>[8, 2, 1, 8])",
    "expect(r.challenges, <int>[6, 0, 6, 6])",
    "expect(c.values['F'], 8)",
):
    if required_fixture not in text:
        fail(f'exact regression fixture missing: {required_fixture}')

print('RC0166_RC0184_OK')
