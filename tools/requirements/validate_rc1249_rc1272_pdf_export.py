from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1249_rc1272_pdf_export_contract.json'
POLICY = ROOT / 'lib/src/pdf/pdf_export_governance.dart'
TEST = ROOT / 'test/pdf/pdf_export_governance_rc1249_rc1272_test.dart'
CONCURRENCY_TEST = ROOT / 'test/pdf/pdf_export_concurrency_rc1262_test.dart'
FIXTURE_TEST = ROOT / 'test/pdf/pdf_release_fixture_rc1272_test.dart'
FIXTURE = ROOT / 'test/fixtures/pdf/rc1272_free_sample_fixture.json'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    contract = json.loads(read(CONTRACT))
    policy = read(POLICY)
    regression = read(TEST)
    concurrency = read(CONCURRENCY_TEST)
    fixture_test = read(FIXTURE_TEST)
    fixture = json.loads(read(FIXTURE))

    expected = [f'RC-{i:04d}' for i in range(1249, 1273)]
    assert list(contract['requirements'].keys()) == expected, 'contract RC range/order mismatch'
    assert contract['release_blockers'], 'release blockers must remain explicit'

    for token in (
        'PdfExportAudience.freeDemo',
        'PdfExportAudience.professionalClient',
        'Free sample PDF must be visibly watermarked as demo.',
        'Real-client PDF export requires PRO entitlement.',
        'Demo PDF must not carry a real client id.',
        'PdfExportCancellationToken',
        'PdfExportRunState.cancelled',
        'PdfExportRunState.completed',
        'maximumConcurrentJobs',
        "'client:${request.clientId}'",
        'publishAtomically',
        'deleteIfExists',
        'PdfExportCollisionPolicy',
        'PDF $label path escapes the app sandbox.',
        'shareCacheRoot',
        'PdfAppLifecycleMode',
        'contentOrder.toSet()',
    ):
        assert token in policy, f'missing RC1249-RC1272 production token: {token}'

    for token in (
        'Free sample is allowed only with isolated demo data and watermark',
        'real client export requires PRO but full report may disable watermark',
        'cancelled export cleans temp and is never successful',
        'failed export cleans partial file and never publishes success',
        'successful export publishes atomically and removes temp',
        'sandbox escape is fail-closed',
        'same-client jobs are serialized and global concurrency is bounded',
        'filename collisions resolve deterministically',
        'content order is explicit, unique and stable',
    ):
        assert token in regression, f'missing RC1249-RC1272 regression token: {token}'

    for token in ('maximumConcurrentJobs: 2', 'expect(maxActive, 2)'):
        assert token in concurrency, f'missing RC1262 concurrency proof token: {token}'

    assert fixture['fixtureVersion'] == 1
    assert fixture['usesDemoData'] is True
    assert fixture['clientId'] is None
    assert fixture['watermark'] == 'DEMO / SAMPLE'
    assert fixture['sections'], 'sample PDF fixture requires deterministic sections'
    for token in ('pw.Document()', 'document.save()', "'%PDF'"):
        assert token in fixture_test, f'missing RC1272 real PDF fixture token: {token}'

except (AssertionError, KeyError, TypeError, ValueError, OSError, json.JSONDecodeError) as exc:
    print(f'RC1249_RC1272_FAIL: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('RC1249_RC1272_OK')
