# Ruh Code automation checkpoint — Backup application service

Bu turda backup zinciri platform gateway seviyesinden application-service seviyesine taşındı.

## Yapılanlar

- `BackupApplicationService` eklendi.
- Runtime LocalDatabase exporter için `BackupPackageSource` adapter sınırı tanımlandı.
- Export → logical package → portable ZIP → OS Save As akışı bağlandı.
- Export → portable ZIP → native share akışı bağlandı.
- OS picker → ZIP decode → manifest/checksum/schema/FK strict preview akışı bağlandı.
- Preview tamamlanmadan storage mutation yapılmıyor.
- Merge/replace mutation mevcut transactional `BackupImportCoordinator` üzerinden uygulanıyor.
- Save/picker/share dismiss kullanıcı iptali olarak modelleniyor; exception/failure sayılmıyor.
- Application-service unit contract testleri eklendi.
- `evidence/backup/application_service_contract.json` ve structural validator eklendi.
- `Backup CSV Contract` workflow application-service validator/test kapsamını içeriyor.

## Kanıt durumu

Source-level implementation tamamlandı; evidence `done=false` tutuluyor. Exact Flutter/GitHub Actions SUCCESS görünür olmadan requirement state yükseltilmeyecek. Android gerçek cihaz Save As / picker / share smoke kanıtı ayrıca gerekiyor.

## Sıradaki işler

1. Backup UI action/state sözleşmesini application-service semantiğiyle eşleştir; export/import etiketlerini portable backup gerçeğiyle uyumlu hale getir.
2. TR/EN kullanıcı durumları: save cancelled, pick cancelled, preview valid/invalid, merge success, replace success/rollback, share dismissed/unavailable.
3. Exact CI kırmızı görünürse aynı turda düzelt.
4. Gerçek dependency resolution sonrası `pubspec.lock` üret ve clean-checkout gate'e bağla.
5. Backup hattı yeterince kapandıktan sonra profesyonel PDF motoruna ilerle.

**FINAL DEĞİL.**
