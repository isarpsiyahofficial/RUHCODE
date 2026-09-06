from pathlib import Path

required = {
    'RUH_CODE_MASTER_SARTNAME.md': ['118. Vedik yogalar profesyonel modülde değerlendirilebilecek.'],
    'lib/src/calculation_core/vedic/vedic_yoga_engine.dart': [
        'abstract final class VedicYogaEngine',
        'VedicYogaDefinition',
        'definitionSourceId',
        'Duplicate yoga definition id',
        'VedicYogaRelationType.houseDistance',
    ],
    'test/calculation_core/vedic/vedic_yoga_engine_test.dart': [
        'matches explicit same-house and house-distance rules',
        'rejects duplicate catalog ids and missing provenance',
    ],
    'requirements/contracts/rc0118_vedic_yoga_contract.json': ['RC-0118', 'versioned source-tagged'],
}

for path, needles in required.items():
    text = Path(path).read_text(encoding='utf-8')
    for needle in needles:
        if needle not in text:
            raise SystemExit(f'{path}: missing required RC-0118 evidence: {needle}')

print('RC-0118 binding validation: PASS')
