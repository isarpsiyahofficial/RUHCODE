from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0079_eclipse_overlay_contract.json'
RUNTIME = ROOT / 'lib/src/calculation_core/western/eclipse_overlay.dart'
TEST = ROOT / 'test/calculation_core/western/eclipse_overlay_test.dart'
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
TEXT = 'Eclipse overlay ve tutulma etkileri ilerleyen profesyonel modüllerde kullanılabilecek.'
EXPECTED_SHA = '59d0c54008788ac8ecf2dec2cc421d9bf7dd0ee195adcb10734c8f89ef48d806'

for path in (CONTRACT, RUNTIME, TEST, SPEC):
    if not path.is_file():
        raise SystemExit(f'missing required RC-0079 evidence: {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('requirements', {}).get('RC-0079') != TEXT:
    raise SystemExit('RC-0079 contract text mismatch')
if hashlib.sha256(TEXT.encode('utf-8')).hexdigest() != EXPECTED_SHA:
    raise SystemExit('RC-0079 requirement hash mismatch')
if f'79. {TEXT}' not in SPEC.read_text(encoding='utf-8'):
    raise SystemExit('RC-0079 binding specification text not found')

runtime = RUNTIME.read_text(encoding='utf-8')
for token in [
    'VerifiedEclipseEvent',
    'WesternEclipseOverlay',
    'EclipseContactKind.conjunction',
    'EclipseContactKind.opposition',
    'maximumOrbDegrees',
    'Eclipse and natal provenance must match',
    '_smallestSeparation',
]:
    if token not in runtime:
        raise SystemExit(f'RC-0079 runtime invariant missing: {token}')
if 'DateTime.now' in runtime or 'http://' in runtime or 'https://' in runtime:
    raise SystemExit('eclipse overlay runtime must not depend on device current time/network')

compiled_test = TEST.read_text(encoding='utf-8')
for token in [
    'RC-0079 computes deterministic eclipse conjunction/opposition overlay',
    'RC-0079 does not fabricate contacts outside configured orb',
    'RC-0079 fails closed on eclipse/natal provenance mismatch',
    'RC-0079 rejects invalid eclipse longitude and unsafe orb',
]:
    if token not in compiled_test:
        raise SystemExit(f'RC-0079 regression coverage missing: {token}')

print('RC-0079 eclipse overlay contract: PASS')
