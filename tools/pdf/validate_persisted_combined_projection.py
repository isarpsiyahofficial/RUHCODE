from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/pdf/persisted_combined_projection.json'
PROJECTION = ROOT / 'lib/src/pdf/persisted_combined_pdf_projection.dart'
APPLICATION = ROOT / 'lib/src/pdf/combined_professional_pdf_application_service.dart'
WESTERN_PERSISTENCE = ROOT / 'lib/src/pdf/western_natal_persistence_service.dart'
WESTERN_READER = ROOT / 'lib/src/pdf/persisted_western_natal_pdf.dart'
MASTER = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'


def require(condition: bool, message: str) -> None:
    if not condition:
        raise SystemExit(message)


def main() -> None:
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    projection = PROJECTION.read_text(encoding='utf-8')
    application = APPLICATION.read_text(encoding='utf-8')
    western_persistence = WESTERN_PERSISTENCE.read_text(encoding='utf-8')
    western_reader = WESTERN_READER.read_text(encoding='utf-8')
    master = MASTER.read_text(encoding='utf-8')

    require(evidence.get('requirements') == ['RC-0903', 'RC-0904'],
            'Persisted combined evidence must own exactly RC-0903 and RC-0904.')
    require('RC-0905' not in evidence.get('requirements', []),
            'RC-0905 must remain open until Vedic/Western cross-system rendering is proven.')
    require(evidence.get('done') is False,
            'Persisted combined evidence cannot be DONE before runtime/CI/font proof.')

    require(re.search(r'^903\.\s+Kombine danışmanlık raporu birden fazla sistemi kapsayabilecek\.$', master, re.M) is not None,
            'MASTER RC-0903 semantic text drifted.')
    require(re.search(r'^904\.\s+Sistemler kombine raporda bile birbirinden açık başlıklarla ayrılacak\.$', master, re.M) is not None,
            'MASTER RC-0904 semantic text drifted.')
    require(re.search(r'^905\.\s+Batı sonucu Vedik sonuç gibi gösterilmeyecek\.$', master, re.M) is not None,
            'MASTER RC-0905 semantic text drifted.')

    projection_tokens = [
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
        'subjectKind: parsed.subjectKind',
    ]
    for token in projection_tokens:
        require(token in projection, f'Missing persisted combined projection token: {token}')

    application_tokens = [
        'CombinedProfessionalPdfApplicationService',
        'RuhFeatureIds.pdfProfessionalExport',
        'listCandidates',
        'preview',
        'buildFromPreview',
        'compositeSnapshotDigest',
        'memberSystemIds',
        'preview/build persisted snapshot drift detected',
        'preview/build system drift detected',
        'preview/build section drift detected',
        'subjectKind',
        'subjectId',
    ]
    for token in application_tokens:
        require(token in application, f'Missing combined PDF application token: {token}')

    persistence_tokens = [
        "String subjectKind = 'profile'",
        "'subjectKind': normalizedSubjectKind",
        "normalized != 'profile' && normalized != 'client'",
    ]
    for token in persistence_tokens:
        require(token in western_persistence,
                f'Missing Western subject-kind persistence token: {token}')

    reader_tokens = [
        'final PdfSubjectKind subjectKind',
        "if (raw == null) return PdfSubjectKind.profile",
        "if (raw == 'profile') return PdfSubjectKind.profile",
        "if (raw == 'client') return PdfSubjectKind.client",
    ]
    for token in reader_tokens:
        require(token in western_reader,
                f'Missing Western subject-kind reader token: {token}')

    for rel in evidence.get('sources', []) + evidence.get('tests', []) + evidence.get('validators', []):
        path = ROOT / rel
        require(path.is_file(), f'Evidence path missing: {rel}')

    print('Persisted combined PDF projection/application contract: OK')


if __name__ == '__main__':
    main()
