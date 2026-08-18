# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır.

## Son doğrulanmış kapsam

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı: 1.442 RC ID, deterministic classification, task/evidence sözleşmesi ve kanıtsız DONE yasağı mevcut.
- Faz 1 kısmi: AKİLES referans/runtime sınırı belgelendi; binary ZIP gerektiren exact hash, aktif JS/CSS/ephemeris/timezone envanteri ve 25.000+/6.400+ dataset dönüştürmeleri açık.
- Faz 2 temel bilgi mimarisi mevcut: `Bugün · Araçlar · Kayıtlar · Profil`, 106 SCREEN-ID ve ACTION-ID sözleşmesi mevcut.
- Faz 3 structural UI sözleşmeleri mevcut: 106/106 ekran reference tracking, state tracking, action registry, static asset manifest ve dynamic geometry contract mevcut. Gerçek reference PNG dosyaları repository içinde henüz APPROVED değil.
- Faz 4 structural design system mevcut: warm ivory `#FBF8F3`, primary purple `#4C2A91`, strong purple `#6B42E6`, gold `#C89338`, spacing/radius/typography/navigation/touch-target sözleşmeleri mevcut.

## Faz 5 — persistence

### Uygulanmış / source-level

- [x] Flutter package/entrypoint ve dört ana navigation destination mevcut.
- [x] Platform bağımsız domain katmanı ve UUID ID sözleşmesi mevcut.
- [x] calculation_core / interpretation / data / ui / pdf / backup / entitlements sınırları mevcut.
- [x] Transaction/migration/integrity-check DB portu mevcut.
- [x] SQLite adapter, schema-v1 creation ve integrity-check source-level mevcut.
- [x] SQLite FFI rollback/integrity testleri mevcut.
- [x] Core domain model codec coverage ve round-trip testleri mevcut.
- [x] Generic transactional `JsonRecordRepository<T>` mevcut.
- [x] `JsonRecordRepository<T>` için save/find/delete, atomic ID replacement ve injected-failure rollback testleri eklendi.
- [x] `CoreRepositories` typed registry eklendi: profile, client, calculation manifest, consultation, note, journal, goal, habit, tarot, professional preset ve interpretation template repository’leri ayrı typed erişime sahip.
- [x] Phase-5 architecture validator typed repository ve rollback testlerini zorunlu kılıyor.

### Açık / DONE değil

- [ ] Yeni persistence değişikliklerinin `Flutter Quality` SUCCESS kanıtı alınmalı.
- [ ] Architecture/UI/Requirements contract kapıları latest exact commit üzerinde SUCCESS kanıtına bağlanmalı.
- [ ] Standart Flutter Android/iOS generated project klasörleri henüz yok.
- [ ] Android release/signing yapılandırması henüz yok.
- [ ] Gerçek Android cihaz/emülatör SQLite smoke testi henüz yok.
- [ ] Büyük veri/performance persistence testleri henüz yok.

## Faz 6 — Gregorian calendar + IANA timezone + daily date

### Uygulanmış / source-level

- [x] Strict `CivilDate` ve destek aralığı `1890–2110` mevcut.
- [x] Gregorian `%400/%100/%4` artık yıl kuralları mevcut.
- [x] 1900 non-leap, 2000 leap, 2028/2032/2036 leap ve 2100 non-leap testleri mevcut.
- [x] 28→29 Şubat→1 Mart ve normal 28 Şubat→1 Mart geçiş testleri mevcut.
- [x] Locale/timezone bağımsız `YYYY-MM-DD` exact-date key ve ISO weekday mevcut.
- [x] `16.08.2026` ile `16.08.2027` ayrı tarih/weekday olarak test ediliyor.
- [x] `timezone ^0.11.1` ve `flutter_timezone ^5.1.0` bağımlılıkları eklendi.
- [x] `TimeZoneRuntime` paketlenmiş `latest_all` IANA verisini kullanacak şekilde eklendi.
- [x] Runtime timezone dataset sürümü `2025c` manifest/sözleşmesinde kayıtlı.
- [x] App startup sırasında bundled timezone database initialize ediliyor.
- [x] Explicit ambiguous-time politikaları: `earlier / later / reject`.
- [x] Explicit nonexistent-time politikaları: `reject / shiftForward`.
- [x] Half-hour `Asia/Kolkata`, 45-minute `Asia/Kathmandu`, UTC+14 `Pacific/Kiritimati` testleri mevcut.
- [x] Date-line aynı-an/farklı-gün testi mevcut.
- [x] `America/New_York` DST overlap/gap testleri mevcut.
- [x] `Pacific/Apia` 2011 skipped civil-day testi mevcut.
- [x] `FlutterDeviceTimeZoneProvider` platform IANA identifier’ını bundled database’e karşı doğruluyor.
- [x] `DailyDateContext` exact `dateKey` + timezone cache partition key üretiyor.
- [x] İstanbul local-midnight rollover testi mevcut.
- [x] Aynı gün/ay farklı yıl DailyDate key ayrımı mevcut.
- [x] 2028-02-29 daily-date key testi mevcut.
- [x] `Timezone Contract` structural CI kapısı mevcut ve daily-date/device-zone contractını kapsıyor.
- [x] `requirements/data_manifests/timezone.json` lokal dataset/version/license contractını taşıyor.

