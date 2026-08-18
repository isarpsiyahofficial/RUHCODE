# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında kaldığı yeri kaybetmemek için tutulur. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. Bu dosyadaki `source-level` kayıtları DONE anlamına gelmez; yalnız test/workflow/evidence kapıları geçen RC maddeleri requirement state içinde yükseltilebilir.

## Son doğrulanmış kapsam

- MASTER kapsamı: `RC-0001 → RC-1442`.
- Faz 0 tamamlandı: 1.442 RC ID, deterministic classification, task/evidence sözleşmesi ve kanıtsız DONE yasağı mevcut.
- Faz 1 kısmi: AKİLES referans/runtime sınırı belgelendi; binary ZIP gerektiren exact hash, aktif JS/CSS/ephemeris/timezone envanteri ve 25.000+/6.400+ dataset dönüştürmeleri açık.
- Faz 2: `Bugün · Araçlar · Kayıtlar · Profil`, 106 SCREEN-ID ve ACTION-ID sözleşmesi mevcut.
- Faz 3: 106/106 structural UI reference/state tracking, action registry, static asset manifest ve dynamic geometry contract mevcut; güncel APPROVED PNG seti henüz yok.
- Faz 4: warm ivory `#FBF8F3`, primary purple `#4C2A91`, strong purple `#6B42E6`, gold `#C89338`, spacing/radius/typography/navigation/touch-target structural design sözleşmeleri mevcut.

## Faz 5 — persistence

### Uygulanmış / source-level
- [x] Flutter package/entrypoint ve dört ana navigation destination.
- [x] Platform bağımsız domain + UUID sözleşmesi.
- [x] calculation_core / interpretation / data / ui / pdf / backup / entitlements sınırları.
- [x] Transaction/migration/integrity-check DB portu, SQLite adapter, schema-v1 ve FFI rollback/integrity testleri.
- [x] Core domain codec/round-trip testleri.
- [x] Generic transactional `JsonRecordRepository<T>` ve typed `CoreRepositories` registry.

### Açık / DONE değil
- [ ] Flutter Quality + Architecture/UI/Requirements exact-commit SUCCESS kanıtları.
- [ ] Standard Flutter Android/iOS generated project klasörleri.
- [ ] Android release/signing.
- [ ] Gerçek cihaz/emülatör SQLite smoke ve büyük-data performance testleri.

## Faz 6 — Gregorian calendar + daily date

### Uygulanmış / source-level
- [x] Strict `CivilDate`, destek aralığı `1890–2110`.
- [x] Gregorian `%400/%100/%4`; 1900/2000/2028/2032/2036/2100 sınır testleri.
- [x] 28→29 Şubat→1 Mart ve normal 28 Şubat→1 Mart.
- [x] Locale/timezone bağımsız `YYYY-MM-DD` key + ISO weekday.
- [x] 16.08.2026 / 16.08.2027 bağımsız test.
- [x] `DailyDateContext`, local-midnight rollover, year partition ve leap-day testleri.

## Faz 7 — IANA timezone + şehir/konum

### Uygulanmış / source-level
- [x] `timezone` + `flutter_timezone`, bundled `latest_all`, version `2025c` manifesti.
- [x] Explicit ambiguous/nonexistent-time policies.
- [x] Kolkata/Kathmandu/Kiritimati/date-line/New York DST/Apia skipped-day testleri.
- [x] Platform IANA identifier doğrulaması ve Timezone Contract.
- [x] `CityRecord` + offline deterministic `CityCatalog`.
- [x] Türkçe diacritics/alias/same-name-city testleri.
- [x] GeoNames kaynak/lisans manifesti ve deterministic compact catalog builder.
- [x] Builder source/generated SHA üretimi, fixture/invalid ZIP testleri ve City Catalog Contract.

### Açık / DONE değil
- [ ] Timezone / City Catalog / Flutter Quality exact-commit SUCCESS kanıtları.
- [ ] Dependency lock/checksum clean-checkout zinciri.
- [ ] Timezone release hash/integrity.
- [ ] Gerçek GeoNames source artifact + generated catalog + gerçek SHA-256.
- [ ] Attribution UI, büyük katalog performance ve toplu timezone-ID integrity.

## DailySnapshot

