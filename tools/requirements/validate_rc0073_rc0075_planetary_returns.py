from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0073_rc0075_planetary_returns_contract.json'
RUNTIME = ROOT / 'lib/src/calculation_core/western/planetary_return.dart'
TEST = ROOT / 'test/calculation_core/western/planetary_return_test.dart'
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'

EXPECTED = {
    'RC-0073': ('73', 'Solar Return hesaplanacak.', 'da4c14384d6f2ee8f44cf2e255b848026b7e2af6a2a5aa876c97464353cb4f14'),
    'RC-0074': ('74', 'Lunar Return hesaplanacak.', 'aac0e85c48ae186e3e225e074796757308de71c228f7b331b4f0e2ad8a5ab3c8'),
    'RC-0075': ('75', 'Planetary Return sistemleri desteklenebilecek.', 'e4dd0f71d35e6e47e858ec6cf5d99882c710f529e7115c9c3fed6e03d17f0568'),
}

for path in (CONTRACT, RUNTIME, TEST, SPEC):
    if not path.is_file():
        raise SystemExit(f'missing required RC-0073/0075 evidence: {path.relative_to(ROOT)}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
spec = SPEC.read_text(encoding='utf-8')
for rc_id, (number, text, expected_sha) in EXPECTED.items():
    if contract.get('requirements', {}).get(rc_id) != text:
        raise SystemExit(f'{rc_id} contract text mismatch')
    if hashlib.sha256(text.encode('utf-8')).hexdigest() != expected_sha:
        raise SystemExit(f'{rc_id} requirement hash mismatch')
    if f'{number}. {text}' not in spec:
        raise SystemExit(f'{rc_id} binding specification text not found')

runtime = RUNTIME.read_text(encoding='utf-8')
for token in [
    'WesternPlanetaryReturnSolver',
    'findFirst',
    'findSolarReturn',
    'findLunarReturn',
    'AstroBody.sun',
    'AstroBody.moon',
    '_signedAngularError',
    'branch cut',
    'ephemeris.coverage.requireContains',
    'body/instant/provenance mismatch',
    'No planetary longitude return exists',
]:
    if token not in runtime:
        raise SystemExit(f'RC-0073/0075 runtime invariant missing: {token}')
if 'DateTime.now' in runtime or 'http://' in runtime or 'https://' in runtime:
    raise SystemExit('return runtime must not depend on device current time/network')

compiled_test = TEST.read_text(encoding='utf-8')
for token in [
    'RC-0073 finds Solar Return across the 360-degree wrap',
    'RC-0074 finds Lunar Return from the same exact-TT solver',
    'RC-0075 supports a non-luminary planetary return',
    'does not mistake the plus/minus 180 branch cut for a return',
    'fails closed when ephemeris provenance does not match coverage',
    'fails closed when no return exists in the supplied window',
]:
    if token not in compiled_test:
        raise SystemExit(f'RC-0073/0075 regression coverage missing: {token}')

print('RC-0073..RC-0075 planetary return contracts: PASS')