### Açık / DONE değil

- [ ] Yeni timezone ve daily-date Dart testlerinin `Flutter Quality` SUCCESS kanıtı alınmalı.
- [ ] `Timezone Contract` latest exact commit SUCCESS kanıtı alınmalı.
- [ ] Dependency lock/checksum clean-checkout release zincirine bağlanmalı.
- [ ] Timezone dataset gerçek release hash/integrity kanıtı henüz yok.
- [ ] DailySnapshot’ın Moon/transit/planetary-hour/numerology faktörleri henüz yok; yalnız doğru günlük tarih partition temeli mevcut.

## Faz 7 — lokal şehir/koordinat/timezone katalog temeli

### Uygulanmış / source-level

- [x] `CityRecord` stable ID, canonical name, country, admin area, coordinate, IANA timezone ve aliases alanlarıyla eklendi.
- [x] `CityCatalog` tamamen lokal/deterministic search çekirdeği eklendi.
- [x] Türkçe diacritics normalization ve `İstanbul/Istanbul` eşleşme testi mevcut.
- [x] Alias araması canonical display adını değiştirmeden çalışacak şekilde test edildi.
- [x] Aynı isimli `Springfield` kayıtlarının admin-area/country ile ayrı kalması test edildi.
- [x] Coordinate range ve duplicate ID reddi mevcut.
- [x] `requirements/data_manifests/cities.json` kaynak/lisans/offline-generation sözleşmesi eklendi.
- [x] `City Catalog Contract` structural CI workflow’u eklendi.

### Açık / DONE değil

- [ ] Gerçek şehir dataset dosyaları henüz repository’ye üretilip bundle edilmedi.
- [ ] Kaynak artifact SHA-256 değerleri henüz kaydedilmedi.
- [ ] Generated catalog SHA-256 henüz yok.
- [ ] Attribution ekranı/metni henüz UI’a bağlanmadı.
- [ ] Büyük katalog search/performance testi henüz yok.
- [ ] Gerçek katalog timezone ID’lerinin bundled IANA database’e karşı toplu doğrulaması henüz yok.
- [ ] City Catalog Contract ve Flutter Quality latest exact commit SUCCESS kanıtı alınmalı.

## UI reference dosyaları

- Aktif automation workspace içinde önceki tasarım turundan 9 adet 863×1822 PNG hâlâ mevcut: Bugün, Batı giriş, Batı chart, Vedik, Numeroloji, Spiritüel, Danışanlar, Ayarlar ve PDF önizleme.
- PNG SHA-256 değerleri local olarak çıkarıldı ancak binary dosyalar henüz repository’ye bağlanmadı; bu nedenle `ui/reference_manifest.csv` satırları APPROVED yapılmadı.
- Gezegen Saatleri reference PNG’si aktif `/mnt/data` setinde bulunmuyor; yeniden üretim/onay gerekecek.
- Kullanıcının açık UI şartı gereği gerçek uygulama ekranları reference asset olmadan “benzer” kabul edilmeyecek.

## Faz 1 — binary blocker

- [ ] AKİLES V96 Final 28 ZIP exact SHA-256 manifesti — binary paket repository/aktif automation workspace içinde yok.
- [ ] Exact aktif JS/CSS/ephemeris/timezone envanteri — ZIP gerekir.
- [ ] 25.000+ Vedik dataset fiziksel reference-test formatı — ZIP/dataset gerekir.
- [ ] 6.400+ planetary-hour dataset fiziksel reference-test formatı — ZIP/dataset gerekir.

## Sıradaki çalışma

1. Latest exact commit üzerinde `Flutter Quality`, `Timezone Contract`, `City Catalog Contract`, `Architecture Contract`, `UI Contracts` ve `Requirements Contract` sonucunu doğrula; kırmızıysa aynı turda log/kod hatasını düzelt.
2. Gerçek şehir dataset generator/importer aracını ekle; source checksum + generated checksum manifestini üretilebilir hale getir.
3. City catalog timezone IDs × bundled IANA toplu integrity testini ekle.
4. DailySnapshot modelini date partition üzerine kur; astronomik faktörler calculation core tamamlanmadan uydurulmayacak.
5. Standard Flutter Android/iOS platform klasörlerini yalnız gerçek Flutter generator ile üret; elle sahte generated proje oluşturma.
6. UI reference PNG’lerini repository binary asset olarak bağlayabildiğimiz yolda ekran-ID/hash manifestine işle; açık kullanıcı onayı olmadan APPROVED yapma.
7. Faz 1 binary blocker sürüyorsa açık bırak; golden dataset iddiası yapma.

## Final durumu

**FINAL DEĞİL.** Bu turda timezone/DST çözümleme, günlük timezone-aware date partition, typed transactional repository registry/testleri ve offline city-search çekirdeği ilerletildi. Bunların gerçek Flutter/Actions SUCCESS kanıtları, gerçek bundled şehir verisi, astronomik motorlar, UI reference assetleri ve diğer master fazlar tamamlanmadan ilgili requirement’lar DONE sayılmayacak.
