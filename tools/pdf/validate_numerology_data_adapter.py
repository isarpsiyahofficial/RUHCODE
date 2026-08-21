#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'lib/src/pdf/pdf_numerology_data.dart'
TEST = ROOT / 'test/pdf/pdf_numerology_data_test.dart'
EVIDENCE = ROOT / 'evidence/pdf/numerology_data_adapter.json'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    for path in (SOURCE, TEST, EVIDENCE):
        require(path.exists(), f'Missing numerology PDF contract file: {path}')

    source = SOURCE.read_text(encoding='utf-8')
    test = TEST.read_text(encoding='utf-8')
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))

    for token in [
        'PythagoreanNumerologySnapshot',
        'PythagoreanSnapshotFingerprint.sha256Hex',
        'PdfSnapshotIdentity(',
        'PdfSectionIds.numerology',
        'PdfReportDataValidator().validateAndProject',
    ]:
        require(token in source, f'Numerology PDF source missing token: {token}')

    for token in [
        'without recalculation drift',
        'exact canonical snapshot SHA-256 identity',
        'target-date changes produce a different PDF snapshot identity',
        'demo/user subject boundaries remain strict',
        'requireUiPdfSnapshotParity',
    ]:
        require(token in test, f'Numerology PDF test missing contract case: {token}')

    require(evidence.get('done') is False, 'Numerology PDF evidence cannot claim DONE')
    require(len(evidence.get('invariants', [])) >= 5, 'Numerology PDF evidence needs explicit invariants')
    require(len(evidence.get('notProvenYet', [])) >= 3, 'Numerology PDF evidence must retain production blockers')

    print('Numerology PDF data adapter contract: OK')


if __name__ == '__main__':
    main()
