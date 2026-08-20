#!/usr/bin/env python3
from pathlib import Path
import csv
import json

ROOT = Path(__file__).resolve().parents[2]
SOURCE = ROOT / 'lib/src/pdf/pdf_western_chart_geometry.dart'
TEST = ROOT / 'test/pdf/pdf_western_chart_geometry_test.dart'
EVIDENCE = ROOT / 'evidence/pdf/western_chart_geometry_contract.json'
GEOMETRY_MANIFEST = ROOT / 'ui/dynamic_geometry_manifest.csv'

errors = []

required_source = [
    'final class PdfWesternChartGeometry',
    'abstract final class PdfWesternChartGeometryAdapter',
    'WesternNatalChart chart',
    'static const double houseRadius = 1.0',
    'static const double planetRadius = 0.82',
    'static const double aspectRadius = 0.58',
    "throw const FormatException('Western PDF geometry cannot mix calculation snapshots.')",
    'chart.houses.cusp(index + 1)',
    'placement.longitudeDegrees',
    'for (final hit in chart.aspects.aspects)',
    'final angle = math.pi - (relative * math.pi / 180.0)',
]
required_tests = [
    'ASC is anchored at 9 o clock and increasing longitude is counter-clockwise',
    'geometry is derived from exact house, placement and aspect sets',
    'expect(geometry.houseRays, hasLength(12))',
    'expect(sunMoon.aspect, MajorAspect.square)',
]

for path, tokens in ((SOURCE, required_source), (TEST, required_tests)):
    if not path.exists():
        errors.append(f'missing {path.relative_to(ROOT)}')
        continue
    text = path.read_text(encoding='utf-8')
    for token in tokens:
        if token not in text:
            errors.append(f'{path.relative_to(ROOT)} missing token: {token}')

if not EVIDENCE.exists():
    errors.append('missing Western PDF geometry evidence')
else:
    evidence = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if evidence.get('contract') != 'pdf-western-chart-geometry-v1':
        errors.append('unexpected Western PDF geometry evidence id')
    if evidence.get('done') is not False:
        errors.append('Western PDF geometry must remain done=false until painter/golden proof exists')
    if evidence.get('sharedCalculationRequired') is not True:
        errors.append('Western PDF geometry must require shared calculation snapshot')
    coordinate = evidence.get('coordinateContract', {})
    if coordinate.get('ascendantAnchor') != '9_o_clock' or coordinate.get('zodiacDirection') != 'counter_clockwise':
        errors.append('Western PDF geometry coordinate convention is not pinned')

if not GEOMETRY_MANIFEST.exists():
    errors.append('missing ui/dynamic_geometry_manifest.csv')
else:
    rows = list(csv.DictReader(GEOMETRY_MANIFEST.open(encoding='utf-8', newline='')))
    matching = [row for row in rows if row.get('geometry_id') == 'GEOM-PDF-WESTERN-WHEEL']
    if len(matching) != 1:
        errors.append('GEOM-PDF-WESTERN-WHEEL must appear exactly once')
    else:
        row = matching[0]
        if row.get('renderer_contract') != 'SHARED_CALCULATION_VECTOR':
            errors.append('Western PDF wheel must remain SHARED_CALCULATION_VECTOR')
        if row.get('golden_required', '').lower() != 'true':
            errors.append('Western PDF wheel must require golden visual proof')
        if row.get('status') != 'IMPLEMENTED':
            errors.append('Western PDF wheel source geometry status must be IMPLEMENTED')

if errors:
    raise SystemExit('\n'.join(f'ERROR: {error}' for error in errors))

print('Western PDF vector geometry contract OK (source-level; painter/golden still pending).')
