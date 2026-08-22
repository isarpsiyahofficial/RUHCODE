#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/pdf/persisted_western_pdf_service.json'
SOURCE = ROOT / 'lib/src/pdf/persisted_western_natal_pdf_service.dart'

errors = []

if not EVIDENCE.is_file():
    errors.append('missing persisted Western PDF evidence')
else:
    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if data.get('status') != 'SOURCE_LEVEL_IMPLEMENTED':
        errors.append('unexpected evidence status')
    if data.get('done') is not False:
        errors.append('evidence must remain done=false until production render proof exists')
    required_rcs = {'RC-0916', 'RC-0920', 'RC-0921', 'RC-0922', 'RC-0923', 'RC-0964'}
    if set(data.get('requirements', [])) != required_rcs:
        errors.append('persisted Western PDF requirement ownership drift')
    for relative in data.get('source_files', []):
        if not (ROOT / relative).is_file():
            errors.append(f'missing evidence source file: {relative}')

if not SOURCE.is_file():
    errors.append('missing persisted_western_natal_pdf_service.dart')
else:
    text = SOURCE.read_text(encoding='utf-8')
    tokens = [
        'PersistedWesternNatalPdfReader.read(snapshot)',
        'PersistedWesternNatalSectionAdapter.build(',
        'PersistedManifestSectionAdapter.build(',
        'PdfSectionIds.placements',
        'PdfSectionIds.houses',
        'PdfSectionIds.aspects',
        'PdfSectionIds.technicalManifest',
        "locale != 'tr' && locale != 'en'",
        'Western PDF persisted record identity drift detected.',
    ]
    for token in tokens:
        if token not in text:
            errors.append(f'missing source invariant token: {token}')
    forbidden = [
        'EphemerisProvider',
        'WesternNatalChartAssembler',
        'PlacidusHouseEngine',
        'PorphyryHouseEngine',
    ]
    for token in forbidden:
        if token in text:
            errors.append(f'PDF service must not recalculate historical astronomy: {token}')

if errors:
    for error in errors:
        print(f'ERROR: {error}')
    raise SystemExit(1)

print('persisted Western PDF service contract: OK')
