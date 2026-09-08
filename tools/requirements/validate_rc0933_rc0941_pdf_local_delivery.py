from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc0933_rc0941_pdf_local_delivery_contract.json'
PRODUCTION = ROOT / 'lib/src/pdf/pdf_local_delivery.dart'
TEST = ROOT / 'test/pdf/pdf_local_delivery_rc0933_rc0941_test.dart'

for path in (CONTRACT, PRODUCTION, TEST):
    if not path.exists():
        raise SystemExit(f'RC0933_RC0941_FAIL: missing {path.relative_to(ROOT)}')
contract = json.loads(CONTRACT.read_text(encoding='utf-8'))
expected = {f'RC-{i:04d}' for i in range(933, 942)}
if set(contract.get('requirements', {})) != expected:
    raise SystemExit('RC0933_RC0941_FAIL: exact requirement set mismatch')
if contract.get('status_ceiling') != 'IMPLEMENTED':
    raise SystemExit('RC0933_RC0941_FAIL: status ceiling must remain IMPLEMENTED')
production = PRODUCTION.read_text(encoding='utf-8')
test = TEST.read_text(encoding='utf-8')
for token in ('PdfFileNamePolicy', 'sanitizeBaseName', 'PdfLocalDeliveryTarget', 'systemShareSheet', 'emailApp', 'messagingApp', 'deviceFiles', 'requiresInternet => false', 'usesOwnedServer => false', 'acceptsRemotePdfUrl => false'):
    if token not in production:
        raise SystemExit(f'RC0933_RC0941_FAIL: missing production token {token!r}')
for token in ('never silently overwritten', 'delivery targets include share, email, messaging and device files', 'does not require internet or owned server', 'empty or non-pdf local delivery is rejected'):
    if token not in test:
        raise SystemExit(f'RC0933_RC0941_FAIL: missing regression token {token!r}')
print('RC0933_RC0941_OK')
