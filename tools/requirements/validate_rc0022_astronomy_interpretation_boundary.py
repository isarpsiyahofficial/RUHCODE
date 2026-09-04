#!/usr/bin/env python3
from __future__ import annotations
import csv, json, re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0022_astronomy_interpretation_boundary_contract.json'
IMPORT_RE = re.compile(r"^\s*import\s+['\"]([^'\"]+)['\"]", re.MULTILINE)


def require(ok: bool, message: str) -> None:
    if not ok:
        raise SystemExit(message)


def dart_files(rel_root: str):
    return sorted((ROOT / rel_root).rglob('*.dart'))


def main() -> None:
    contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
    require(contract['rcId'] == 'RC-0022', 'wrong RC-0022 contract binding')
    require(contract['promotionCeiling'] == 'TESTED', 'RC-0022 self-promotion ceiling weakened')

    rows = list(csv.DictReader((ROOT / 'requirements/requirement_state.csv').open(encoding='utf-8', newline='')))
    row = next((r for r in rows if r['rc_id'] == 'RC-0022'), None)
    require(row is not None, 'RC-0022 missing from requirement matrix')
    require(row['source_text_sha256'] == contract['bindingRequirementSha256'], 'RC-0022 binding SHA drift')

    calc_files = dart_files(contract['calculationRoot'])
    interp_files = dart_files(contract['interpretationRoot'])
    require(calc_files, 'calculation_core is empty')
    require(interp_files, 'interpretation root is empty')

    for path in calc_files:
        text = path.read_text(encoding='utf-8')
        for imp in IMPORT_RE.findall(text):
            require('interpretation/' not in imp and '/interpretation' not in imp,
                    f'calculation_core imports interpretation: {path.relative_to(ROOT)} -> {imp}')

    for path in interp_files:
        text = path.read_text(encoding='utf-8')
        for imp in IMPORT_RE.findall(text):
            require('calculation_core/' not in imp and '/calculation_core' not in imp,
                    f'interpretation imports calculation_core: {path.relative_to(ROOT)} -> {imp}')

    calc_engine = (ROOT / 'lib/src/calculation_core/calculation_engine.dart').read_text(encoding='utf-8')
    interp_engine = (ROOT / 'lib/src/interpretation/interpretation_engine.dart').read_text(encoding='utf-8')
    for marker in ('CalculationEngine<TInput, TResult>', 'CalculationResult<TResult>', 'required this.manifest', 'required this.value'):
        require(marker in calc_engine, f'RC-0022 calculation boundary marker missing: {marker}')
    for marker in ('InterpretationEngine<TSnapshot>', 'required TSnapshot snapshot', 'required String localeTag'):
        require(marker in interp_engine, f'RC-0022 interpretation boundary marker missing: {marker}')

    for forbidden in ('EphemerisProvider', 'De440sEphemerisProvider', 'SolarEvents.', 'JulianDay.'):
        require(forbidden not in interp_engine,
                f'interpretation boundary directly invokes astronomy runtime: {forbidden}')

    print(f'RC-0022 astronomy/interpretation boundary: OK ({len(calc_files)} calculation files, {len(interp_files)} interpretation files)')


if __name__ == '__main__':
    main()
