#!/usr/bin/env python3
from __future__ import annotations
import csv, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
CONTRACT=ROOT/'requirements/contracts/rc0015_lunar_nodes_contract.json'

def require(ok: bool, message: str) -> None:
    if not ok:
        raise SystemExit(message)

def main() -> None:
    contract=json.loads(CONTRACT.read_text(encoding='utf-8'))
    require(contract['rcId']=='RC-0015','wrong RC-0015 contract binding')
    require(contract['promotionCeiling']=='TESTED','RC-0015 self-promotion ceiling weakened')

    rows=list(csv.DictReader((ROOT/'requirements/requirement_state.csv').open(encoding='utf-8',newline='')))
    row=next((r for r in rows if r['rc_id']=='RC-0015'),None)
    require(row is not None,'RC-0015 missing from requirement matrix')
    require(row['source_text_sha256']==contract['bindingRequirementSha256'],'RC-0015 binding SHA drift')

    for rel in contract['requiredRuntimeComponents']+contract['requiredCompiledTests']:
        path=ROOT/rel
        require(path.is_file() and path.stat().st_size>0,f'missing RC-0015 evidence: {rel}')

    calc=(ROOT/'lib/src/calculation_core/ephemeris/lunar_node_calculator.dart').read_text(encoding='utf-8')
    provider=(ROOT/'lib/src/calculation_core/ephemeris/de440s_ephemeris_provider.dart').read_text(encoding='utf-8')
    tests=(ROOT/'test/calculation_core/lunar_node_calculator_test.dart').read_text(encoding='utf-8')

    for needle in (
        'meanAscendingNodeDegrees',
        'trueAscendingNodeDegrees',
        'descendingNodeDegrees',
        '125.0445479',
        '1934.1362891',
        '-1.4979',
        '-0.1500',
        '-0.1226',
        '+\n        0.1176',
        '-\n        0.0801',
        '_requireFiniteJd',
    ):
        require(needle in calc,f'RC-0015 lunar node algorithm marker missing: {needle}')

    require('DateTime.now()' not in calc,'RC-0015 lunar nodes must not depend on device clock')
    require('Lunar nodes are calculated by the dedicated node engine.' in provider,
            'RC-0015 physical DE440s provider must keep nodes out of SPK-body mapping')
    require('AstroBody.meanNode' not in provider and 'AstroBody.trueNode' not in provider,
            'RC-0015 nodes must not be mapped to fake physical SPK targets')
    require('2451545.0' in tests and '123.9261713684' in tests,
            'RC-0015 compiled J2000 mean/true node regression missing')
    require('throwsArgumentError' in tests,'RC-0015 non-finite fail-closed regression missing')

    print('RC-0015 lunar node contract: OK')

if __name__=='__main__':
    main()
