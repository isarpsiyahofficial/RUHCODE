# Ruh Code automation checkpoint — backup platform gateway

## Yapılan işler

- `file_picker ^12.0.0` ve `share_plus ^13.3.0` bağımlılıkları eklendi.
- `BackupPlatformGateway` sözleşmesi oluşturuldu.
- `NativeBackupPlatformGateway` OS-native Save As, tek dosya seçme ve share-sheet akışlarını uyguluyor.
- Platform katmanı yalnız portable `.ruhcode.zip` byte'larıyla çalışıyor; serialization, ZIP doğrulaması ve SQLite katmanlarına karışmıyor.
- `.ruhcode.zip` suffix doğrulaması, path-injection reddi, boş/oversize payload reddi ve 64 MiB sınırı `BackupPlatformPolicy` içine alındı.
- Platform policy unit testleri eklendi.
- `evidence/backup/platform_gateway_contract.json` eklendi ve bilinçli olarak `done=false` bırakıldı.
- `tools/backup/validate_backup_platform_gateway_contract.py` eklendi.
- `Backup CSV Contract` workflow'una yeni validator ve test kapsamı bağlandı.

## Kanıt durumu

- GitHub combined-status exact workflow commit `7f7cc01f96771d5153c0d2ec12396740383e9d66` için `statuses=[]` döndürdü.
- Bu nedenle Flutter/Actions SUCCESS uydurulmadı ve ilgili RC maddeleri DONE yapılmadı.
- Android gerçek cihaz Save As / pick / share smoke testi hâlâ gereklidir.
- `pubspec.lock` hâlâ gerçek dependency resolution sonrasında üretilip commit edilmelidir; elle uydurulmayacaktır.

## İlgili RC alanları

Source-level ilerleyen alanlar: RC-0936, RC-0937, RC-0938, RC-0939, RC-0940, RC-1296, RC-1297, RC-1298, RC-1299, RC-1300.

## Sıradaki çalışma

1. Exact CI sonucu görünür kırmızı olursa düzelt.
2. Backup export/import uygulama servis katmanını platform gateway ile bağla; kullanıcı iptalini hata sayma.
3. TR/EN kullanıcı görünen backup action/state sözleşmesini UI registry'ye bağla.
4. Gerçek dependency resolution mümkün olduğunda `pubspec.lock` üret ve clean-checkout gate'e ekle.
5. Ardından PDF motoru source-level uygulamasına ilerle.
6. Fiziksel astronomi datasetleri, GeoNames, 8.036 günlük mesaj ve APPROVED UI referans blocker'larını paralel açık tut.

**FINAL DEĞİL.**