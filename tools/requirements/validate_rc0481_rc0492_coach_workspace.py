import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0481_rc0492_coach_workspace_contract.json'
SOURCE = ROOT / 'lib/src/professional/coach_workspace.dart'
TEST = ROOT / 'test/professional/coach_workspace_rc0481_rc0492_test.dart'
WORKFLOW = ROOT / '.github/workflows/rc0481-rc0492-coach-workspace.yml'
for path in [SPEC, CONTRACT, SOURCE, TEST, WORKFLOW]:
    if not path.is_file():
        raise SystemExit(f'RC0481_RC0492_FAIL: missing {path.relative_to(ROOT)}')
spec = SPEC.read_text(encoding='utf-8')
for number in range(481, 493):
    if not re.search(rf'(?m)^{number}\.\s+\S', spec):
        raise SystemExit(f'RC0481_RC0492_FAIL: binding {number}. missing')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('required_numbered_entries') != list(range(481, 493)):
    raise SystemExit('RC0481_RC0492_FAIL: contract sequence mismatch')
if contract.get('promotion_ceiling') != 'IMPLEMENTED':
    raise SystemExit('RC0481_RC0492_FAIL: unsafe promotion ceiling')
source = SOURCE.read_text(encoding='utf-8')
for token in [
    'CoachClientWorkspace', 'CoachGoal', 'BetweenSessionAction', 'WeeklyGrowthReview',
    'OptionalGrowthReference', 'SingleScreenConsultationModel', 'SingleScreenSection',
    'usesReducedNavigation'
]:
    if token not in source:
        raise SystemExit(f'RC0481_RC0492_FAIL: missing production token {token}')
print('RC0481_RC0492_OK')
