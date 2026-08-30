from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
source = ROOT / 'lib/src/calculation_core/western/aspect_grid.dart'
test = ROOT / 'test/calculation_core/western/aspect_grid_test.dart'
evidence = ROOT / 'evidence/astronomy/western_aspect_grid.json'

for path in (source, test, evidence):
    if not path.exists():
        raise SystemExit(f'missing required file: {path.relative_to(ROOT)}')

text = source.read_text(encoding='utf-8')
required_source = [
    'final class NatalAspectGrid',
    'AspectGridCell cell(',
    "throw StateError('Aspect grid inputs must share exact provenance.')",
    "throw StateError('Multiple major aspects found for the same body pair.')",
    'rowBody == columnBody',
]
for token in required_source:
    if token not in text:
        raise SystemExit(f'missing aspect-grid contract token: {token}')

test_text = test.read_text(encoding='utf-8')
for token in ('symmetric square grid', 'provenance mismatch', 'duplicate aspect entries'):
    if token not in test_text:
        raise SystemExit(f'missing aspect-grid regression coverage: {token}')

manifest = json.loads(evidence.read_text(encoding='utf-8'))
if manifest.get('contract') != 'western_aspect_grid':
    raise SystemExit('wrong aspect-grid contract id')
if manifest.get('status') != 'SOURCE_LEVEL_ONLY':
    raise SystemExit('aspect-grid evidence must remain source-level until upstream accuracy is proven')
requirements = set(manifest.get('requirements', []))
if 'RC-0051' not in requirements:
    raise SystemExit('aspect-grid evidence missing RC-0051 requirement coverage')

print('western aspect-grid structural contract: PASS')
