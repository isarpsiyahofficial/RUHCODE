# Ruh Code Automation Checkpoint — Backup CSV Codec

## Bu turda yapılan gerçek işler

- `lib/src/backup/csv_codec.dart` eklendi.
  - RFC-4180 tarzı comma/quote/newline quoting.
  - CRLF record separator.
  - `\\N` null sentinel.
  - Null ile empty string birbirinden ayrılıyor.
  - Literal `\\N` ve diğer leading-backslash metinler escape edilip round-trip oluyor.
  - Locale bağımsız machine-number sözleşmesi açık.
- `test/backup/csv_codec_test.dart` eklendi.
  - Türkçe Unicode.
  - Japonca/Arapça/emoji.
  - Virgül, çift tırnak ve embedded newline.
  - Null / empty / zero ayrımı.
  - Literal null sentinel round-trip.
  - CRLF/LF davranışı.
  - Locale bağımsız `12.45` örneği.
  - Unterminated quote rejection.
- `evidence/backup/csv_contract.json` eklendi; durum bilinçli olarak `SOURCE_LEVEL_IMPLEMENTED`, `done=false`.
- `tools/backup/validate_csv_contract.py` structural validator eklendi.
- `.github/workflows/backup-csv-contract.yml` structural validator + Flutter unit-test kapısı eklendi.

## Commit zinciri

- CSV codec: `87f88998da8daf0d84d9c7208bb4f3069823dbc4`
- CSV tests: `23c281e5cc97d3cfe71564b6b2ef7f7b360f23c3`
- Evidence contract: `a84e01ef39878b18457996c161a7fb99c504a199`
- Structural validator: `c8d38d395d8ec1d05ca783fe3811fa0c3321efac`
- CI workflow: `84ac231f3492305628b07c50e6692f135040d4db`

## Requirement etkisi

Source-level ilerleyen başlıca maddeler: `RC-0774`, `RC-0777`, `RC-0792`, `RC-0793`, `RC-0796–RC-0815` içindeki CSV encoding/escaping/null/date/enum makine-verisi sözleşmeleri.

Bu RC'ler **DONE yapılmadı**. Full backup package, per-table schema, manifest/checksum, transactional preview/import/merge/replace/rollback, schema migration, TR↔EN round-trip, stress test ve exact Flutter CI SUCCESS kanıtı hâlâ gerekli.

## CI görünürlüğü

`84ac231f...` için GitHub combined-status çağrısı yine `statuses=[]` döndürdü. Bu nedenle workflow SUCCESS iddiası yapılmadı.

## Sıradaki güvenli işler

1. CSV table schema registry (`profiles.csv`, `clients.csv`, `consultations.csv`, `notes.csv`, `calculations.csv`, manifests, journal, goals, habits, tarot, favorites, settings, professional templates).
2. Schema kolonları için nullable/enum/date/foreign-key sözleşmesi.
3. Backup manifest JSON + per-file SHA-256 + record counts.
4. UTF-8 byte boundary codec ve package-level validation.
5. Transactional import preview + merge/replace + rollback altyapısı.
6. Blocker bağımsız olarak Western house golden-data ve fiziksel EOP/ephemeris hatlarına devam.

**FINAL DEĞİL.**
