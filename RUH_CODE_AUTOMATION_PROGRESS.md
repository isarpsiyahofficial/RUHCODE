# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır.

## Son doğrulanmış durum

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı: 1.442 RC ID, deterministic classification, task/evidence sözleşmesi ve kanıtsız DONE yasağı mevcut.
- Faz 1 kısmi: AKİLES referans/runtime sınırı belgelendi; binary ZIP gerektiren exact hash, active JS/CSS/ephemeris/timezone envanteri ve 25.000+/6.400+ dataset dönüştürmeleri açık.
- Faz 2 temel bilgi mimarisi tamamlandı: `Bugün · Araçlar · Kayıtlar · Profil`, 106 SCREEN-ID ve geniş ACTION-ID sözleşmesi mevcut.
- Faz 3 structural UI sözleşmeleri mevcut: 106/106 ekran reference tracking, 33 state tracking, action registry, static asset manifest ve 14 zorunlu dynamic geometry contract.
- Gerçek UI reference dosyaları, gerçek static production assetleri ve dynamic renderer implementasyonları henüz APPROVED/DONE değil.
- Faz 4 structural design system mevcut: warm ivory `#FBF8F3`, primary purple `#4C2A91`, strong purple `#6B42E6`, gold `#C89338`, spacing/radius/typography/navigation/touch-target sözleşmeleri ve validatorlar mevcut.

## Bu tur — Faz 5 gerçek persistence ilerlemesi

- Flutter/Dart environment sözleşmesi güncel SQLite bağımlılığıyla uyumlu olacak şekilde `Dart >=3.12` / `Flutter >=3.44` seviyesine yükseltildi.
- Runtime local persistence için `sqflite ^2.4.3` ve `path ^1.9.1` eklendi.
- Unit/integration testlerinde gerçek SQLite transaction davranışını emülatör olmadan doğrulamak için `sqflite_common_ffi ^2.4.2` dev dependency olarak eklendi.
- `lib/src/data/local/sqflite_local_database.dart` ile gerçek SQLite adapter uygulandı.
- Schema v1 fiziksel olarak `app_meta` ve generic `records` tablolarıyla oluşturuluyor.
- SQLite `PRAGMA foreign_keys = ON` açılış konfigürasyonuna bağlandı.
- `PRAGMA integrity_check` gerçek database integrity doğrulamasına bağlandı.
- LocalDatabase transaction portu gerçek `sqflite` transaction ile çalışıyor; exception durumunda SQLite rollback davranışı kullanılıyor.
- Record payloadları locale-bağımsız JSON object olarak saklanıyor; `table_name + record_id` composite primary key kullanılıyor.
- `test/data/local/sqflite_local_database_test.dart` eklendi: schema-v1 write/read, Unicode/Türkçe payload, integrity check, forced rollback ve transactional delete senaryoları tanımlandı.
- `lib/src/data/local/core_model_codecs.dart` eklendi: Profile, BirthData, LocationRecord, Client, CalculationManifest, Consultation ve Note için locale-bağımsız persistence codec sözleşmesi oluşturuldu.
- `test/data/local/core_model_codecs_test.dart` eklendi: profil, danışan, calculation manifest, consultation ve note round-trip senaryoları tanımlandı.
- `.github/workflows/flutter-quality.yml` eklendi: Flutter 3.44.7 üzerinde dependency resolve + `flutter analyze --fatal-infos` + `flutter test` kapısı tanımlandı.
- Linux FFI testleri için workflow içinde `libsqlite3-0` ve `libsqlite3-dev` kurulumu eklendi.
- Phase 5 structural validator artık SQLite adapterını, transaction/rollback/integrity testini, persistence codec round-trip testlerini ve Flutter Quality workflow’unu zorunlu kılıyor.
- Güncel sqflite API dokümantasyonuna göre varsayılan factory adı `databaseFactorySqflitePlugin` olarak düzeltildi.

## Faz 5 — kanıt durumu

### Uygulanmış / source-level

