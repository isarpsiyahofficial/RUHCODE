#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CONTRACT = ROOT / 'evidence' / 'backup' / 'csv_contract.json'
SOURCE = ROOT / 'lib' / 'src' / 'backup' / 'csv_codec.dart'
TEST = ROOT / 'test' / 'backup' / 'csv_codec_test.dart'


def fail(message: str) -> None:
    raise SystemExit(f'CSV CONTRACT ERROR: {message}')


def main() -> None:
    if not CONTRACT.is_file():
        fail('missing evidence contract')
    if not SOURCE.is_file():
        fail('missing CSV codec source')
    if not TEST.is_file():
        fail('missing CSV codec tests')

    data = json.loads(CONTRACT.read_text(encoding='utf-8'))
    if data.get('contract_id') != 'RUH-BACKUP-CSV-V1':
        fail('unexpected contract_id')
    if data.get('status') != 'SOURCE_LEVEL_IMPLEMENTED':
        fail('status must remain SOURCE_LEVEL_IMPLEMENTED until full proof exists')
    if data.get('done') is not False:
        fail('contract must not claim DONE before full backup proof')
    if data.get('encoding') != 'UTF-8':
        fail('UTF-8 is mandatory')
    if data.get('null_encoding') != r'\N':
        fail('null sentinel contract changed unexpectedly')
    if not data.get('empty_string_is_distinct_from_null'):
        fail('null/empty distinction is mandatory')
    if not data.get('locale_independent_numbers_required'):
        fail('locale-independent machine numbers are mandatory')
    if not data.get('machine_dates_must_use_iso'):
        fail('ISO machine dates are mandatory')
    if not data.get('localized_enum_labels_forbidden_in_backup'):
        fail('localized enum labels must not be persisted')

    coverage = data.get('coverage', {})
    required = {
        'quoted_commas',
        'embedded_double_quotes',
        'embedded_newlines',
        'turkish_unicode',
        'multiscript_unicode',
        'emoji',
        'null_empty_zero_distinction',
        'literal_null_sentinel_round_trip',
        'trailing_record_separator',
        'malformed_unterminated_quote_rejected',
    }
    missing = sorted(key for key in required if coverage.get(key) is not True)
    if missing:
        fail(f'missing coverage flags: {missing}')

    source = SOURCE.read_text(encoding='utf-8')
    for token in [
        'RuhCsvValueCodec',
        'RuhCsvDocumentCodec',
        "nullSentinel = r'\\N'",
        "replaceAll('\"', '\"\"')",
        'FormatException',
    ]:
        if token not in source:
            fail(f'missing source invariant: {token}')

    tests = TEST.read_text(encoding='utf-8')
    for phrase in [
        'İbrahim Yeşilyurt',
        '東京',
        'مرحبا 🌙',
        'preserves null, empty string, zero',
        'machine decimal representation remains locale independent',
        'rejects unterminated quoted fields',
    ]:
        if phrase not in tests:
            fail(f'missing test invariant: {phrase}')

    print('CSV backup source-level contract OK')


if __name__ == '__main__':
    main()
