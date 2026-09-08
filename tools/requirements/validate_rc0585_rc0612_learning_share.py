from pathlib import Path
import json
import re

ROOT = Path(__file__).resolve().parents[2]
SPEC = ROOT / 'RUH_CODE_MASTER_SARTNAME.md'
CONTRACT = ROOT / 'requirements/contracts/rc0585_rc0612_learning_share_contract.json'
PROD = ROOT / 'lib/src/learning/learning_and_share.dart'
TEST = ROOT / 'test/learning/learning_and_share_rc0585_rc0612_test.dart'

for path in (SPEC, CONTRACT, PROD, TEST):
    if not path.exists():
        raise SystemExit(f'missing required evidence: {path.relative_to(ROOT)}')

spec = SPEC.read_text(encoding='utf-8')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
prod = PROD.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')

for n in range(585, 613):
    if not re.search(rf'(?m)^{n}\.\s+\S', spec):
        raise SystemExit(f'binding requirement {n}. missing')
    rc = f'RC-{n:04d}'
    if rc not in contract.get('requirements', {}):
        raise SystemExit(f'{rc} missing from exact contract')

for token in [
    'LearningTopic.planet', 'LearningTopic.sign', 'LearningTopic.house', 'LearningTopic.aspect',
    'LearningTopic.combination', 'TeachingLayer.houses', 'TeachingLayer.planets', 'TeachingLayer.aspects',
    'ShareCardKind.sky', 'ShareCardKind.personalDay', 'ShareCardKind.universalDay', 'ShareCardKind.spiritual',
    'calculationResultRef', 'professionalText', 'DailyContentAssistant'
]:
    if token not in prod:
        raise SystemExit(f'production evidence token missing: {token}')

for phrase in ['Learning mode exposes', 'Teaching view can isolate', 'Share cards require calculation-backed data', 'does not invent data']:
    if phrase not in test:
        raise SystemExit(f'regression evidence missing: {phrase}')

if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('status ceiling must remain IMPLEMENTED until rendered/UI/export/release evidence exists')

print('RC-0585..RC-0612 learning/share contract OK')
