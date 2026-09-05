from pathlib import Path
import hashlib
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0076_rc0078_predictive_techniques_contract.json'
RUNTIME = ROOT / 'lib/src/calculation_core/western/predictive_techniques.dart'
TEST = ROOT / 'test/calculation_core/western/predictive_techniques_test.dart'
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'

EXPECTED = {
    'RC-0076': ('76', 'Secondary Progressions hesaplanacak.', '7f9388b6949ac6a30ec6e17806bb8905cc924af782b44c8660259f52171d1489'),
    'RC-0077': ('77', 'Solar Arc desteklenilecek.', '0d11ea9413b927bc584b00f26648d7aff093ed7186dda57eb2ff5617a5aa6d5c'),
    'RC-0078': ('78', 'Annual Profections desteklenilecek.', 'b21ac3a25df1b6b611f38a315083f75e40425d553d0cf36af6d20947e0e4ee47'),
}

for path in (CONTRACT, RUNTIME, TEST, SPEC):
    if not path.is_file():
        raise SystemExit(f'missing required RC-0076/0078 evidence: {path.relative_to(ROOT)}')

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
    'WesternSecondaryProgressions',
    'progressedJdTt = natalJdTt + ageYears',
    'ephemeris.coverage.requireContains',
    'WesternSolarArc',
    'progressedSun.longitudeDegrees - sun.longitudeDegrees',
    'Natal and ephemeris provenance must match for Solar Arc',
    'WesternAnnualProfections',
    'ageYears % 12',
    'activatedHouse: offset + 1',
    'Predictive-technique ephemeris body/instant/provenance mismatch',
]:
    if token not in runtime:
        raise SystemExit(f'RC-0076/0078 runtime invariant missing: {token}')
if 'DateTime.now' in runtime or 'http://' in runtime or 'https://' in runtime:
    raise SystemExit('predictive runtime must not depend on device current time/network')

compiled_test = TEST.read_text(encoding='utf-8')
for token in [
    'RC-0076 uses one ephemeris day per explicit year of age',
    'RC-0076 fails closed on duplicate body requests',
    'RC-0077 derives a single Solar Arc from the progressed Sun',
    'RC-0077 rejects natal and ephemeris provenance mismatch',
    'RC-0078 advances one house/sign per year and repeats every twelve',
    'RC-0078 rejects non-normalized Ascendant longitude',
    'predictive techniques reject mismatched returned ephemeris provenance',
]:
    if token not in compiled_test:
        raise SystemExit(f'RC-0076/0078 regression coverage missing: {token}')

print('RC-0076..RC-0078 predictive technique contracts: PASS')
