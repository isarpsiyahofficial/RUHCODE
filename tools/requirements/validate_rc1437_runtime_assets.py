from pathlib import Path
import hashlib
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
MANIFEST = ROOT / 'requirements/reference_manifests/offline_ephemeris_runtime.json'
EOP_EVIDENCE = ROOT / 'requirements/evidence/rc1437_iers_eop_snapshot.json'
DE440_EVIDENCE = ROOT / 'requirements/evidence/rc1437_de440s_snapshot.json'
EOP_ASSET = ROOT / 'assets/data/eop/finals2000A.all'
DE440_ASSET = ROOT / 'assets/data/ephemeris/de440s.bsp'
EOP_LOADER = ROOT / 'lib/src/calculation_core/time/iers_finals2000a_asset_loader.dart'
DE440_LOADER = ROOT / 'lib/src/calculation_core/ephemeris/de440s_asset_loader.dart'
EOP_TEST = ROOT / 'test/calculation_core/iers_finals2000a_asset_loader_test.dart'
DE440_TEST = ROOT / 'test/calculation_core/de440s_asset_loader_test.dart'
PUBSPEC = ROOT / 'pubspec.yaml'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


def digest(path: Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as handle:
        for chunk in iter(lambda: handle.read(1024 * 1024), b''):
            h.update(chunk)
    return h.hexdigest()


def flutter_asset_declared(asset_path: str, pubspec_text: str) -> bool:
    """Accept Flutter's supported exact-file or containing-directory declaration.

    pubspec.yaml may declare an individual asset (`assets/data/eop/file`) or the
    directory containing it (`assets/data/eop/`). The latter is the canonical
    form used by this repository and packages files directly under that folder.
    Packaged-asset widget tests remain the runtime proof that the file is
    actually present in the Flutter asset bundle.
    """
    normalized = asset_path.replace('\\', '/')
    parent = f"{Path(normalized).parent.as_posix()}/"
    return normalized in pubspec_text or parent in pubspec_text


try:
    manifest = json.loads(read(MANIFEST))
    eop_evidence = json.loads(read(EOP_EVIDENCE))
    de440_evidence = json.loads(read(DE440_EVIDENCE))
    pubspec = read(PUBSPEC)
    eop_loader = read(EOP_LOADER)
    de440_loader = read(DE440_LOADER)
    eop_test = read(EOP_TEST)
    de440_test = read(DE440_TEST)

    assert EOP_ASSET.is_file(), 'physical IERS EOP asset missing'
    assert DE440_ASSET.is_file(), 'physical DE440s asset missing'

    eop_sha = digest(EOP_ASSET)
    de440_sha = digest(DE440_ASSET)
    assert eop_sha == eop_evidence['sha256'], 'physical IERS EOP SHA-256 differs from evidence'
    assert EOP_ASSET.stat().st_size == eop_evidence['byte_size'], 'physical IERS EOP byte-size differs from evidence'
    assert de440_sha == de440_evidence['sha256'], 'physical DE440s SHA-256 differs from evidence'
    assert DE440_ASSET.stat().st_size == de440_evidence['byte_size'], 'physical DE440s byte-size differs from evidence'

    with DE440_ASSET.open('rb') as handle:
        assert handle.read(7) == b'DAF/SPK', 'physical DE440s DAF/SPK magic mismatch'

    eop = manifest['earthOrientation']
    planetary = manifest['planetaryEphemeris']
    rules = manifest['runtimeRules']
    assert eop['bundled'] is True, 'IERS EOP manifest is not bundled'
    assert eop['sha256'] == eop_sha, 'IERS EOP manifest SHA-256 mismatch'
    assert eop['byteSize'] == EOP_ASSET.stat().st_size, 'IERS EOP manifest byte-size mismatch'
    assert eop['bundledPath'] == eop_evidence['path'], 'IERS EOP manifest path differs from evidence'
    assert planetary['bundled'] is True, 'DE440s manifest is not bundled'
    assert planetary['sha256'] == de440_sha, 'DE440s manifest SHA-256 mismatch'
    assert planetary['byteSize'] == DE440_ASSET.stat().st_size, 'DE440s manifest byte-size mismatch'
    assert planetary['bundledPath'] == de440_evidence['path'], 'DE440s manifest path differs from evidence'
    assert planetary['proven'] is False, 'DE440s computation was marked proven without independent golden-vector evidence'

    assert eop_evidence['runtime_network_required'] is False, 'IERS evidence permits network access'
    assert de440_evidence['runtime_network_required'] is False, 'DE440s evidence permits network access'
    assert de440_evidence['runtime_integration_proven'] is False, 'DE440s computation integration was marked proven without golden-vector evidence'
    assert de440_evidence['independent_golden_vectors_proven'] is False, 'DE440s golden vectors were marked proven without evidence'

    for path in (eop_evidence['path'], de440_evidence['path']):
        assert flutter_asset_declared(path, pubspec), (
            f'physical runtime asset is not declared in pubspec.yaml as a file or containing directory: {path}'
        )

    for token in (
        eop_evidence['path'],
        eop_evidence['sha256'],
        'rootBundle',
        'BundledEarthOrientationProvider',
        'substring(58, 68)',
    ):
        assert token in eop_loader, f'IERS runtime loader binding missing: {token}'
    for token in (
        de440_evidence['path'],
        de440_evidence['sha256'],
        str(de440_evidence['byte_size']),
        'rootBundle',
        'DAF/SPK',
    ):
        assert token in de440_loader, f'DE440s runtime loader binding missing: {token}'

    assert 'loadPackaged()' in eop_test, 'IERS packaged-asset runtime test missing'
    assert 'coverageStartUtc' in eop_test and 'coverageEndUtc' in eop_test, 'IERS fail-closed coverage test missing'
    assert 'loadPackaged()' in de440_test, 'DE440s packaged-asset runtime test missing'
    assert 'DAF/SPK' in de440_test, 'DE440s kernel-header runtime test missing'

    assert rules['networkFallback'] is False, 'network fallback enabled'
    assert rules['nearestDateFallback'] is False, 'nearest-date fallback enabled'
    assert rules['zeroStateFallback'] is False, 'zero-state fallback enabled'
    assert rules['corruptionFailsClosed'] is True, 'corruption fail-closed gate disabled'
    assert rules['outOfCoverageFailsClosed'] is True, 'out-of-coverage fail-closed gate disabled'
    assert rules['independentGoldenEvidenceRequired'] is True, 'independent golden evidence gate disabled'
    assert rules['cleanCheckoutReproducibilityRequired'] is True, 'clean-checkout reproducibility gate disabled'

except (AssertionError, KeyError, OSError, ValueError, json.JSONDecodeError) as exc:
    print(f'RC-1437 runtime asset gate FAILED: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('RC-1437 runtime asset gate OK: physical IERS and DE440s assets, hashes, Flutter packaging, offline loaders and packaged-asset tests are bound; DE440s computation/golden-vector proof remains intentionally open')
