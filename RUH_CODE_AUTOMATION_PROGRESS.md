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

## Faz 5 — persistence durumu

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
- [x] Generic transactional `JsonRecordRepository<T>` source-level olarak eklendi; save/find/delete/atomic replace davranışları LocalDatabase transaction sınırı üzerinden çalışacak şekilde tanımlandı.

### Açık / DONE değil

- [ ] `Flutter Quality` latest exact commit SUCCESS kanıtı alınmalı; source ve test mevcut olsa da yeşil CI olmadan DONE sayılmayacak.
- [ ] `Architecture Contract`, `UI Contracts`, `Requirements Contract` latest exact commit üzerinde yeniden SUCCESS kanıtına bağlanmalı.
- [ ] `JsonRecordRepository<T>` için gerçek/fake DB integration testleri eklenmeli.
- [ ] Standart Flutter Android/iOS generated project klasörleri henüz yok.
- [ ] Android release/signing yapılandırması henüz yok.
- [ ] App-level typed repository/service katmanı henüz yok; generic transactional repository hazır.
- [ ] Future schema migration registry v1 sınırında; v1→v2 ancak schema v2 tanımlandığında gerçek veri dönüşümüyle eklenecek.
- [ ] Büyük veri/performance persistence testleri henüz yok.
- [ ] Gerçek Android cihaz/emülatör SQLite smoke testi henüz yok.

## Bu tur — Faz 6 Gregorian calendar core ilerlemesi

- [x] `CivilDate` strict date value object eklendi.
- [x] Desteklenen civil tarih aralığı `1890–2110` olarak kod seviyesinde kilitlendi.
- [x] Gregorian leap-year kuralları açık uygulandı: `%400`, `%100`, `%4` sırası.
- [x] Ay uzunlukları ve geçersiz tarih reddi eklendi.
- [x] Locale/timezone bağımsız `YYYY-MM-DD` exact-date anahtarı eklendi.
- [x] ISO weekday (`Monday=1 … Sunday=7`) sözleşmesi eklendi.
- [x] Civil date day-add ve day-difference yardımcıları eklendi.
- [x] 1900 non-leap, 2000 leap, 2028/2032/2036 leap ve 2100 non-leap testleri eklendi.
- [x] 28→29 Şubat→1 Mart ve normal 28 Şubat→1 Mart geçiş testleri eklendi.
- [x] `16.08.2026` ile `16.08.2027` ayrı tarih/weekday olarak golden unit contract içine alındı.
- [x] Exact ISO-key parse/round-trip ve locale-formatted date rejection testi eklendi.
- [x] `tools/time/validate_calendar_contract.py` structural contract validator eklendi.
- [x] `Calendar Contract` GitHub Actions workflow’u eklendi.

### Faz 6 açık / DONE değil

- [ ] `Calendar Contract` latest exact commit SUCCESS kanıtı alınmalı.
- [ ] `Flutter Quality` içinde yeni civil-calendar unit testlerinin gerçek SUCCESS kanıtı alınmalı.
- [ ] IANA timezone database/runtime katmanı henüz uygulanmadı.
- [ ] Historical DST ambiguity/nonexistent-time politikası henüz uygulanmadı.
- [ ] Half-hour, 45-minute, UTC+14 ve date-line timezone testleri henüz uygulanmadı.
- [ ] Gün sınırı / timezone-aware DailySnapshot tarihi henüz uygulanmadı.

## Faz 1 — binary blocker

- [ ] AKİLES V96 Final 28 ZIP exact SHA-256 manifesti — binary paket repository/aktif automation workspace içinde yok.
- [ ] Exact aktif JS/CSS/ephemeris/timezone envanteri — ZIP gerekir.
- [ ] 25.000+ Vedik dataset fiziksel reference-test formatı — ZIP/dataset gerekir.
- [ ] 6.400+ planetary-hour dataset fiziksel reference-test formatı — ZIP/dataset gerekir.

## Sıradaki çalışma

1. Latest exact commit üzerinde `Calendar Contract` ve `Flutter Quality` sonucunu doğrula; kırmızıysa log/kod hatasını düzelt.
2. Aynı exact commit zincirinde Architecture/UI/Requirements kapılarını doğrula.
3. `JsonRecordRepository<T>` integration testini ekle ve persistence repository katmanını typed service’lere genişlet.
4. Standard Flutter Android/iOS platform klasörlerini yalnız gerçek Flutter generator ile üret; elle sahte generated proje oluşturma.
5. Android SQLite smoke testi + release build kapısı ekle.
6. Faz 6’da IANA timezone + historical DST tasarımını ve lokal dataset sözleşmesini uygula.
7. Half-hour/45-minute/UTC+14/date-line timezone boundary suite ekle.
8. Faz 1 binary blocker sürüyorsa açık bırak; golden dataset iddiası yapma.

## Final durumu

**FINAL DEĞİL.** Gregorian civil calendar çekirdeği, leap-year/date/weekday/ISO-key testleri ve bağımsız Calendar Contract CI kapısı repository’ye eklendi. Ancak bu yeni kapıların gerçek SUCCESS kanıtı, timezone/DST katmanı, generated Android/iOS yapısı ve Faz 1 binary referansları tamamlanmadan ilgili fazlar DONE sayılmayacak.
