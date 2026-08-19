from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
source = ROOT / 'lib/src/calculation_core/western/essential_dignities.dart'
test = ROOT / 'test/calculation_core/western/essential_dignities_test.dart'
evidence = ROOT / 'evidence/astronomy/western_essential_dignities.json'

for path in (source, test, evidence):
    if not path.exists():
        raise SystemExit(f'missing required file: {path.relative_to(ROOT)}')

text = source.read_text(encoding='utf-8')
required_source = [
    'enum EssentialDignity',
    'AstroBody.sun: {TropicalZodiacSign.leo}',
    'AstroBody.mercury: {TropicalZodiacSign.gemini, TropicalZodiacSign.virgo}',
    'AstroBody.saturn: {TropicalZodiacSign.capricorn, TropicalZodiacSign.aquarius}',
    'TropicalZodiacSign.values[(sign.index + 6) % 12]',
]
for token in required_source:
    if token not in text:
        raise SystemExit(f'missing dignity contract token: {token}')

test_text = test.read_text(encoding='utf-8')
for token in ('Mercury in Virgo', 'outer planets and nodes', 'Mercury in Pisces'):
    if token not in test_text:
        raise SystemExit(f'missing dignity regression coverage: {token}')
if 'skip:' in test_text:
    raise SystemExit('critical dignity test may not be skipped')

manifest = json.loads(evidence.read_text(encoding='utf-8'))
if manifest.get('contract') != 'western_essential_dignities':
    raise SystemExit('wrong dignity contract id')
requirements = set(manifest.get('requirements', []))
if not {'RC-0049', 'RC-0050', 'RC-0276'} <= requirements:
    raise SystemExit('dignity evidence missing requirement coverage')
if manifest.get('status') != 'SOURCE_LEVEL_ONLY':
    raise SystemExit('dignity evidence may not claim more than source-level proof yet')

print('western essential-dignity structural contract: PASS')
