# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte independent/golden, TR/EN, offline, Free/PRO, backup/PDF, security, accessibility, performance, clean-checkout/lifecycle/device ve exact-release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Canonical durum özeti

- Erken bloklardaki mevcut status/promotion zincirleri korunuyor; RC-0062/0082/0083/0086/0087, exact AKİLES provenance ve global release blocker'ları açık.
- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0950 = implementation/matrix zincirleri mevcut; production-scale golden, rendered UI/device, PDF/backup ve diğer global blocker'lar nedeniyle DONE değil.
- RC-0951→0964 = IMPLEMENTED + blocked=YES; physical matrix promotion `5f08942462a0b3784725b9fd7e65de0cc22eb50e`.
- RC-0965→0994 = requirement/test traceability audit ve CI hattı mevcut; 1.442 RC'nin tamamı doğrudan evidence ile kapanmadığı için release-mode fail-closed.
- RC-0995→1003 = authoritative golden corpus sözleşmesi var; exact AKİLES ve bağımsız production golden değerleri eksik olduğu için promotion yok.
- RC-1004→1039 = IMPLEMENTED + blocked=YES; promotion `fb71d1b9703f35a4dec499e7d7de33151d57a75e`.
- RC-1040→1058 = IMPLEMENTED + blocked=YES; promotion `d96a3b5c1821d81739b491757795cfced5ba040a`.
- RC-1059→1084 = IMPLEMENTED + blocked=YES; physical promotion `ed87a5c385425a0c3e7f59f7f884c8dc55cab8f6`.
- RC-1085→1104 = IMPLEMENTED + blocked=YES; physical promotion `a9c4b832269328935dbf6d4753f603d17fa5b1f7`.
- RC-1105→1130 = offline startup/dependency governance zinciri mevcut; `pubspec.lock` fiziksel olarak `09cf4da44c63c8031a149a7c555e37362ef194aa` ile oluştu. EOP/DE440s/package license/device/exact-release blocker'ları açık.
- RC-1131→1144 = feature-branch/PR/release governance PR #1'de. Önceki release APK/minified build işi yeşildi; governance regression çağrısındaki Python path hatası `8b71601faaa6cc2d82ef990b18ce0245588d2de8` ile düzeltildi. Yeni dedicated run `34301183122` checkpoint anında queued. Repository-level branch protection/ruleset, independent review, physical/device minified parity ve exact final artifact kanıtı olmadan VERIFIED/DONE yok.
- RC-1145→1160 = explicit Android API floor + API21/API37 emulator launch gate + production UI compatibility matrisi stacked PR #2'de. UI viewport/font/chart/table/keyboard physical evidence tamamlanmadan VERIFIED/DONE yok.
- RC-1161→1174 = indexed offline city search + TR/EN birth date/time policy + explicit unknown-time state + stable-id recent locations + GPS-denial manual fallback PR #3'te production/regression/contract/CI olarak uygulandı. Dedicated run `34301408373` checkpoint anında queued; lifecycle yükseltilmedi.
- RC-1175→1196 = permission isolation + local export/storage privacy + encryption key-origin/app-lock policy + PII-safe production logging production/regression/contract/CI olarak stacked branch'te uygulandı. Real platform adapter/device/release-binary kanıtları eksik olduğu için DONE değil.

## Son çalıştırmada yapılan gerçek geliştirme

### RC-1131→1144 governance CI root-cause düzeltmesi

PR #1 workflow run `34293326532` incelendi. Static release-governance validator başarılıydı; minified/obfuscated release APK build, debug artifact reject ve artifact digest adımları da başarılıydı. Kırmızı sonuç yalnız `python -m unittest test/governance/test_rc1131_rc1144_release_governance.py -v` çağrısının `test.governance` paketini import etmeye çalışıp `ModuleNotFoundError` üretmesinden geliyordu. Workflow test çağrısı doğrudan dosya execution biçimine çevrildi: `python test/governance/test_rc1131_rc1144_release_governance.py -v` (`8b71601faaa6cc2d82ef990b18ce0245588d2de8`). Yeni dedicated run `34301183122` oluştu ancak checkpoint anında queued; promotion/DONE yok.

### RC-1161→1174 date/time + city search + manual location

Binding şartname RC-1161→1174 TR/EN date/time picker davranışı, açık bilinmeyen doğum saati seçeneği, yaklaşık 100.000 kayıt üzerinde hızlı şehir araması, Türkçe karakter/`Istanbul`↔`İstanbul` normalizasyonu, alias, aynı isimli şehir disambiguation, recent locations, GPS zorunluluğunun kaldırılması ve permission-denied manual fallback ister.

Mevcut `CityCatalog.search()` her sorguda tüm kayıtları lineer geziyordu. Bundled city manifesti 200.000+ kayıt ölçeğini doğrulasa da runtime arama path'i bu ölçeğe özel indeksli değildi. `lib/src/data/location/city_catalog.dart` artık normalized candidate'ları bir kez hazırlar ve üç-karakter prefix bucket index'i üzerinden >=3 karakter sorguları daraltır (`0dc2f1f52bc9175a9f9f4d7c818dd4753ed162f0`). Canonical display, aliases, country/admin region ve stable city identity korunur.

