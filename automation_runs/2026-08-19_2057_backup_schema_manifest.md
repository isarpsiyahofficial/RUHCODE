# Ruh Code automation checkpoint — Backup schema + package manifest

Bu tur `RUH_CODE_MASTER_TODO.md` bağımlılık sırasındaki Backup / CSV hattını ilerletti.

## Uygulanan işler

- `lib/src/backup/backup_schema.dart`
  - schemaVersion=1
  - 14 taşınabilir CSV tablo sözleşmesi
  - sabit kolon sırası
  - primary key metadata
  - nullable metadata
  - locale-bağımsız enum ID metadata
  - ISO date / UTC ISO datetime / decimal / JSON tip metadata
  - ilişkisel tablolar için foreign-key metadata
- `lib/src/backup/backup_schema_validator.dart`
  - header/kolon sırası doğrulama
  - kolon sayısı doğrulama
  - required/nullability doğrulama
  - machine decimal doğrulama
  - boolean doğrulama
  - ISO date doğrulama
  - UTC `Z` datetime doğrulama
  - enum whitelist doğrulama
  - JSON parse doğrulama
  - duplicate primary-key reddi
  - cross-table foreign-key doğrulama
- `test/backup/backup_schema_test.dart`
  - required table inventory
  - duplicate table/column guards
  - locale-independent enum IDs
  - `36.8969` kabul / `36,8969` red
  - unknown translated enum red
  - non-UTC timestamp red
  - duplicate PK red
  - unresolved FK red
- `evidence/backup/schema_registry_contract.json`
- `tools/backup/validate_backup_schema_contract.py`
- `.github/workflows/backup-csv-contract.yml` backup schema test/validator kapsamını çalıştıracak şekilde genişletildi.

## Manifest/checksum hattı

- Resmî dart.dev `crypto` paketi `^3.0.7` eklendi.
- `lib/src/backup/backup_package_manifest.dart`
  - UTF-8 byte stream üzerinde SHA-256
  - record count
  - byte length
  - deterministic filename ordering
  - duplicate-file rejection
  - UTC export timestamp zorunluluğu
  - file tamper verification
- `test/backup/backup_package_manifest_test.dart`
- `evidence/backup/package_manifest_contract.json`

## Bu turda DONE yapılmayanlar

Source-level contract oluşturuldu ancak exact Flutter/Actions SUCCESS görünür olmadığı için ilgili RC maddeleri DONE yapılmadı. Full package writer/reader ve transactional restore henüz tamamlanmadı.

## Commit zinciri

- `9c767ff2ab0fc51f332e8fc19adf12149b0510a4` schema registry
- `af1010b6e368f431e98b88ea7f344cbd886d0c9d` schema validator
- `edaf9e52247295d42c304b57cdb7f270ec810a91` schema tests
- `0f998c38895a2027f95fae95f77f4f8c0d9e5cfd` schema evidence
- `e6abbd54bb5a8d7abe76e94ae0d59404a109cd64` schema structural validator
- `f40dbf4e5f09a3f503c96b374c4a64078134a3e2` backup CI expansion
- `5413cd2ec7e1fba4b690ad46b74ce8b6ba3186fd` crypto dependency
- `30db4145d3f7d8039e2fd630a1be76e80eef024c` package manifest builder
- `87b84e57ff07c9b9266e5297f4882296d199d653` package manifest tests
- `c5da46e9135313471ab1aa513448d80c7cdaf0ce` package manifest evidence

## CI görünürlüğü

GitHub combined-status sorgusu `c5da46e...` için yine `statuses=[]` döndürdü. SUCCESS iddiası yapılmadı.

## Sıradaki güvenli işler

1. Backup package writer/reader: `manifest.json` + UTF-8 CSV byte files.
2. Import pipeline: package decode -> manifest/checksum/count -> schema -> FK -> preview.
3. Transactional merge/replace; replace öncesi safety snapshot; failure rollback.
4. Duplicate-ID policy ve idempotent re-import.
5. TR→EN / EN→TR round-trip + legacy schema migration tests.
6. Physical astronomy/UI/content blocker dışındaki bağımsız işlere devam.