### Uygulanmış / source-level
- [x] `DailySnapshotIdentity` profile + exact date + IANA zone + coordinate + engineVersion + tzDatabaseVersion.
- [x] Cache partition testleri ve provenance-only factor modeli.
- [x] Daily Snapshot Contract.
- [x] Gerçek `PlanetaryHours` motoru için `PlanetaryHourDailyFactor` bağlandı.
- [x] Civil midnight ile planetary-day sunrise sınırı karıştırılmıyor; 00:00→sunrise aralığında önceki planetary day slotu aranıyor.
- [x] `MoonPhaseDailyFactor` strict `EphemerisProvider` üstünden bağlandı; result ID phase + angle + illumination + source/version provenance taşıyor.

### Açık / DONE değil
- [ ] Moon sign gerçek motor bağlantısı.
- [ ] Moon phase physical ephemeris + independent accuracy kanıtı.
- [ ] Transit gerçek motor bağlantısı.
- [ ] Personal Day gerçek motor bağlantısı.
- [ ] Vedik günlük faktörler gerçek motor bağlantısı.
- [ ] Flutter Quality SUCCESS kanıtı.

## Günün Mesajı

### Uygulanmış / source-level
- [x] Exact `CivilDate + locale` model, deterministic `YYYY-MM-DD|locale`, no random fallback.
- [x] Duplicate/missing/non-empty/leap-date kontrolleri.
- [x] 2026-01-01→2036-12-31 = 4.018 gün / 8.036 TR+EN manifest ve rolling >=10-year horizon.
- [x] Runtime AI, random fallback ve TR↔EN machine translation yasak.
- [x] Catalog validator + fixture tests + Daily Message Contract.

### Açık / DONE değil
- [ ] Gerçek 4.018 TR + bağımsız 4.018 EN editoryal içerik.
- [ ] Near-duplicate/manual QA, artificial-pattern density, unsafe-certainty review ve release-horizon gate.

## Faz 8 — ortak astronomik calculation core / zaman tabanı

### Uygulanmış / source-level
- [x] `JulianDay`: CivilDate/UTC → JD, MJD, J2000 centuries.
- [x] UTC/TAI/TT ayrımı; explicit leap-second coverage ve pre-1972 reject.
- [x] `SiderealTime.greenwichMeanHours`: JD_UT1 ve JD_TT explicit input.
- [x] `EarthOrientationProvider`; UT1−UTC explicit versioned provenance ile zorunlu.
- [x] `AstronomicalTimeContext` UTC, JD_UTC, JD_TT ve JD_UT1 değerlerini ayrı tutar.
- [x] Strict `EphemerisProvider`: Sun/Moon/planets/nodes; TT coverage + source/version/SHA; network/nearest-date/zero fallback yok.
- [x] Deterministic solar-event alt motoru, polar unavailable state ve reference contract.
- [x] Gerçek 12 gündüz + 12 gece planetary-hours motoru ve DailySnapshot binding.

### Moon phase — son tur
- [x] `MoonPhaseEngine` eklendi.
- [x] Phase angle `normalize(Moon longitude − Sun longitude)` üzerinden hesaplanıyor.
- [x] Illuminated fraction `(1 − cos(angle))/2` üzerinden hesaplanıyor.
- [x] 8 faz sınıfı deterministic boundary’lerle ayrılıyor.
- [x] Sun/Moon exact aynı `jdTt` örneği olmak zorunda.
- [x] Sun/Moon `sourceId` ve `dataVersion` aynı olmak zorunda; karışık provenance reject.
- [x] Wraparound, canonical new/quarter/full/last-quarter ve mixed-provenance unit testleri eklendi.
- [x] `MoonPhaseDailyFactor` DailySnapshot’a bağlandı ve unit testi eklendi.
- [x] `moon_phase_runtime.json`, structural validator ve `Moon Phase Contract` workflow’u eklendi.
- [ ] Fiziksel, lisanslı offline ephemeris dataset henüz yok; manifest bunu `false` tutuyor.
- [ ] Independent physical moon-phase accuracy suite henüz yok.
- [ ] Exact commit CI SUCCESS kanıtı henüz görünür değil; requirement DONE yükseltilmedi.

## Gezegen Saatleri

### Uygulanmış / source-level
- [x] Classical Chaldean order: Saturn → Jupiter → Mars → Sun → Venus → Mercury → Moon.
- [x] Weekday ruler gerçek `CivilWeekday` üzerinden hesaplanıyor.
- [x] Gündüz sunrise→sunset 12 eşit parça; gece sunset→next sunrise 12 eşit parça.
- [x] Polar-day/night fake sonuç yerine unavailable.
- [x] DailySnapshot planetary-hour entegrasyonu.