`lib/src/data/location/location_input_policy.dart` eklendi (`eef1bb01c3cec5c1b9408d9a52bb11b393664aeb`). `BirthTimePrecision` unknown/approximate/exact ayrıdır; unknown durumda saat/dakika null kalmak zorundadır ve midnight gibi sentetik saat üretilemez. TR/EN date/time sunumu ayrı testlenebilir. `RecentLocationStore` stable city ID bazlı bounded MRU davranışı sağlar. `LocationInputPolicy` birth place için GPS'i zorunlu kılmaz, manual selection'ı her permission state'te açık tutar ve denied/permanentlyDenied durumunda TR/EN manual fallback mesajı üretir.

Regression `test/data/location_input_rc1161_rc1174_test.dart` (`04ec818e6984d07c343c74b81e288d0706563041`, compile-safe fix `2ffc2e58e6668d458be16770dff7b3459d45345f`) TR/EN tarih/unknown-time, approximate/exact validation, 100.001 kayıt fixture üzerinde indexed `istan` araması, `Istanbul`/`İstanbul`/`Constantinople`, iki ayrı Springfield disambiguation, bounded recent locations ve GPS denial manual fallback davranışlarını kapsar.

Exact contract `b610a36940924f856b341d9e9a4a7ba277ebe17c`; fail-closed validator `8b3ef279d5e8e4b0cfd05bf6bf734bf9957255d7`; dedicated CI/matrix gate `7d3b37633275df634296dd4d45e80a30e23b0560`; progress checkpoint `d8ae13e268b33124230d82fba7dbf1ecef63cfae`. PR #3 açıldı. Dedicated run `34301408373` queued olduğu için matrix/lifecycle elle yükseltilmedi.

### RC-1175→1196 permission / storage / encryption / privacy logging

`lib/src/security/privacy_and_storage_policy.dart` eklendi (`78bb89b3df05ece7b21d7144d3cacbb91da3fa35`). Notification izni reddi çekirdek kullanım kararından izole; manual location permission reddinde kullanılabilir kalır. Export üçüncü tarafa ancak kullanıcı açıkça başlatır ve local artifact hazırsa çıkabilir; remote upload ve arbitrary root-folder write çekirdek gereksinim değildir.

`EncryptionPolicy` profesyonel veri için local encryption sınırını, `platformKeystore` veya user-derived key origin'i ve fixed application string key yasağını açıklar; server round-trip gerektirmez. `AppLockPolicy` PIN/biometric yöntemlerini ayrı tutar ve biometric için secure PIN fallback'i fail-closed zorunlu kılar. Export kilidi atlayamaz; başarılı unlock sonrası çalışabilir.

`ProductionLogPolicy` production log payload'larında customer/client name, full birth date, consultation notes ve birth-place gibi kişisel alanları fail-closed reddeder. `PrivacySafeLogEvent` yalnız anonim technical code + UTC timestamp + opsiyonel component taşır. Core kullanım için analytics/telemetry zorunlu değildir ve release debug logs policy seviyesinde kapalıdır.

Regression `9db535fb1a313985dc6d4f3370fbb39b8aaeb10d`; exact contract `3cc3e382cb7fae49a6dc949752e17524645212ab`; fail-closed validator `8a27d98996a7835ee1162081d378e8eff3ad684e`; dedicated CI/matrix gate `d866c6ab7e87cc4f606d1fa6debb4a36a0dbd9f4`.

Bu blok real Android/iOS secure storage/keystore/biometric adapter, encrypted SQLite migration, platform modern-storage integration ve release binary/log inspection olmadan TESTED/VERIFIED/DONE olmayacak.

## Açık blocker'lar

Authoritative independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; historical timezone/DST/polar goldens; production localization catalog + rendered TR/EN UI/PDF/share cards; interpretation/editorial QA; EOP/DE440s exact redistribution/license evidence; dependency license approvals; encrypted persistence/key management adapter; production migration corpus; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode physical device proof; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact açık.

RC-1132/1135/1136 için repository-level branch protection/ruleset enforcement kanıtı ayrıca gereklidir. RC-1143/1144 için compile-only minified build yeterli değildir; behavior parity/reflection path'leri integration/device seviyesinde doğrulanmalıdır. RC-1148→1160 için compatibility matrix tanımı tek başına yeterli değildir; production UI üzerinde viewport/font/chart/table/keyboard evidence gerekir. RC-1161→1174 için policy/unit testler production picker/form/permission wiring kanıtının yerine geçmez. RC-1175→1196 için policy/unit testler gerçek secure-storage/encryption/biometric/platform-storage ve release-binary log kanıtının yerine geçmez.

## Sonraki devam noktası

1. PR #1 governance fix sonrası run `34301183122` sonucunu fiziksel doğrula; kırmızıysa aynı branch'te root-cause düzelt.
2. PR #2 RC-1145→1160 API21/API37 emulator + production UI gate sonucunu fiziksel doğrula ve kırmızıysa düzelt.
3. PR #3 run `34301408373` sonucunu fiziksel doğrula; indexed search/Flutter compile kırmızıysa aynı branch'te düzelt. Green olsa bile yalnız IMPLEMENTED+blocked promotion yap.
4. RC-1175→1196 stacked CI sonucunu fiziksel doğrula; sonra binding sırada RC-1197+ tam veri silme / tek müşteri silme / cascade/archive / restore semantics hattını ilerlet.
5. RC-0995→1003 exact AKİLES provenance/independent goldens ve RC-0965→0994 traceability açıklarını paralel azalt.
6. RC-0001→RC-1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL deme.

**FINAL: NO.**
