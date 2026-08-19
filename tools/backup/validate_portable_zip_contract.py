#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
EVIDENCE = ROOT / 'evidence/backup/portable_zip_contract.json'
SOURCE = ROOT / 'lib/src/backup/portable_zip_backup_codec.dart'
TEST = ROOT / 'test/backup/portable_zip_backup_codec_test.dart'
PUBSPEC = ROOT / 'pubspec.yaml'


def fail(message: str) -> None:
    raise SystemExit(message)


def main() -> None:
    for path in (EVIDENCE, SOURCE, TEST, PUBSPEC):
        if not path.exists():
            fail(f'Portable ZIP contract file is missing: {path.relative_to(ROOT)}')

    data = json.loads(EVIDENCE.read_text(encoding='utf-8'))
    if data.get('contract_id') != 'BACKUP-PORTABLE-ZIP-V1':
        fail('Unexpected portable ZIP contract id.')
    if data.get('done') is not False:
        fail('Portable ZIP contract must remain done=false until runtime/device/lifecycle gates pass.')

    invariants = data.get('invariants', {})
    required_invariants = [
        'single_file_zip',
        'logical_package_validation_preserved',
        'crc_verification_on_decode',
        'zip_slip_rejected',
        'absolute_paths_rejected',
        'directories_rejected',
        'symlinks_rejected',
        'duplicate_member_names_rejected',
        'member_count_bounded',
        'member_size_bounded',
        'expanded_total_size_bounded',
        'manifest_required',
    ]
    missing_flags = [key for key in required_invariants if invariants.get(key) is not True]
    if missing_flags:
        fail(f'Portable ZIP evidence is missing required invariant flags: {missing_flags}')

    pubspec = PUBSPEC.read_text(encoding='utf-8')
    if 'archive: ^4.0.9' not in pubspec:
        fail('pubspec must pin the reviewed archive 4.0.9 compatible constraint.')

    source = SOURCE.read_text(encoding='utf-8')
    for token in [
        'PortableZipBackupCodec',
        'ZipEncoder().encodeBytes',
        'ZipDecoder().decodeBytes(zipBytes, verify: true)',
        'isSymbolicLink',
        'duplicate member',
        'unsafe path traversal',
        'maxArchiveBytes',
        'maxMemberBytes',
        'maxMemberCount',
        "manifest.json",
    ]:
        if token not in source:
            fail(f'Portable ZIP source is missing required contract token: {token}')

    test_source = TEST.read_text(encoding='utf-8')
    for scenario in [
        'round-trips a flat logical package byte-for-byte',
        'unsafe traversal member on encode',
        'unsafe traversal member on decode',
        'rejects directory members',
        'rejects missing manifest',
        'member count above configured maximum',
        'expanded member above configured maximum',
    ]:
        if scenario not in test_source:
            fail(f'Portable ZIP tests are missing scenario: {scenario}')

    print('Portable ZIP backup structural contract OK.')


if __name__ == '__main__':
    main()
