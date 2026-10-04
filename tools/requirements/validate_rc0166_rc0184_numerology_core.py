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
]
for token in required_tokens:
    if token not in prod:
        fail(f'production binding missing token: {token}')

if "id: 'chaldean-latin'" not in prod or "'F':8" not in prod:
    fail('Chaldean table is missing or no longer structurally distinct')

text = TEST.read_text(encoding='utf-8')
for i in range(166, 185):
    marker = f'RC-{i:04d}'
    if marker not in text and not any(f'RC-{j:04d}' in text for j in range(max(166, i-2), min(184, i+2)+1)):
        fail(f'test evidence does not cover {marker}')

print('RC0166_RC0184_OK')
