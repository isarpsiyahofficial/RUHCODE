# Ruh Code automation checkpoint — service entitlement guards

## Bu turda uygulanan gerçek değişiklikler

- `GuardedProfessionalPdfService<TSnapshot>` eklendi. Profesyonel PDF byte üretimi artık UI/route kontrolünden bağımsız olarak `FeatureAccessGuard.runService()` üzerinden `RuhFeatureIds.pdfProfessionalExport` yetkisini zorunlu kılıyor.
- Free durumda PDF delegate hiç çalıştırılmıyor; PRO durumda tam bir kez çalıştırılıyor. Bunun için `test/entitlements/guarded_pdf_service_test.dart` eklendi.
- `GuardedRecordRepository<T>` eklendi. Korunan persisted kayıtların read/save/delete/replace operasyonları service-level entitlement kontrolünden geçmeden `JsonRecordRepository` ve dolayısıyla database transaction katmanına ulaşamıyor.
- Locked professional repository testinde hiçbir database transaction başlatılmadığı kanıt sözleşmesine bağlandı; PRO durumda save/find/replace/delete delegate'e gidiyor.
- `evidence/entitlements/feature_policy_contract.json` service-level PDF ve protected-record guard özellikleriyle genişletildi; `done=false` korunuyor.
- `tools/entitlements/validate_feature_policy_contract.py` yeni production guard dosyaları, testleri ve evidence maddelerini zorunlu kılacak şekilde sertleştirildi.
- `Feature Entitlement Contract` workflow'u guarded PDF service değişikliklerinde de tetiklenecek şekilde güncellendi.

## Commit zinciri

- `e75f54a4149ca08c3a0c5bdaa1f8dd55ddbc4326` — professional PDF service guard
- `559314f048451b78e2858dd2bc358a9080b5503b` — PDF service guard tests
- `825b0daff711eeeeb357566cf3e0cccac01a2adc` — entitlement CI path coverage
- `dd069b8686fdf01cccc147d539f7bb7191a2b2ae` — guarded persisted record repository
- `2b97b6948a1f8cab5bf79b01d3a880314b7eed83` — guarded record repository tests
- `5ad8ae927d54b9abe751f5a24e7560123c3ea596` — service guard evidence
- `17451b1a57c6b71f859035c86598102f642a507a` — structural entitlement validator extension

## Kanıt durumu

- Source/test/evidence/CI contract ilerledi.
- GitHub combined-status endpoint yeni workflow hedefinde yine individual check sonucu döndürmedi; SUCCESS uydurulmadı.
- İlgili RC'ler bu nedenle DONE'a yükseltilmedi.

## Sıradaki güvenli iş

1. `GuardedRecordRepository` wrapper'larını concrete professional client/preset application-service composition root'una bağla; doğrudan raw repository kullanımını production feature service yolunda kaldır.
2. Google Play lifetime ownership restore'u app startup coordinator'a bağla; outage/offline cache semantics'i koru.
3. Exact entitlement workflow kırmızı görünürse aynı turda düzelt.
4. Blocker dışı PDF hattında 5/25/50+ fixture/page-count test altyapısını ve full parser/crop/glyph gates'i ilerlet; approved font binary yoksa DONE deme.
5. Requirement state yalnız görünür test/evidence kanıtıyla yükseltilecek.

## Final

FINAL DEĞİL. RC-0001→RC-1442 ve bütün release kapıları tamamlanmadan final etiketi kullanılmayacak.
