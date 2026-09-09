from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'requirements/contracts/rc1175_rc1196_security_privacy_contract.json'
POLICY = ROOT / 'lib/src/security/privacy_and_storage_policy.dart'
TEST = ROOT / 'test/security/privacy_and_storage_rc1175_rc1196_test.dart'


def read(path: Path) -> str:
    if not path.is_file():
        raise AssertionError(f'missing required file: {path.relative_to(ROOT)}')
    return path.read_text(encoding='utf-8')


try:
    contract = json.loads(read(CONTRACT))
    policy = read(POLICY)
    test = read(TEST)
    expected = [f'RC-{i:04d}' for i in range(1175, 1197)]
    assert list(contract['requirements'].keys()) == expected, 'contract RC range/order mismatch'

    for token in (
        'PermissionIsolationPolicy',
        'notificationFeaturesAllowed',
        'ExportPrivacyPolicy',
        'requiresRemoteUpload => false',
        'writesToArbitraryRootFolder => false',
        'EncryptionPolicy',
        'fixedApplicationStringKeyAllowed => false',
        'serverRoundTripRequired => false',
        'platformKeystore',
        'AppLockMethod',
        'biometric',
        'hasPinFallback',
        'ProductionLogPolicy',
        'analyticsRequiredForCoreUsage => false',
        'telemetryRequiredForCoreUsage => false',
        'debugLogsAllowedInRelease => false',
        'customerName',
        'fullBirthDate',
        'consultationNotes',
        'TechnicalLogCode',
    ):
        assert token in policy, f'missing RC1175-RC1196 policy token: {token}'

    for token in (
        'notification denial is isolated',
        'export never requires remote upload',
        'forbids embedded fixed application keys',
        'biometric lock requires secure PIN fallback',
        'production logging rejects client names',
        'technical log event contains only anonymous technical fields',
    ):
        assert token in test, f'missing RC1175-RC1196 regression token: {token}'

except (AssertionError, KeyError, ValueError, OSError, json.JSONDecodeError) as exc:
    print(f'RC1175_RC1196_FAIL: {exc}', file=sys.stderr)
    raise SystemExit(1)

print('RC1175_RC1196_OK')
