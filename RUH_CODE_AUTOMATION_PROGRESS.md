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
- [x] `JsonRecordRepository<T>` save/find/delete, atomic ID replacement ve injected-failure rollback testleri mevcut.
- [x] `CoreRepositories` typed registry mevcut.
- [x] Phase-5 architecture validator typed repository ve rollback testlerini zorunlu kılıyor.

### Açık / DONE değil

- [ ] Persistence değişikliklerinin `Flutter Quality` SUCCESS kanıtı alınmalı.
- [ ] Architecture/UI/Requirements contract kapıları latest exact commit üzerinde SUCCESS kanıtına bağlanmalı.
- [ ] Standart Flutter Android/iOS generated project klasörleri henüz yok.
- [ ] Android release/signing yapılandırması henüz yok.
- [ ] Gerçek Android cihaz/emülatör SQLite smoke testi henüz yok.
- [ ] Büyük veri/performance persistence testleri henüz yok.

## Faz 6 — Gregorian calendar + daily date

### Uygulanmış / source-level

- [x] Strict `CivilDate` ve destek aralığı `1890–2110` mevcut.
- [x] Gregorian `%400/%100/%4` artık yıl kuralları mevcut.
- [x] 1900 non-leap, 2000 leap, 2028/2032/2036 leap ve 2100 non-leap testleri mevcut.
- [x] 28→29 Şubat→1 Mart ve normal 28 Şubat→1 Mart geçiş testleri mevcut.
- [x] Locale/timezone bağımsız `YYYY-MM-DD` exact-date key ve ISO weekday mevcut.
- [x] `16.08.2026` ile `16.08.2027` ayrı tarih/weekday olarak test ediliyor.
- [x] `DailyDateContext` exact dateKey + timezone cache partition key üretiyor.
- [x] İstanbul local-midnight rollover, farklı yıl ayrımı ve 2028-02-29 testleri mevcut.

## Faz 7 — IANA timezone + şehir/konum temeli

### Uygulanmış / source-level

- [x] `timezone ^0.11.1` ve `flutter_timezone ^5.1.0` bağımlılıkları mevcut.
- [x] `TimeZoneRuntime` bundled `latest_all` IANA verisini kullanıyor.
- [x] Runtime timezone dataset sürümü `2025c` manifest/sözleşmesinde kayıtlı.
- [x] App startup timezone database initialize ediyor.
- [x] Ambiguous-time politikaları `earlier / later / reject`; nonexistent-time politikaları `reject / shiftForward`.
- [x] Half-hour `Asia/Kolkata`, 45-minute `Asia/Kathmandu`, UTC+14 `Pacific/Kiritimati`, date-line, New York overlap/gap ve Apia skipped-day testleri mevcut.
- [x] `FlutterDeviceTimeZoneProvider` platform IANA identifier’ını bundled database’e karşı doğruluyor.
- [x] `Timezone Contract` structural CI kapısı ve `requirements/data_manifests/timezone.json` mevcut.
- [x] `CityRecord` stable ID, canonical name, country, admin area, coordinate, IANA timezone ve aliases alanlarıyla mevcut.
- [x] `CityCatalog` tamamen lokal/deterministic search çekirdeği mevcut.
- [x] Türkçe diacritics normalization, alias ve aynı isimli şehir ayrımı testleri mevcut.
- [x] GeoNames kaynak/lisans/offline-generation sözleşmesi `requirements/data_manifests/cities.json` içinde mevcut.
- [x] `tools/location/build_city_catalog.py` deterministic katalog üretip source/generated SHA-256 hesaplıyor.
- [x] Builder fixture/invalid-ZIP testleri ve `City Catalog Contract` mevcut.
- [x] Büyük 193MB alternate-name kaynağını zorunlu tutmayan compact-source policy source-level eklendi.

### Açık / DONE değil

- [ ] Timezone / City Catalog / Flutter Quality latest exact commit SUCCESS kanıtları alınmalı.
- [ ] Dependency lock/checksum clean-checkout zincirine bağlanmalı.
- [ ] Timezone dataset gerçek release hash/integrity kanıtı henüz yok.
- [ ] Gerçek GeoNames dataset artifact’i bundle edilmedi; gerçek source/generated SHA-256 yok.
- [ ] Attribution UI’a bağlanmadı.
- [ ] Büyük katalog search/performance testi ve tüm timezone ID toplu integrity testi açık.

## DailySnapshot kimlik/cache temeli

### Uygulanmış / source-level