- [x] Flutter package/entrypoint dosyaları oluşturuldu.
- [x] Platform bağımsız domain katmanı başlangıcı oluşturuldu.
- [x] Feature/layer sınırları oluşturuldu: calculation_core / interpretation / data / ui / pdf / backup / entitlements.
- [x] UUID tabanlı ID başlangıç standardı oluşturuldu.
- [x] MASTER TODO'da istenen ana domain model sınıfları tanımlandı.
- [x] Locale bağımsız enum/ID başlangıç sözleşmesi oluşturuldu.
- [x] Transaction/migration/integrity-check database portu tanımlandı.
- [x] Gerçek SQLite adapter source-level olarak uygulandı.
- [x] Schema-v1 creation source-level olarak uygulandı.
- [x] Gerçek SQLite integrity-check source-level olarak uygulandı.
- [x] Gerçek transaction rollback testi yazıldı.
- [x] Temel domain persistence codec ve round-trip testleri yazıldı.
- [x] Flutter analyze/test CI workflow’u yazıldı.
- [x] Structural architecture validator persistence contractını zorunlu kılıyor.

### Açık / DONE değil

- [ ] Yeni `Flutter Quality` workflow için SUCCESS kanıtı henüz alınmadı; testler yazılmış olsa da yeşil CI olmadan DONE sayılmayacak.
- [ ] `Architecture Contract`, `UI Contracts`, `Requirements Contract` latest exact commit üzerinde yeniden SUCCESS kanıtına bağlanmalı.
- [ ] Standart Flutter Android/iOS generated project klasörleri henüz yok.
- [ ] Android release/signing yapılandırması henüz yok.
- [ ] Schema v1 app-level repository/service katmanı henüz yok; şu an generic transactional persistence adapterı var.
- [ ] Future schema migration registry henüz yalnız v1 sınırında; gerçek v1→v2 migration ancak schema v2 tanımlandığında eklenebilir.
- [ ] Tüm domain modelleri için codec coverage henüz tamamlanmadı; Journal/Goal/Habit/Tarot/Preset/Interpretation/Entitlement/BackupManifest açık.
- [ ] Büyük veri/performance persistence testleri henüz yok.
- [ ] Gerçek Android cihaz/emülatör SQLite smoke testi henüz yok.

## Faz 1 — binary blocker

- [ ] AKİLES V96 Final 28 ZIP exact SHA-256 manifesti — binary paket repository/aktif automation workspace içinde yok.
- [ ] Exact aktif JS/CSS/ephemeris/timezone envanteri — ZIP gerekir.
- [ ] 25.000+ Vedik dataset fiziksel reference-test formatı — ZIP/dataset gerekir.
- [ ] 6.400+ planetary-hour dataset fiziksel reference-test formatı — ZIP/dataset gerekir.

## Sıradaki çalışma

1. Latest exact commit üzerindeki `Flutter Quality` sonucunu doğrula; kırmızıysa job logunu okuyup compile/test hatalarını düzelt.
2. Aynı commit zincirinde Architecture/UI/Requirements contract kapılarını doğrula.
3. Kalan domain modellerinin locale-independent codec ve round-trip testlerini tamamla.
4. Standard Flutter Android/iOS platform klasörlerini yalnız gerçek Flutter generator ile üret; elle sahte generated proje oluşturma.
5. Android SQLite smoke testi + release build kapısı ekle.
6. Faz 5 Flutter Quality ve persistence kapıları yeşil olduktan sonra Faz 6 Gregorian calendar core’a geç.
7. Faz 1 binary blocker sürüyorsa açık bırak; golden dataset iddiası yapma.

## Final durumu

**FINAL DEĞİL.** Faz 5 artık yalnız mimari porttan ibaret değil; gerçek SQLite adapterı, schema-v1, integrity check, rollback testleri, temel persistence codec/round-trip testleri ve Flutter analyze/test CI kapısı repository’de. Ancak yeni Flutter Quality workflow’un SUCCESS kanıtı, Android generated/release yapısı ve tüm domain codec coverage tamamlanmadan Faz 5 DONE sayılmayacak.
