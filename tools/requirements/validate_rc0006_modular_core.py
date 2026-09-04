#!/usr/bin/env python3
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0006_modular_core_contract.json'
ENGINE = ROOT / 'lib/src/calculation_core/calculation_engine.dart'
INTERPRETATION = ROOT / 'lib/src/interpretation/interpretation_engine.dart'

errors = []
if not CONTRACT.is_file():
    errors.append('missing RC-0006 contract')
else:
    data = json.loads(CONTRACT.read_text(encoding='utf-8'))
    if data.get('rc_id') != 'RC-0006':
        errors.append('contract rc_id mismatch')
    arch = data.get('architecture_contract', {})
    required = arch.get('required_module_roots', [])
    if len(required) < 8:
        errors.append('insufficient modular subsystem coverage')
    for module in required:
        path = ROOT / 'lib/src/calculation_core' / module
        if not path.is_dir():
            errors.append(f'missing calculation module root: {module}')
    state = data.get('verification_state', {})
    if state.get('full_requirement_proven') is not False:
        errors.append('RC-0006 must remain fail-closed until AKILES provenance exists')
    if not state.get('blocker'):
        errors.append('missing provenance blocker text')

if not ENGINE.is_file():
    errors.append('missing CalculationEngine abstraction')
else:
    text = ENGINE.read_text(encoding='utf-8')
    for token in ('abstract interface class CalculationEngine', 'engineId', 'engineVersion', 'CalculationResult'):
        if token not in text:
            errors.append(f'calculation engine missing token: {token}')

if not INTERPRETATION.is_file():
    errors.append('missing separate InterpretationEngine abstraction')
else:
    text = INTERPRETATION.read_text(encoding='utf-8')
    if 'InterpretationEngine' not in text:
        errors.append('interpretation abstraction token missing')

pubspec = ROOT / 'pubspec.yaml'
if not pubspec.is_file():
    errors.append('missing pubspec.yaml')
else:
    lowered = pubspec.read_text(encoding='utf-8').lower()
    for forbidden in ('akiles:', 'akiles_git', 'package:akiles'):
        if forbidden in lowered:
            errors.append(f'forbidden direct AKILES dependency marker: {forbidden}')

if errors:
    print('RC-0006 modular-core contract FAILED')
    for error in errors:
        print(f'- {error}')
    sys.exit(1)

print('RC-0006 modular-core structural contract OK')
print('Ruh Code uses a separated calculation_core with a CalculationEngine abstraction and independent subsystem roots.')
print('Interpretation remains outside calculation_core.')
print('NOTE: TESTED structural architecture does not prove AKILES non-copy/method-transfer provenance; RC-0005 remains a hard VERIFIED/DONE blocker.')
