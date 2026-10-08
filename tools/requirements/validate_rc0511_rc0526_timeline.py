import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0511_rc0526_timeline_contract.json'
SOURCE = ROOT / 'lib/src/professional/timeline_workspace.dart'
TEST = ROOT / 'test/professional/timeline_workspace_rc0511_rc0526_test.dart'
WORKFLOW = ROOT / '.github/workflows/rc0511-rc0526-professional-timeline.yml'
for path in [SPEC, CONTRACT, SOURCE, TEST, WORKFLOW]:
    if not path.is_file():
        raise SystemExit(f'RC0511_RC0526_FAIL: missing {path.relative_to(ROOT)}')
spec = SPEC.read_text(encoding='utf-8')
for number in range(511, 527):
    if not re.search(rf'(?m)^{number}\.\s+\S', spec):
        raise SystemExit(f'RC0511_RC0526_FAIL: binding {number}. missing')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('required_numbered_entries') != list(range(511, 527)):
    raise SystemExit('RC0511_RC0526_FAIL: contract sequence mismatch')
if contract.get('promotion_ceiling') != 'IMPLEMENTED':
    raise SystemExit('RC0511_RC0526_FAIL: unsafe promotion ceiling')
source = SOURCE.read_text(encoding='utf-8')
for token in [
    'ProfessionalTimeline', 'TimelineWindow.next30Days', 'TimelineWindow.next3Months', 'TimelineWindow.next1Year',
    'highImportanceOnly',
    'TimelineLanguagePolicy', 'TimelineFilterPreset', 'TimelinePresetLibrary'
]:
    if token not in source:
        raise SystemExit(f'RC0511_RC0526_FAIL: missing production token {token}')
if not re.search(r'enum\s+TimelinePlanet\s*\{[^}]*\bsaturn\b[^}]*\}', source, flags=re.DOTALL):
    raise SystemExit('RC0511_RC0526_FAIL: TimelinePlanet enum is missing saturn')
if not re.search(r'enum\s+TimelineTopic\s*\{[^}]*\brelationship\b[^}]*\bcareer\b[^}]*\}', source, flags=re.DOTALL):
    raise SystemExit('RC0511_RC0526_FAIL: TimelineTopic enum is missing relationship/career')
regression = TEST.read_text(encoding='utf-8')
for token in (
    'high importance, Saturn, relationship and career filters are independent',
    'topic: TimelineTopic.relationship',
    'topic: TimelineTopic.career',
):
    if token not in regression:
        raise SystemExit(f'RC0511_RC0526_FAIL: missing timeline filter regression {token}')
print('RC0511_RC0526_OK')
