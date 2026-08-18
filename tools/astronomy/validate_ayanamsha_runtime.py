from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CORE = ROOT / 'lib/src/calculation_core/vedic/ayanamsha.dart'
VEDIC = ROOT / 'lib/src/calculation_core/vedic/vedic_daily_indicators.dart'
TEST = ROOT / 'test/calculation_core/ayanamsha_test.dart'
VEDIC_TEST = ROOT / 'test/calculation_core/vedic_daily_indicators_test.dart'
MANIFEST = ROOT / 'requirements/reference_manifests/ayanamsha_runtime.json'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    core = read(CORE)
    vedic = read(VEDIC)
    test = read(TEST)
    vedic_test = read(VEDIC_TEST)
    manifest = json.loads(read(MANIFEST))

    for token in (
        'AyanamshaProvider',
        'TabulatedAyanamshaProvider',
        'dataSha256',
        'coverageStartJulianDayTt',
        'coverageEndJulianDayTt',
        'Ayanamsha extrapolation is forbidden',
        'strictly increasing TT Julian days',
    ):
        assert token in core, f'missing ayanamsha runtime token: {token}'

    assert 'calculateWithProvider' in vedic
    assert 'ayanamshaProvider.atJulianDayTt' in vedic

    for token in (
        'exact sample preserves provenance',
        'interpolation is deterministic inside coverage',
        'coverage extrapolation is forbidden',
        'samples must be strictly increasing',
        'checksum cannot be omitted or malformed',
    ):
        assert token in test, f'missing ayanamsha test: {token}'

    assert 'provider path binds TT instant and ayanamsha provenance' in vedic_test
    assert 'provider path refuses ayanamsha extrapolation' in vedic_test

    assert manifest['required_mode'] == 'Lahiri/Chitrapaksha'
    assert manifest['runtime_network_required'] is False
    assert manifest['proven'] is False
    provider = manifest['provider_contract']
    assert provider['time_scale'] == 'TT Julian Day'
    assert provider['source_id_required'] is True
    assert provider['source_version_required'] is True
    assert provider['data_sha256_required'] is True
    assert provider['strictly_increasing_samples_required'] is True
    assert provider['coverage_extrapolation_allowed'] is False
except (AssertionError, KeyError, json.JSONDecodeError) as exc:
    print(f'ayanamsha runtime contract FAILED: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('ayanamsha runtime contract OK: strict TT/provider/provenance/checksum/coverage rules are present; production evidence remains unproven')
