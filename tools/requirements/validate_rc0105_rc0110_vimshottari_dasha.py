#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
PROD = ROOT / 'lib/src/calculation_core/vedic/vimshottari_dasha.dart'
NAK = ROOT / 'lib/src/calculation_core/vedic/vedic_nakshatra.dart'
TEST = ROOT / 'test/calculation_core/vedic/vimshottari_dasha_test.dart'
CONTRACT = ROOT / 'requirements/contracts/rc0105_rc0110_vimshottari_dasha_contract.json'

required = {
    SPEC: [
        '105. Vimshottari Dasha hesaplanacak.',
        '106. Mahadasha gösterilecek.',
        '107. Antardasha gösterilecek.',
        '108. Pratyantardasha gerektiğinde desteklenilecek.',
        '109. Kullanıcının şu anda hangi Dasha döneminde olduğu gösterilecek.',
        '110. Dasha başlangıç ve bitiş tarihleri açıkça gösterilecek.',
    ],
    PROD: [
        'canonicalVimshottariOrder',
        'VimshottariLord.ketu: 7',
        'VimshottariLord.venus: 20',
        'VimshottariLord.rahu: 18',
        'VimshottariLord.mercury: 17',
        'static const double cycleYears = 120;',
        'static const double daysPerDashaYear = 365.25;',
        'static VimshottariTimeline fromNakshatra(',
        'static List<VimshottariPeriod> antardashas(',
        'static List<VimshottariPeriod> pratyantardashas(',
        'static List<VimshottariPeriod> currentPeriods(',
        'bool contains(double jdTt) => jdTt >= startJdTt && jdTt < endJdTt;',
        'VedicNakshatra.nakshatraSpanDegrees',
    ],
    NAK: ['final class VedicNakshatraPosition', 'degreesIntoNakshatra'],
    TEST: [
        'RC-0105 canonical Vimshottari lords sum to 120 years',
        'RC-0105 birth Nakshatra selects starting Mahadasha lord',
        'RC-0106 Mahadasha balance reflects elapsed birth Nakshatra fraction',
        'RC-0107 Antardashas partition the Mahadasha exactly',
        'RC-0108 Pratyantardashas recursively partition Antardasha',
        'RC-0109 current period resolves exactly one period per requested level',
        'RC-0110 ranges are half-open and expose exact start/end TT',
        'RC-0105-RC-0110 fail closed for invalid provenance and query TT',
    ],
}

for path, needles in required.items():
    if not path.exists():
        raise SystemExit(f'missing required file: {path.relative_to(ROOT)}')
    text = path.read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            raise SystemExit(f'missing binding evidence in {path.relative_to(ROOT)}: {needle}')

contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
ids = [f'RC-{i:04d}' for i in range(105, 111)]
if contract.get('requirements') != ids:
    raise SystemExit('contract requirement IDs are not exact')
if set(contract.get('claims', {})) != set(ids):
    raise SystemExit('contract claims are incomplete')
if contract.get('conventions', {}).get('dasha_year_days') != 365.25:
    raise SystemExit('Dasha-year convention must remain explicit and versioned in evidence')

print('RC-0105/RC-0110 Vimshottari Dasha binding validation: PASS')
