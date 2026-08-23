from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/pdf/persisted_combined_projection.json'
SOURCE = ROOT / 'lib/src/pdf/persisted_combined_pdf_projection.dart'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    source = SOURCE.read_text(encoding='utf-8')
    master = MASTER.read_text(encoding='utf-8')

    require(evidence.get('requirements') == ['RC-0903', 'RC-0904'],
            'Persisted combined evidence must own exactly RC-0903 and RC-0904.')
    require(evidence.get('done') is False,
            'Persisted combined evidence cannot be DONE before runtime/CI/font proof.')

    require(re.search(r'^903\.\s+Kombine danışmanlık raporu birden fazla sistemi kapsayabilecek\.$', master, re.M) is not None,
            'MASTER RC-0903 semantic text drifted.')
    require(re.search(r'^904\.\s+Sistemler kombine raporda bile birbirinden açık başlıklarla ayrılacak\.$', master, re.M) is not None,
            'MASTER RC-0904 semantic text drifted.')

    required_tokens = [
        'PersistedCombinedPdfProjectionSource',
        'PersistedWesternCombinedMemberProjector',
        'PersistedPythagoreanCombinedMemberProjector',
        'PdfCombinedReportBuilder',
        'same subject',
        "'Batı Astrolojisi'",
        "'Western Astrology'",
        "'Numeroloji'",
        "'Numerology'",
        'snapshotSha256',
    ]
    for token in required_tokens:
        require(token in source, f'Missing persisted combined contract token: {token}')

    for rel in evidence.get('sources', []) + evidence.get('tests', []) + evidence.get('validators', []):
        path = ROOT / rel
        require(path.is_file(), f'Evidence path missing: {rel}')

    print('Persisted combined PDF projection contract: OK')


if __name__ == '__main__':
    main()
