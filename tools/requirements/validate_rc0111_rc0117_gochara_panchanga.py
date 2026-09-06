#!/usr/bin/env python3
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
contract = json.loads((ROOT / 'requirements/contracts/rc0111_rc0117_gochara_panchanga_contract.json').read_text(encoding='utf-8'))
master = (ROOT / 'RUH_CODE_MASTER_SARTNAME.md').read_text(encoding='utf-8')
gochara = (ROOT / 'lib/src/calculation_core/vedic/vedic_gochara.dart').read_text(encoding='utf-8')
panchanga = (ROOT / 'lib/src/calculation_core/vedic/vedic_panchanga.dart').read_text(encoding='utf-8')
tests = (ROOT / 'test/calculation_core/vedic/vedic_gochara_panchanga_test.dart').read_text(encoding='utf-8')

expected = ['RC-0111', 'RC-0113', 'RC-0115', 'RC-0116', 'RC-0117']
assert contract['requirements'] == expected
for n in (111, 113, 115, 116, 117):
    assert f'{n}.' in master, f'missing master requirement {n}'

for token in [
    'VedicCalculationEngine.calculate', 'canonicalGocharaBodies',
    'EphemerisProvider', 'VedicAyanamshaProvider'
]:
    assert token in gochara, f'missing Gochara binding: {token}'

for token in [
    'tithiSpanDegrees = 12.0', 'nakshatraSpanDegrees = 360.0 / 27.0',
    '_normalize360(sun + moon)', 'karanaSpanDegrees = 6.0',
    'VedicKarana.kimstughna', 'VedicKarana.shakuni',
    'VedicKarana.chatushpada', 'VedicKarana.naga',
    "Vara (RC-0114) is deliberately not synthesized"
]:
    assert token in panchanga, f'missing Panchanga binding: {token}'

for token in [
    "group('RC-0111 Gochara'", 'computes Tithi, daily Nakshatra, Yoga and Karana',
    'maps fixed and repeating Karanas', 'fails closed without Sun and Moon completeness'
]:
    assert token in tests, f'missing regression evidence: {token}'

assert 'RC-0114' in contract['deliberate_exclusion']
print('RC-0111/0113/0115/0116/0117 binding validation: PASS')