- [x] `DailySnapshotIdentity` profile + exact civil date + IANA timezone + coordinate + engineVersion + timezoneDatabaseVersion alanlarıyla mevcut.
- [x] Cache identity yıl/timezone/profile/location/engine/timezone-db değişimlerini ayırıyor ve leap-day testine sahip.
- [x] Daily factor sonuçları uydurulmuyor; yalnız source engine/result provenance referansı tutuluyor.
- [x] `Daily Snapshot Contract` structural CI kapısı mevcut.

### Açık / DONE değil

- [ ] Moon sign/phase gerçek astronomik motor sonucu olarak bağlanmalı.
- [ ] Transit faktörleri gerçek Batı motorundan gelmeli.
- [ ] Planetary hour gerçek planetary-hours motorundan gelmeli.
- [ ] Personal Day gerçek numeroloji motorundan gelmeli.
- [ ] Vedik günlük göstergeler gerçek Vedik motorundan gelmeli.
- [ ] DailySnapshot Dart testleri Flutter Quality’de SUCCESS kanıtı almalı.

## Günün Mesajı — exact-date stok sistemi

### Uygulanmış / source-level

- [x] `DailyMessageEntry` exact `CivilDate + locale` modeli ve deterministic `YYYY-MM-DD|locale` lookup mevcut; random fallback yok.
- [x] Duplicate exact key ve boş title/teaser/fullText/themeTag reddediliyor; missing date açık missing-state üretir.
- [x] 2028-02-29 exact TR/EN lookup testi mevcut.
- [x] `requirements/content_manifests/daily_messages.json` 2026-01-01→2036-12-31 = 4.018 gün / 8.036 TR+EN kayıt hedefini ve rolling >=10-year horizon politikasını kilitliyor.
- [x] Runtime AI, random fallback ve TR↔EN machine translation yasak.
- [x] `validate_daily_message_catalog.py`, fixture testleri ve `Daily Message Contract` mevcut.

### Açık / DONE değil

- [ ] 4.018 Türkçe ve bağımsız 4.018 İngilizce gerçek editoryal mesaj henüz yok.
- [ ] Gerçek 8.036 kayıt catalog dosyası yok.
- [ ] Near-duplicate/manual editorial QA, artificial-pattern density ve unsafe-certainty review gerçek katalog üzerinde açık.
- [ ] Rolling horizon gerçek release pipeline’a bağlanmalı.
- [ ] Daily Message Contract / Flutter Quality exact-commit SUCCESS kanıtı alınmalı.

## Faz 8 — ortak astronomik zaman temeli

### Uygulanmış / source-level

- [x] `JulianDay` eklendi: Gregorian CivilDate/UTC → JD, MJD ve J2000 centuries fonksiyonları mevcut.
- [x] USNO referans değerleriyle Julian Day testleri mevcut.
- [x] USNO Julian Day referans manifesti, validator ve `Julian Day Contract` CI workflow’u mevcut.
- [x] `UtcTaiOffsetTable` ile 1972 sonrası leap-second segmentleri explicit modelleniyor.
- [x] `TimeScales.ttMinusTaiSeconds = 32.184` ve UTC→TAI→TT Julian Day dönüşümü mevcut.
- [x] Pre-1972 UTC için sahte offset üretilmiyor; explicit reject uygulanıyor.
- [x] Gelecekteki leap-second kararları uydurulmuyor. IERS Bulletin C 72 nedeniyle built-in coverage `UTC < 2027-07-01T00:00:00Z` ile sınırlı.
- [x] 1972/2000/2017/2026 offset testleri ve USNO J2000 TT epoch testi mevcut.
- [x] IAU SOFA + USNO + IERS kaynaklı `requirements/reference_manifests/time_scales.json`, validator ve `Time Scales Contract` workflow’u mevcut.
- [x] `SiderealTime.greenwichMeanHours` ile JD_UT1 ve JD_TT’yi ayrı input alan USNO approximate GMST hesabı eklendi.
- [x] GMST J2000 noon/midnight, normalization ve degree conversion testleri mevcut.
- [x] USNO sidereal reference manifesti, validator ve `Sidereal Time Contract` workflow’u mevcut.
- [x] UTC, UT1 ve TT aynı zaman ölçeğiymiş gibi birleştirilmiyor; yüksek hassasiyetli apparent sidereal time iddiası yapılmıyor.

### Açık / DONE değil

