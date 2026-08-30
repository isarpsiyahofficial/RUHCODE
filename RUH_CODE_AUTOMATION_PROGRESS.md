# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** SOURCE_LEVEL_IMPLEMENTED / IMPLEMENTED, DONE değildir. DONE yalnız gerekli test, golden, cihaz ve release kanıtlarıyla verilir.

## Requirement durumu

- Exact kapsam: `RC-0001 → RC-1442`.
- Repository-wide evidence integrity, semantic ownership ve matrix provenance kapıları aktif.
- Calculation, UI, backup, PDF, entitlement ve content kanıtları eksik final doğrulamalarını atlayarak DONE üretemez.
- `requirements/requirement_state.csv` sparse explicit-override ledger'dır; full 1.442 satırlık matrix CI'da üretilir. Kanıtsız DONE/status override eklenmedi.

## Source-level ilerlemiş ana bloklar

- Gregorian calendar, leap-year, exact-date identity, timezone/UTC-TT-UT1 sınırları.
- Astronomi provider sözleşmeleri, solar events, Gezegen Saatleri, DailySnapshot faktörleri.
- Western temel motorları ve persisted natal snapshot/manifest.
- Numeroloji, BaZi primitives ve basic Çin Astrolojisi çekirdekleri.
- Entitlement Free/PRO guard ve offline state.
- 15 tablolu backup/restore, `.ruhcode.zip`, transaction/rollback ve native save/pick/share.
- Professional/combined PDF planning, persisted Western/Numerology projection, preview/build parity ve structural validation.
- UI action/accessibility kontratları.
- Daily-message deterministic shard + editorial ledger + partial QA hattı.
- Daily-message legacy source adapter: geçmiş 5-sütun shardlar canonical 6-sütun in-memory şemaya normalize edilir; yeni editorial batchler canonical yazılır.

## Günün Mesajı — doğrulanmış ledger

Başlangıç hedefi: **4.018 tarih × 2 bağımsız dil = 8.036 kayıt**.

- TR ledger: `2026-01-01 → 2035-06-30` = **3468**
- EN ledger: `2026-01-01 → 2035-06-30` = **3468**
- Ledger toplamı: **6936 / 8036**
- Ledger kalan: **1100**
- Ledger'ın sıradaki exact başlangıcı: **2035-07-01**

Haziran 2035 canonical shardları commit sonrası `main` üzerinden yeniden okunarak locale başına 30 exact tarih doğrulandıktan sonra ledger ileri taşındı.

## Bu turdaki doğrulama ve ilerleme

- Binding master TODO/index ve mevcut progress tekrar okundu; kapsamın `RC-0001 → RC-1442` olduğu yeniden doğrulandı.
- Önceki exact baseline HEAD `71829268300a5caa5b9e07a54255884f633098cf` için 23 workflow run bulundu; bunların 4 tanesi kırmızıydı: Flutter Quality, Requirements Contract, Western Aspect Grid Contract ve Western Natal Aspects Contract. Bu nedenle önceki görünür CI durumu SUCCESS olarak kabul edilmedi.
- `assets/content/daily_messages/tr/2035-06.csv` ve `assets/content/daily_messages/en/2035-06.csv` eklendi; iki shard commit sonrası `main` üzerinden yeniden okunarak `2035-06-01 → 2035-06-30` exact tarih dizisi ve canonical header doğrulandı.
- `evidence/content/daily_messages_editorial_progress.json` yalnız committed contiguous shard sınırına göre 6936/8036 seviyesine ilerletildi.
- Requirements Contract kök nedeni bulundu: evidence `sources` listesinde directory pathleri vardı; integrity validator yalnız repository file pathlerini kabul ediyor. Directory girdileri kaldırıldı ve file-resolvable kaynak sözleşmesi restore edildi.
- Western Aspect Grid ve Western Natal Aspects kırmızıları aynı runtime kök nedene bağlıydı: `AspectOrbPolicy` default `Map<MajorAspect,double>` içine integer literal yazıldığı için Dart runtime `int is not a subtype of double` hatası veriyordu. Default orb değerleri explicit double (`8.0/5.0/7.0/7.0/8.0`) yapıldı.
- Flutter Quality decoded logu incelendi. Eski baseline analyzer 55 issue ile kırmızıydı; bu turda Google Play lifetime ownership, rewarded temporary unlock ve combined professional PDF katmanlarındaki geçersiz `const StateError` kullanımları kaldırıldı.
- Flutter Quality'de backup test import driftleri, kalan PDF/UI const kullanımları, eski `CivilDate` test constructorları, PDF symbol importları ve fatal warning/info borcu tamamen kapanmış değildir; exact yeni CI kanıtı gelmeden bu kapı yeşil sayılmayacaktır.
- `RC-1424/1425/1426/1427/1433/1434` full catalog ve release kanıtları olmadığı için DONE yapılmadı.

## Açık ana blocker'lar

- En yeni exact HEAD üzerindeki GitHub Actions zorunlu contract sonuçlarının tamamlanmış görünür SUCCESS olması; özellikle Flutter Quality'nin kalan analyzer borcunun sıfırlanması
- remaining daily-message editorial kapsamı: TR+EN `2035-07-01 → 2036-12-31` ve ardından strict 8.036-record release audit
- versioned fiziksel IERS EOP + checksum/provenance
- yeniden dağıtıma uygun offline ephemeris + independent golden accuracy
- production Lahiri/Chitrapaksha ve GeoNames artifact kanıtı
- APPROVED UI reference/hash seti ve real-device accessibility/visual regression
- production Unicode PDF font + license/hash, full parser/open, rendered 5/25/50+ ve device delivery proof
- Play/rewarded gerçek cihaz kanıtı
- `pubspec.lock` gerçek dependency resolution sonrası
- clean-checkout/reproducible release APK
- airplane-mode + Golden Lifecycle + final 1.442 RC audit

## Son checkpoint

`automation_runs/2026-08-31_0056_june_2035_ci_repairs.md`

## Sıradaki çalışma

1. En yeni exact SHA workflow sonuçlarını tamamlanmış sonuçlarla yeniden oku; kalan Flutter Quality/Requirements/Western kırmızılarını decoded log üzerinden kök neden bazında kapat.
2. Flutter analyzer'daki backup/PDF/UI import ve constructor driftlerini temizleyip `flutter analyze --fatal-infos` + test kapısını exact CI ile doğrula.
3. Canonical editorial batchlere `2035-07-01` tarihinden devam et; TR ve EN tracklerini bağımsız tut.
4. Günün Mesajı kapsamını 2036-12-31'e kadar kesintisiz ilerlet; strict release completeness/quality auditini ancak 8.036 kayıt tamamlanınca çalıştırıp ilgili RC'leri kanıtla.
5. Fiziksel artifact/font/UI/device-test gerektiren maddelere kanıtsız DONE verme.

**FINAL: NO.**
