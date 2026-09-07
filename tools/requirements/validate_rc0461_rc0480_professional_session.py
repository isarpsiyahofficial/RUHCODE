import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
SPEC=ROOT/'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT=ROOT/'requirements/contracts/rc0461_rc0480_professional_session_contract.json'
SOURCE=ROOT/'lib/src/professional/numerology_session_workspace.dart'
TEST=ROOT/'test/professional/numerology_session_workspace_rc0461_rc0480_test.dart'
WORKFLOW=ROOT/'.github/workflows/rc0461-rc0480-professional-session.yml'
for p in [SPEC,CONTRACT,SOURCE,TEST,WORKFLOW]:
    if not p.is_file(): raise SystemExit(f'RC0461_RC0480_FAIL: missing {p.relative_to(ROOT)}')
spec=SPEC.read_text(encoding='utf-8')
for n in range(461,481):
    if not re.search(rf'(?m)^{n}\.\s+\S',spec): raise SystemExit(f'RC0461_RC0480_FAIL: binding {n}. missing')
contract=json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('required_numbered_entries') != list(range(461,481)): raise SystemExit('RC0461_RC0480_FAIL: contract sequence')
if contract.get('promotion_ceiling') != 'IMPLEMENTED': raise SystemExit('RC0461_RC0480_FAIL: unsafe promotion ceiling')
source=SOURCE.read_text(encoding='utf-8')
for token in [
    'NumerologyYearPeriod','NumerologyPeriodProvider','FiveYearNumerologyTimeline',
    'NumerologyPairComparison','NumerologyAnalysisKind','NameAnalysisComparison',
    'NumerologyWorkspacePreferences','SpiritualConsultationSession','SpiritualCardRecord',
    'disclosurePolicyId','SpiritualSessionHistory'
]:
    if token not in source: raise SystemExit(f'RC0461_RC0480_FAIL: missing {token}')
print('RC0461_RC0480_OK')