- [ ] Yeni `Time Scales`, `Julian Day` ve `Sidereal Time` Dart testlerinin gerçek Flutter Quality SUCCESS kanıtı alınmalı.
- [ ] Yeni Python contract workflow’larının exact latest commit SUCCESS kanıtı alınmalı.
- [ ] UT1-UTC/EOP veri stratejisi ve release manifesti oluşturulmalı; GMST için UTC’nin UT1 yerine sessizce kullanılması yasak kalmalı.
- [ ] Pre-1972 zaman ölçeği/Delta-T stratejisi onaylanmadan 1890–1971 aralığında TT/UT1 hassasiyeti DONE sayılamaz.
- [ ] Ephemeris/data lisans ve runtime stratejisi kesinleşmeli.
- [ ] Güneş/Ay/gezegen konumları, retrograde, sunrise/sunset ve Ay fazı henüz uygulanmadı.
- [ ] Hard accuracy budgetları ve independent golden cross-check henüz tamamlanmadı.

## UI reference dosyaları

- Önceki tasarım turundaki 9 adet 863×1822 PNG `Hesapla` alt menüsünü içerdiği için yeni `Bugün · Araçlar · Kayıtlar · Profil` şartına göre APPROVED değildir.
- Gezegen Saatleri güncel reference PNG’si de authoritative set içinde yok.
- Güncel UI görselleri üretilip SCREEN-ID/hash manifestine bağlanmadan gerçek uygulama ekranları “benzer” diye DONE yapılmayacak.

## Faz 1 — binary blocker

- [ ] AKİLES V96 Final 28 ZIP exact SHA-256 manifesti — binary paket repository/aktif automation workspace içinde yok.
- [ ] Exact aktif JS/CSS/ephemeris/timezone envanteri — ZIP gerekir.
- [ ] 25.000+ Vedik dataset fiziksel reference-test formatı — ZIP/dataset gerekir.
- [ ] 6.400+ planetary-hour dataset fiziksel reference-test formatı — ZIP/dataset gerekir.
- [x] AKİLES uygulama raporu davranış referansı olarak bulundu; binary/golden dataset yerine geçmedi.

## Bu turun doğrulama notu

- GitHub repository’ye kaynak, test, reference manifest, validator ve workflow commitleri gerçekten yazıldı.
- Automation runtime container’ından public GitHub DNS erişimi olmadığı için temiz `git clone` ile local validator/Flutter çalıştırma girişimi ağ seviyesinde başarısız oldu; bu bir ürün testi SUCCESS kanıtı olarak sayılmadı.
- GitHub push workflow’larının SUCCESS sonucu connector üzerinden bu turda henüz elde edilemedi. Bu nedenle ilgili RC/TODO maddeleri source-level ilerledi fakat DONE’a yükseltilmedi.

## Sıradaki çalışma

1. Latest exact commit üzerinde `Flutter Quality`, `Time Scales Contract`, `Julian Day Contract`, `Sidereal Time Contract`, `Timezone Contract`, `City Catalog Contract`, `Daily Snapshot Contract`, `Daily Message Contract`, `Architecture Contract`, `UI Contracts` ve `Requirements Contract` kanıtını doğrula; kırmızıysa aynı turda düzelt.
2. UT1-UTC/EOP için offline/versioned kaynak + coverage manifest stratejisini kur; tahmin/uydurma yapma.
3. Ephemeris runtime/lisans stratejisini independent primary/reference kaynaklarla kesinleştir; AKİLES binary bulunursa hash ve golden dataset’i ayrıca içeri al.
4. Gerçek şehir dataset artifact + generated compact catalog ve timezone-ID toplu doğrulamayı tamamla.
5. Günün Mesajı 8.036 gerçek editoryal kayıt üretim/QA zincirini ilerlet.
6. Standard Flutter Android/iOS generated platformlarını yalnız gerçek Flutter generator ile üret.
7. Güncel `Bugün · Araçlar · Kayıtlar · Profil` UI reference seti oluşturulduğunda SCREEN-ID/hash manifestine bağla.
8. Requirement state’e yalnız gerçek workflow/test/evidence kanıtı alınan RC’leri yükselt.

## Final durumu

**FINAL DEĞİL.** Astronomik zaman altyapısı artık Julian Day + explicit UTC/TAI/TT + UT1/TT ayrımlı GMST seviyesine ilerledi; fakat gerçek CI kanıtları, UT1/EOP stratejisi, ephemeris/gezegen hesapları, gerçek şehir/message datasetleri, güncel UI reference assetleri ve sonraki master fazlar tamamlanmadan ilgili requirement’lar DONE sayılmayacak.
