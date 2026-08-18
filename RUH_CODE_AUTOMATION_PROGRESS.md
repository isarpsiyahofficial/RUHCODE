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

## Faz 7 — lokal şehir/koordinat/timezone katalog temeli

### Uygulanmış / source-level

- [x] `CityRecord` stable ID, canonical name, country, admin area, coordinate, IANA timezone ve aliases alanlarıyla eklendi.
- [x] `CityCatalog` tamamen lokal/deterministic search çekirdeği eklendi.
- [x] Türkçe diacritics normalization ve `İstanbul/Istanbul` eşleşme testi mevcut.
- [x] Alias araması canonical display adını değiştirmeden çalışacak şekilde test edildi.
- [x] Aynı isimli `Springfield` kayıtlarının admin-area/country ile ayrı kalması test edildi.
- [x] Coordinate range ve duplicate ID reddi mevcut.
- [x] GeoNames kaynak/lisans/offline-generation sözleşmesi `requirements/data_manifests/cities.json` içinde mevcut.
- [x] `tools/location/build_city_catalog.py` kaynak ZIP/TXT dosyalarından deterministic UTF-8 katalog üretir.
- [x] Builder kaynak artifact SHA-256 ve generated catalog SHA-256 değerlerini output manifestine yazar.
- [x] Builder için deterministic fixture testi ve invalid-ZIP testi mevcut.
- [x] `City Catalog Contract` structural CI workflow’u builder testini de çalıştıracak şekilde genişletildi.

### Açık / DONE değil

- [ ] Gerçek GeoNames şehir dataset dosyaları henüz repository’ye üretilip bundle edilmedi.
- [ ] Gerçek kaynak artifact SHA-256 değerleri henüz kaydedilmedi.
- [ ] Gerçek generated catalog SHA-256 henüz yok.
- [ ] Attribution ekranı/metni henüz UI’a bağlanmadı.
- [ ] Büyük katalog search/performance testi henüz yok.
- [ ] Gerçek katalog timezone ID’lerinin bundled IANA database’e karşı toplu doğrulaması henüz yok.
- [ ] City Catalog Contract ve Flutter Quality latest exact commit SUCCESS kanıtı alınmalı.

## DailySnapshot kimlik/cache temeli

### Uygulanmış / source-level

- [x] `DailySnapshotIdentity` profile + exact civil date + IANA timezone + coordinate + engineVersion + timezoneDatabaseVersion alanlarıyla eklendi.
- [x] Cache key aynı gün/ay farklı yıl arasında farklıdır.
- [x] Timezone, profile, location, engine version ve timezone database version cache identity’nin parçasıdır.
- [x] Leap-day snapshot key testi mevcut.
- [x] Daily factor sonuçları uydurulmuyor; yalnız ilgili source engine/result provenance referansı tutuluyor.
- [x] `Daily Snapshot Contract` structural CI kapısı eklendi.

### Açık / DONE değil

- [ ] Moon sign/phase gerçek astronomik motor sonucu olarak bağlanmalı.
- [ ] Transit faktörleri gerçek Batı motorundan gelmeli.
- [ ] Planetary hour faktörü gerçek planetary-hours motorundan gelmeli.
- [ ] Personal Day gerçek numeroloji motorundan gelmeli.
- [ ] Vedik günlük göstergeler gerçek Vedik motorundan gelmeli.
- [ ] DailySnapshot Dart testleri Flutter Quality’de SUCCESS kanıtı almalı.

## Günün Mesajı — exact-date stok sistemi

### Uygulanmış / source-level

- [x] `DailyMessageEntry` exact `CivilDate + locale` modeli eklendi.
- [x] `DailyMessageCatalog` lookup key `YYYY-MM-DD|locale`; random fallback yok.
- [x] Aynı exact date+locale duplicate kaydı runtime catalog tarafından reddediliyor.
- [x] Eksik exact date fallback yerine açık missing-state üretir.
- [x] 2028-02-29 exact TR/EN lookup testi mevcut.
- [x] Yalnız TR/EN locale sözleşmesi runtime modelde korunuyor.
- [x] Boş title/teaser/fullText/themeTag reddediliyor.
- [x] `requirements/content_manifests/daily_messages.json` başlangıç hedefini 2026-01-01→2036-12-31 = 4.018 gün ve 8.036 TR+EN kayıt olarak kilitliyor.
- [x] Manifest 2028/2032/2036 leap-date zorunluluğunu ve her release’de en az 10 yıllık rolling horizon politikasını içeriyor.
- [x] Runtime AI üretimi, random fallback ve TR↔EN machine translation manifestte yasak.
- [x] `tools/content/validate_daily_message_catalog.py` gelecekteki gerçek kataloğu exact key, missing/duplicate date, non-empty fields, exact duplicate text, repeated openings, leap dates ve SHA-256 açısından denetleyecek.
- [x] Catalog auditor için küçük leap-date fixture testleri eklendi.
- [x] `Daily Message Contract` structural CI kapısı eklendi.

