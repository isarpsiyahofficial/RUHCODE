# Ruh Code automation checkpoint — Backup SQLite durable snapshot

## Bu turda ilerleyen gerçek işler

- `LocalDatabaseTransaction` yalnız transaction içinden erişilebilen `readTable` ve `clearTable` bulk operasyonlarını kazandı.
- `SqfliteLocalDatabase` bu operasyonları generic `records` tablosunda deterministik `record_id` sırasıyla uyguluyor.
- `LocalDatabaseBackupImportStore`, logical backup tablolarını production offline database'e bağlayan `BackupImportStore` adapterı olarak eklendi.
- Merge import canonical primary-key upsert akışını gerçek `LocalDatabase.transaction` üzerinden kullanıyor.
- Replace import destructive mutation öncesinde diske flush edilen durable JSON safety snapshot oluşturuyor.
- Snapshot restore, snapshot version ve database schema version doğrulaması yaptıktan sonra bütün registered backup tablolarını tek transaction içinde geri yüklüyor.
- Backup CSV satırları runtime storage payload şekline dönüştürülüyor; Profile mapping doğrudan `CoreRepositories` ile okunabilir şekilde test edildi.
- SQLite FFI integration testi gerçek production adapter üzerinden profile merge ve durable snapshot restore akışlarını kapsıyor.
- `evidence/backup/production_store_contract.json` ve `tools/backup/validate_backup_production_store_contract.py` eklendi.
- `Backup CSV Contract` workflow'u artık `lib/src/data/local/**`, production-store validator ve `test/backup test/data` Flutter testlerini kapsıyor.

## Commit zinciri

- `b9a3993f8fccfe9358fe665ffb96907f963914b7` — LocalDatabase bulk transaction contract
- `5d5f0454c3b523e6e16c1e5ba7b30949399d93fc` — Sqflite bulk table snapshot/clear implementation
- `051e5351038918081f1404515032be3763ffdb93` — production LocalDatabaseBackupImportStore
- `e75e35034beef37bb38dd7baddc3505161ca51bd` — existing memory test adapter compatibility
- `c43be712c11841de962cf3a1ab15d2ae9a882aca` — production adapter integration tests
- `24b6f457d7e370006c3aa88103dd6bcab1d1ea7d` — snapshot file assertion correction
- `99fc529ffeade9c080609e3b257d4488bae19ed9` — production-store evidence contract
- `e985cb8e080cc8867263339921c8c1137a443b70` — production-store structural validator
- `c64d1a5576a872706731acd30771e8a1544b5e37` — Backup CSV CI wiring

## Kanıt durumu

GitHub combined-status endpoint son CI-wiring commit'i için individual status göstermedi (`statuses=[]`). Bu yüzden production backup RC'leri DONE'a yükseltilmedi ve CI SUCCESS uydurulmadı.

## Açık backup işleri

1. Gerçek portable ZIP/file adapter: logical `BackupPackageBytes` ↔ tek dosya byte stream.
2. Device file save/open entegrasyonu.
3. Export tarafında runtime storage payload → canonical CSV row mapping.
4. TR→EN / EN→TR clean-install round trip.
5. Legacy schema migration/adoption politikası ve testleri.
6. Büyük veri/stress restore.
7. Export → erase → restore → domain equality golden lifecycle kanıtı.

## Final

FINAL DEĞİL. Backup production storage hattı source-level olarak ilerledi; exact CI ve kalan portable/lifecycle kanıtları tamamlanmadan ilgili requirement'lar DONE sayılmayacak.
