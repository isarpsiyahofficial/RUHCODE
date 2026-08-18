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

- Flutter/Dart environment sözleşmesi `Dart >=3.12` / `Flutter >=3.44` seviyesine yükseltildi.
- Runtime local persistence için `sqflite ^2.4.3` ve `path ^1.9.1`; test için `sqflite_common_ffi ^2.4.2` eklendi.
- `SqfliteLocalDatabase` gerçek SQLite adapterı eklendi.
- Schema v1 `app_meta` + `records` tablolarıyla fiziksel olarak tanımlandı.
- `PRAGMA foreign_keys = ON` ve `PRAGMA integrity_check` bağlandı.
- Gerçek transaction rollback ve transactional delete testleri yazıldı.
- `Flutter Quality` workflow’u Flutter 3.44.7 üzerinde `flutter analyze --fatal-infos` + `flutter test` çalıştıracak şekilde eklendi.
- Güncel sqflite API’sine göre varsayılan factory `databaseFactorySqflitePlugin` olarak düzeltildi.
- `CoreModelCodecs` artık bütün mevcut core domain modellerini kapsıyor: Profile/BirthData/Location, Client, CalculationManifest, Consultation, Note, JournalEntry, Goal, Habit, TarotSession, ProfessionalPreset, InterpretationTemplate, FeatureEntitlement ve BackupManifest.
- Codec testleri Unicode/Türkçe, null doğum verisi, ilişki ID’leri, ordered Tarot kartları, professional settings, TR interpretation metni, temporary entitlement ve backup record-count/checksum round-trip senaryolarını kapsıyor.
- Phase 5 structural validator artık bütün core-model codec çiftlerini ve ilgili test başlıklarını zorunlu kılıyor.

## Faz 5 — kanıt durumu

### Uygulanmış / source-level

- [x] Flutter package/entrypoint ve dört ana navigation destination mevcut.
- [x] Platform bağımsız domain katmanı ve UUID ID sözleşmesi mevcut.
- [x] calculation_core / interpretation / data / ui / pdf / backup / entitlements sınırları mevcut.
- [x] Transaction/migration/integrity-check DB portu mevcut.
- [x] Gerçek SQLite adapter source-level olarak mevcut.
- [x] Schema-v1 creation source-level olarak mevcut.
- [x] Gerçek SQLite integrity-check source-level olarak mevcut.
- [x] Gerçek transaction rollback testi mevcut.
- [x] Bütün mevcut core domain modelleri için locale-independent codec coverage mevcut.
- [x] Bütün codec grupları için round-trip testleri mevcut.
- [x] Flutter analyze/test CI workflow’u mevcut.
- [x] Structural architecture validator persistence + codec contractını zorunlu kılıyor.

### Açık / DONE değil

- [ ] `Flutter Quality` workflow SUCCESS kanıtı henüz alınmadı; source ve test mevcut olsa da yeşil CI olmadan DONE sayılmayacak.
- [ ] `Architecture Contract`, `UI Contracts`, `Requirements Contract` latest exact commit üzerinde yeniden SUCCESS kanıtına bağlanmalı.
- [ ] Standart Flutter Android/iOS generated project klasörleri henüz yok.
- [ ] Android release/signing yapılandırması henüz yok.
- [ ] Schema v1 app-level repository/service katmanı henüz yok; generic transactional persistence adapterı hazır.
- [ ] Future schema migration registry v1 sınırında; v1→v2 ancak schema v2 tanımlandığında gerçek veri dönüşümüyle eklenecek.
- [ ] Büyük veri/performance persistence testleri henüz yok.
- [ ] Gerçek Android cihaz/emülatör SQLite smoke testi henüz yok.

## Faz 1 — binary blocker

- [ ] AKİLES V96 Final 28 ZIP exact SHA-256 manifesti — binary paket repository/aktif automation workspace içinde yok.
- [ ] Exact aktif JS/CSS/ephemeris/timezone envanteri — ZIP gerekir.
- [ ] 25.000+ Vedik dataset fiziksel reference-test formatı — ZIP/dataset gerekir.
- [ ] 6.400+ planetary-hour dataset fiziksel reference-test formatı — ZIP/dataset gerekir.

## Sıradaki çalışma

1. Latest exact commit üzerinde `Flutter Quality` sonucunu doğrula; kırmızıysa job logunu okuyup compile/test hatalarını düzelt.
2. Aynı commit zincirinde Architecture/UI/Requirements contract kapılarını doğrula.
3. Standard Flutter Android/iOS platform klasörlerini yalnız gerçek Flutter generator ile üret; elle sahte generated proje oluşturma.
4. Android SQLite smoke testi + release build kapısı ekle.
5. Persistence için app-level repository katmanı ve büyük veri testi ekle.
6. Faz 5 gerçek Flutter Quality/persistence kapıları yeşil olduktan sonra Faz 6 Gregorian calendar core’a geç.
7. Faz 1 binary blocker sürüyorsa açık bırak; golden dataset iddiası yapma.

## Final durumu

**FINAL DEĞİL.** Faz 5’te gerçek SQLite adapter, schema-v1, integrity/rollback testleri ve tüm mevcut core-domain model codec round-trip kapsamı repository’de. Ancak Flutter Quality SUCCESS kanıtı, Android generated/release yapısı ve gerçek platform smoke testi olmadan Faz 5 DONE sayılmayacak.
