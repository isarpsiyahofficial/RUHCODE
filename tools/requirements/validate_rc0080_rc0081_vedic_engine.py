from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0080_rc0081_vedic_engine_contract.json'
RUNTIME = ROOT / 'lib/src/calculation_core/vedic/vedic_engine.dart'
TEST = ROOT / 'test/calculation_core/vedic/vedic_engine_test.dart'
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'

EXPECTED = {
    'RC-0080': ('80', 'Vedik astroloji Batı astrolojisinin üzerine sidereal fark uygulanmış basit bir kopya olmayacak.', '10a1be0d7bc0ae89eddf837706786cc36df1a0cefcf768a72d606a8e2cea52e9'),
    'RC-0081': ('81', 'Vedik hesaplama motoru ayrı çalışacak.', '97ada152e46dbc49efa1d435f0a7ae31710a51f50c867b647e0e371ae987f011'),
}

for path in (CONTRACT, RUNTIME, TEST, SPEC):
    if not path.is_file():
        raise SystemExit(f'missing required RC-0080/0081 evidence: {path.relative_to(ROOT)}')

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
    "import '../ephemeris/ephemeris.dart';",
    'abstract interface class VedicAyanamshaProvider',
    'abstract final class VedicCalculationEngine',
    'final class VedicCalculationSnapshot',
    'ephemeris.stateAt',
    'siderealLongitudeDegrees',
    'ephemerisSourceId',
    'ayanamshaDataVersion',
    'Vedic ephemeris body/instant/provenance mismatch',
]:
    if token not in runtime:
        raise SystemExit(f'RC-0080/0081 runtime invariant missing: {token}')

for forbidden in [
    '/western/',
    "../western/",
    'WesternNatal',
    'WesternTransit',
    'WesternCalculation',
    'DateTime.now',
    'http://',
    'https://',
]:
    if forbidden in runtime:
        raise SystemExit(f'Vedic engine forbidden dependency/fallback found: {forbidden}')

compiled_test = TEST.read_text(encoding='utf-8')
for token in [
    'RC-0080/0081 Vedic engine derives its own sidereal snapshot from astronomy',
    'Vedic engine rejects duplicate bodies',
    'Vedic engine fails closed on ephemeris provenance mismatch',
    'Vedic engine fails closed on invalid ayanamsha provenance/value',
]:
    if token not in compiled_test:
        raise SystemExit(f'RC-0080/0081 regression coverage missing: {token}')

print('RC-0080..RC-0081 independent Vedic engine contract: PASS')