### Açık / DONE değil

- [ ] 4.018 Türkçe günlük mesajın gerçek editoryal içeriği henüz yok.
- [ ] 4.018 İngilizce günlük mesajın bağımsız gerçek editoryal içeriği henüz yok.
- [ ] Toplam 8.036 kaydın gerçek catalog dosyası henüz yok.
- [ ] Near-duplicate semantic review otomasyonu/manual editorial QA henüz tamamlanmadı.
- [ ] Tekrarlayan yapay kalıp yoğunluğu için nihai kalite eşiği henüz gerçek katalog üzerinde çalıştırılmadı.
- [ ] Unsafe certainty / etik içerik incelemesi gerçek katalog üzerinde yapılmadı.
- [ ] Rolling 10-year release-horizon kontrolü gerçek release pipeline’a bağlanmadı.
- [ ] Daily Message Contract ve Flutter Quality latest exact commit SUCCESS kanıtı alınmalı.

## UI reference dosyaları

- Aktif automation workspace içinde önceki tasarım turundan 9 adet 863×1822 PNG hâlâ mevcut: Bugün, Batı giriş, Batı chart, Vedik, Numeroloji, Spiritüel, Danışanlar, Ayarlar ve PDF önizleme.
- Eski PNG’ler alt menüde artık yasaklanan `Hesapla` öğesini içerdiği için güncel şartnameye göre APPROVED değildir; repository’ye authoritative reference olarak bağlanmayacak.
- Gezegen Saatleri güncel reference PNG’si aktif `/mnt/data` setinde bulunmuyor.
- Kullanıcının açık UI şartı gereği gerçek uygulama ekranları güncel reference asset olmadan “benzer” kabul edilmeyecek.

## Faz 1 — binary blocker

- [ ] AKİLES V96 Final 28 ZIP exact SHA-256 manifesti — binary paket repository/aktif automation workspace içinde yok.
- [ ] Exact aktif JS/CSS/ephemeris/timezone envanteri — ZIP gerekir.
- [ ] 25.000+ Vedik dataset fiziksel reference-test formatı — ZIP/dataset gerekir.
- [ ] 6.400+ planetary-hour dataset fiziksel reference-test formatı — ZIP/dataset gerekir.
- [x] File Library’deki AKİLES V96 uygulama raporu referans davranışları (global yer, IANA timezone, historical conversion, Lahiri, Whole Sign, Rahu/Ketu, Nakshatra/pada, unknown-time) teyit etmek için bulundu; ancak binary/golden dataset yerine geçmedi.

## Sıradaki çalışma

1. Latest exact commit üzerinde `Flutter Quality`, `Timezone Contract`, `City Catalog Contract`, `Daily Snapshot Contract`, `Daily Message Contract`, `Architecture Contract`, `UI Contracts` ve `Requirements Contract` sonucunu doğrula; kırmızıysa aynı turda log/kod hatasını düzelt.
2. Gerçek şehir dataset source artifact’lerini güvenli biçimde alıp builder ile katalog + gerçek SHA-256 manifest üret; timezone IDs × bundled IANA toplu integrity testini ekle.
3. Günün Mesajı için gerçek 8.036 kayıt üretim/editoryal QA çalışma zincirini kur; içerik dolmadan catalog requirement’larını DONE yapma.
4. Ortak astronomik calculation core’a geçmeden önce AKİLES binary/golden blocker’ı yeniden ara; bulunmazsa bağımsız doğrulanabilir astronomik referans dataset stratejisini oluştur.
5. Standard Flutter Android/iOS platform klasörlerini yalnız gerçek Flutter generator ile üret; elle sahte generated proje oluşturma.
6. Güncel `Bugün · Araçlar · Kayıtlar · Profil` UI referansları üretilebilir hale geldiğinde yeni PNG/SVG referanslarını SCREEN-ID/hash manifestine bağla; eski `Hesapla` görsellerini onaylama.
7. Requirement state’e yalnız gerçek workflow/test/evidence kanıtı alınan RC’leri yükselt; source-level iş için DONE yazma.

## Final durumu

**FINAL DEĞİL.** Bu tura kadar timezone/DST çözümleme, timezone-aware daily-date partition, typed transactional persistence, offline city-search + deterministic dataset builder, DailySnapshot identity/provenance ve exact-date Günün Mesajı catalog/auditor altyapısı repository’ye işlendi. Gerçek CI SUCCESS kanıtları, gerçek şehir/message datasetleri, astronomik motorlar, güncel UI reference assetleri ve sonraki master fazlar tamamlanmadan ilgili requirement’lar DONE sayılmayacak.
