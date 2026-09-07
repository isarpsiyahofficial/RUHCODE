from pathlib import Path

SPEC = Path('RUH_CODE_MASTER_SARTNAME.md')
PROD = Path('lib/src/calculation_core/numerology/lo_shu_grid.dart')
TEST = Path('test/calculation_core/lo_shu_rc0185_rc0186_test.dart')
CONTRACT = Path('requirements/contracts/rc0185_rc0186_lo_shu_kabbalistic_boundary_contract.json')

for p in (SPEC, PROD, TEST, CONTRACT):
    if not p.exists():
        raise SystemExit(f'RC0185_RC0186_FAIL: missing {p}')

spec = SPEC.read_text(encoding='utf-8').splitlines()
for i in (185, 186):
    if not any(line.startswith(f'{i}.') for line in spec):
        raise SystemExit(f'RC0185_RC0186_FAIL: missing binding entry {i}')

prod = PROD.read_text(encoding='utf-8')
for token in ('LoShuGridEngine', 'LoShuGridResult', '[4, 9, 2]', 'digit == 0', 'KabbalisticNumerologySystem'):
    if token not in prod:
        raise SystemExit(f'RC0185_RC0186_FAIL: missing production token {token}')

if 'numerology_core.dart' in prod or 'PythagoreanNumerologyCore' in prod:
    raise SystemExit('RC0185_RC0186_FAIL: Lo Shu must not depend on Pythagorean core')

print('RC0185_RC0186_OK')