### Açık / DONE değil
- [ ] AKİLES fiziksel 6.400+ planetary-hour golden dataset.
- [ ] Global bağımsız accuracy/cross-check genişletmesi.
- [ ] Timezone-local UI ve notification entegrasyonu.
- [ ] Exact latest workflow SUCCESS kanıtları.

## Faz 8 açık kalan ana işler

- [ ] Latest exact commit üzerinde Flutter Quality ve bütün contract SUCCESS kanıtları.
- [ ] Packaged/versioned offline EOP/UT1−UTC dataset + coverage + checksum.
- [ ] Pre-1972 zaman ölçeği/Delta-T yaklaşımı; 1890–1971 hassas zaman hesapları.
- [ ] Fiziksel, ticari yeniden dağıtıma uygun ephemeris runtime dataset/lisans/version/checksum.
- [ ] Gerçek Sun/Moon/planet/node state runtime.
- [ ] Hard accuracy budgets + bağımsız golden cross-check.
- [ ] Moon sign gerçek ephemeris bağlantısı.

## UI reference durumu

- Önceki 9 UI PNG’si yasaklanan `Hesapla` alt menüsünü içerdiği için APPROVED değildir.
- Authoritative Gezegen Saatleri güncel reference setinde yok.
- Yeni `Bugün · Araçlar · Kayıtlar · Profil` referansları SCREEN-ID/hash manifestine bağlanmadan UI DONE yapılmayacak.

## Faz 1 — binary blocker

- [ ] AKİLES V96 Final 28 ZIP exact SHA-256 manifesti — binary paket repo/automation workspace içinde yok.
- [ ] Exact aktif JS/CSS/ephemeris/timezone envanteri.
- [ ] 25.000+ Vedik ve 6.400+ planetary-hour fiziksel golden dataset.
- [x] AKİLES raporu davranış referansı olarak bulundu; binary/golden dataset yerine geçmiyor.

## Son çalışma doğrulama notu

- Moon phase source/test/manifest/validator/workflow değişiklikleri `aa5981065513982b74775e5b5e739505e03807ba` commit’inde `main` dalına işlendi.
- GitHub combined-status endpoint bu commit için status listesi döndürmedi; bu nedenle workflow SUCCESS kanıtı uydurulmadı.
- Automation runtime içinde Flutter/Dart executable bulunmadığından testler yerelde koşulamadı; CI contract sonucu gelmeden DONE yükseltilmedi.
- Fiziksel ephemeris blocker’ı Moon phase matematiğinin source-level ilerlemesini durdurmadı, ancak final accuracy/DONE kapısını açık bıraktı.

## Sıradaki çalışma

1. `aa598106...` sonrası latest exact commit üzerinde Moon Phase + Flutter Quality + astronomy contract sonuçlarını doğrula; kırmızıları aynı turda düzelt.
2. Packaged/versioned IERS EOP/UT1−UTC dataset loader + coverage/checksum zincirini fiziksel veriye bağla.
3. Ticari yeniden dağıtıma uygun offline ephemeris dataset stratejisini kesinleştir ve gerçek checksum/coverage ile bağla.
4. Gerçek Moon longitude üzerinden Moon sign factor’ünü bağla; tropical zodiac boundary testlerini ekle.
5. Personal Day motorunun Pythagorean reduction/master-number politikasını requirement sözleşmesiyle açıklaştırıp DailySnapshot’a bağla.
6. Gerçek GeoNames compact catalog + timezone-ID toplu integrity testini tamamla.
7. Günün Mesajı 8.036 gerçek editoryal kayıt üretim/QA zincirini ilerlet.
8. Standard Flutter Android/iOS platformlarını yalnız gerçek Flutter generator ile üret.
9. Güncel UI reference setini yeni alt navigasyonla üretip SCREEN-ID/hash manifestine bağla.
10. Requirement state’e yalnız workflow/test/evidence kanıtı alınan RC’leri yükselt.

## Final durumu

**FINAL DEĞİL.** Astronomik altyapı Moon phase hesaplaması ve DailySnapshot binding seviyesine ilerledi; fiziksel ephemeris/EOP verileri, gerçek city/message datasetleri, güncel UI referansları ve sonraki master fazlar tamamlanmadan ilgili requirement’lar DONE sayılmayacak.
