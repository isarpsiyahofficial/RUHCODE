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
    'highImportanceOnly', 'TimelineLanguagePolicy', 'TimelineFilterPreset', 'TimelinePresetLibrary'
]:
    if token not in source:
        raise SystemExit(f'RC0511_RC0526_FAIL: missing production token {token}')

# Enum members are validated semantically rather than by requiring a particular
# call-site spelling such as TimelinePlanet.saturn inside the production file.
def enum_has_member(enum_name: str, member: str) -> bool:
    match = re.search(rf'enum\s+{re.escape(enum_name)}\s*\{{([^}}]+)\}}', source, flags=re.DOTALL)
    if not match:
        return False
    members = [item.strip() for item in match.group(1).split(',') if item.strip()]
    return member in members

for enum_name, member in [
    ('TimelinePlanet', 'saturn'),
    ('TimelineTopic', 'relationship'),
    ('TimelineTopic', 'career'),
]:
    if not enum_has_member(enum_name, member):
        raise SystemExit(f'RC0511_RC0526_FAIL: missing production enum member {enum_name}.{member}')

# The regressions must exercise the filters, not merely declare enum members.
test = TEST.read_text(encoding='utf-8')
for token in ['TimelinePlanet.saturn', 'TimelineTopic.relationship', 'TimelineTopic.career', 'highImportanceOnly: true']:
    if token not in test:
        raise SystemExit(f'RC0511_RC0526_FAIL: missing regression filter token {token}')

print('RC0511_RC0526_OK')
