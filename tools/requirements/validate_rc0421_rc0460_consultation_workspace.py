import json
import re
from pathlib import Path

ROOT=Path(__file__).resolve().parents[2]
SPEC=ROOT/'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT=ROOT/'requirements/contracts/rc0421_rc0460_consultation_workspace_contract.json'
SOURCE=ROOT/'lib/src/professional/consultation_workspace.dart'
TEST=ROOT/'test/professional/consultation_workspace_rc0421_rc0460_test.dart'
WORKFLOW=ROOT/'.github/workflows/rc0421-rc0460-consultation-workspace.yml'
for p in [SPEC,CONTRACT,SOURCE,TEST,WORKFLOW]:
    if not p.is_file(): raise SystemExit(f'RC0421_RC0460_FAIL: missing {p.relative_to(ROOT)}')
spec=SPEC.read_text(encoding='utf-8')
for n in range(421,461):
    if not re.search(rf'(?m)^{n}\.\s+\S',spec): raise SystemExit(f'RC0421_RC0460_FAIL: binding {n}. missing')
contract=json.loads(CONTRACT.read_text(encoding='utf-8'))
if contract.get('required_numbered_entries') != list(range(421,461)): raise SystemExit('RC0421_RC0460_FAIL: contract sequence')
if contract.get('promotion_ceiling') != 'IMPLEMENTED': raise SystemExit('RC0421_RC0460_FAIL: unsafe promotion ceiling')
source=SOURCE.read_text(encoding='utf-8')
for token in ['ConsultationPreparation','TechnicalTransit','importanceReason','KnowledgeLibrary','ConsultationSession','ClientWorkspace','NumerologyPreparation']:
    if token not in source: raise SystemExit(f'RC0421_RC0460_FAIL: missing {token}')
print('RC0421_RC0460_OK')
