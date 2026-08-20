# Ruh Code automation checkpoint — full portable backup lifecycle

Bu turda Backup/CSV hattında gerçek SQLite kaynak ve hedef veritabanları üzerinden uçtan uca portable restore zinciri eklendi.

## Eklenen kanıt zinciri

- `test/backup/backup_full_lifecycle_test.dart`
  - SQLite source → 14-table canonical export → package → ZIP encode/decode → strict preview → production import → target storage equality.
  - Aynı backup ikinci kez merge edildiğinde idempotency/storage equality.
  - `localeTag=tr` ve `localeTag=en` paketlerinin aynı machine storage sonucunu üretmesi.
  - 2.500 deterministic Unicode settings kaydıyla portable ZIP + replace restore stress senaryosu.
- `evidence/backup/full_lifecycle_contract.json`
  - Source-level lifecycle/stress invariants; `done=false` korunuyor.
- `tools/backup/validate_full_lifecycle_contract.py`
  - Lifecycle test/evidence zorunluluklarını structural CI seviyesinde kilitliyor.
- `.github/workflows/backup-csv-contract.yml`
  - Full lifecycle structural validator ve Flutter backup suite’e bağlandı.

## Düzeltme

İlk lifecycle test taslağında `BackupImportPreview.errors` kullanımı yanlıştı; gerçek API `issues` alanını kullanıyor. Aynı turda düzeltilerek CI’ye bilinen compile hatası bırakılmadı.

## Durum

Source-level olarak full portable SQLite pipeline, locale-independence, ikinci import idempotency ve 2.500-record stress senaryoları mevcut. Exact GitHub Actions/Flutter SUCCESS görünür kanıtı henüz alınamadığından ilgili RC maddeleri DONE’a yükseltilmedi.

## Açık backup işleri

1. 14 logical tablonun tamamında non-empty, ilişkisel representative fixture ile symmetry.
2. Legacy schema migration/adoption fixture ve migrator.
3. Android document picker/share-sheet entegrasyonu.
4. Clean-install export → erase → restore → domain-object equality.
5. Exact workflow SUCCESS ve clean-checkout dependency lock kanıtı.

## Bu turun commit zinciri

- `80fe838cbdd65a800cb4409cd756587503a21e5d` lifecycle test ilk sürüm
- `b0107420fee113d40f74f147d97716b51c8ab30b` lifecycle evidence
- `bae7e9313726cf62eb6ac644b9ecb6fba8b380fd` lifecycle validator
- `dc80ddc293ee27048d563febc655eb1cf542d904` CI wiring
- `500f0e7500b760dcaa4c2f09a10034a61f1dac98` preview API fix + 2.500-record stress
- `68697550e675e6cbf3ef4fff7995d8054fa1daf2` stress evidence
- `1120c367f0f9f36f50d0546160cbef33ef9b3206` stress validator

**FINAL DEĞİL.**
