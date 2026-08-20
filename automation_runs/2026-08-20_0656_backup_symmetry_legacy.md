# Ruh Code automation checkpoint — backup symmetry + legacy migration

## Bu turda yapılan gerçek değişiklikler

- `test/backup/backup_all_tables_symmetry_test.dart` eklendi.
  - 14 logical backup tablosunun tamamı non-empty representative fixture ile dolduruluyor.
  - Fixture gerçek FK bağlarını içeriyor: consultation→client, calculation→manifest, journal/goal/habit→profile, tarot→client.
  - SQLite source → export → current package → portable ZIP → strict preview → production replace import → target SQLite raw storage equality sınanıyor.
  - Ayrı lifecycle içinde export sonrası registered tabloların tamamı gerçekten siliniyor, backup aynı veritabanına restore ediliyor ve hem raw storage hem `CoreRepositories` üzerinden domain-object snapshot eşitliği sınanıyor.
- `evidence/backup/full_lifecycle_contract.json` genişletildi; all-14-table, relational fixture ve erase→restore domain equality invariants eklendi.
- `tools/backup/validate_full_lifecycle_contract.py` yeni evidence/test sözleşmesini yapısal olarak zorunlu kılıyor.
- `lib/src/backup/legacy_backup_v0_migrator.dart` eklendi.
  - Legacy v0: manifest yok, `profiles.csv` zorunlu, `settings.csv` opsiyonel.
  - Eski profile formatında bulunmayan `birth_time_knowledge` yalnız belgeli kural ile türetiliyor: saat varsa `exact`, yoksa `unknown`.
  - Bilinmeyen saat hiçbir zaman `00:00:00` olarak uydurulmuyor.
  - v0'da bulunmayan yeni tablolar boş current-schema CSV olarak oluşturuluyor; veri uydurulmuyor.
  - Bilinmeyen legacy dosya ve header reddediliyor.
- `test/backup/legacy_backup_v0_migrator_test.dart` eklendi.
  - Exact birth-time migration.
  - Unknown birth-time / midnight-fallback yasağı.
  - Current strict preview + production SQLite import + `CoreRepositories` read proof.
  - Unknown member/header rejection.
- `evidence/backup/legacy_v0_migration_contract.json` ve `tools/backup/validate_legacy_v0_migration_contract.py` eklendi.
- `.github/workflows/backup-csv-contract.yml` legacy migration structural validator ve bütün backup Flutter testlerini kapsıyor.

## Commit zinciri

- `7c98cb0e66daab80ab6f984cac7ee7df1ceacbfc` — all-table symmetry + erase/restore test
- `daafa91264e4701736d45f99fa0441f8061451a2` — full lifecycle evidence expansion
- `f6656686241c7c93aeaac56fcf0a0fa0eb2a584a` — full lifecycle structural validator expansion
- `95d442c6887a97ed2b196a052c85821e9b785775` — legacy v0 migrator
- `997c190054dfe3e05721d3610fee069478e726b2` — legacy migration tests
- `3c6cc898eb3a5180d07743e63a2d6a848f83d71b` — legacy migration evidence
- `a00424f9e7329791ec4169160c51dd30e183d7af` — legacy migration validator
- `f962595646febeb8a978b558ab682c2900817753` — Backup CI wiring

## Kanıt durumu

- GitHub combined-status exact latest commit için yine `statuses=[]` döndürdü.
- Bu nedenle Flutter/GitHub Actions SUCCESS uydurulmadı.
- İlgili RC requirement'ları source-level ilerledi fakat DONE'a yükseltilmedi.

## Sıradaki güvenli işler

1. Backup testlerinde görünür CI sonucu elde edilirse kırmızı hataları aynı turda düzelt.
2. Android document picker/share-sheet adapterını core backup file store'dan ayrı platform katmanı olarak ekle.
3. Gerçek dependency resolution sonrası `pubspec.lock` üretim/reproducibility kapısını kapat.
4. Backup hattından sonra sıradaki bağımsız bloklara devam et: PDF engine contract, security/offline, physical astronomy evidence, GeoNames, 8.036 daily messages ve APPROVED UI reference seti.

**FINAL DEĞİL.**
