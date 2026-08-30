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

- TR ledger: `2026-01-01 → 2034-12-31` = **3287**
- EN ledger: `2026-01-01 → 2034-12-31` = **3287**
- Ledger toplamı: **6574 / 8036**
- Ledger kalan: **1462**
- Ledger'ın sıradaki exact başlangıcı: **2035-01-01**

Bu turda editorial ledger bilinçli olarak ileri taşınmadı; kritik kırmızı CI kapıları dependency önceliğiyle ele alındı.

## Bu turdaki doğrulama ve düzeltme durumu

- Önceki exact HEAD `7abc2f996cec40539bfcce2820e629a99f07a7b7` için gerçekte **23 GitHub Actions run** olduğu ve **8 workflow failure** bulunduğu doğrulandı. Önceki “workflow görünmüyor” varsayımı geçersizdir.
- Western Aspect Grid validator'ındaki yanlış RC sahipliği düzeltildi: aspect grid binding sahibi `RC-0051`; ilgisiz Free/product access `RC-0277/RC-0278` artık bu astronomy kanıt kapısına zorla bağlanmıyor.
- Western Essential Dignities validator'ındaki ilgisiz `RC-0276` bağı kaldırıldı; binding sahiplik `RC-0049/RC-0050` olarak korunuyor.
- Requirements Contract'ın evidence-integrity kırmızısının ilk kök nedeni giderildi: `evidence/backup/single_table_csv_export.json` canonical string `contract` id kullanıyor, boolean detaylar `assertions` altında korunuyor.
- `western/asc_mc.dart`, `vedic/ayanamsha.dart` ve `western/placidus_houses.dart` içinde güncel Dart'ın reddettiği `RangeError.range` double-bound çağrıları `RangeError.value` ile değiştirildi; fail-closed range davranışı korunuyor.
- Earth Orientation Contract'ın 8/9 test durumundaki tek hata, büyük Julian Day double'larının subtraction cancellation hassasiyetinden kaynaklanıyordu. Regression toleransı `2e-10` gün (~17 µs) seviyesine çekildi; UT1-UTC semantic doğrulaması korunuyor.
- Invalid `const StateError` kullanımları entitlement resolver, feature catalog ve rollback-resistant entitlement clock içinde kaldırıldı.
- Eski Flutter Quality logunda toplam **70 analyzer issue** görüldü. Bu tur ortak köklerin bir kısmını temizledi; kalan const/import/type/test-constructor/PDF/backup analyzer borcu çözülmeden CI yeşil sayılmayacak.
- Yeni exact commit zincirinde GitHub Actions tamamlanmadan `SUCCESS` verilmeyecek; queued/in-progress durum proof değildir.

## Açık ana blocker'lar

- Flutter Quality kalan analyzer/test borcu: invalid const exception kullanımları, backup/PDF symbol/import drift, eski `CivilDate` test construction ve analyzer warning/info kalıntıları
- Requirements Contract'ın sonraki evidence-integrity/matrix aşamalarının yeni exact SHA üzerinde tam SUCCESS kanıtı
- remaining daily-message editorial kapsamı: TR+EN `2035-01-01 → 2036-12-31` ve ardından strict 8.036-record release audit
- exact HEAD üzerindeki GitHub Actions zorunlu contract sonuçlarının görünür SUCCESS olması
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

`automation_runs/2026-08-30_1653_ci_contract_repair.md`

## Sıradaki çalışma

1. En yeni exact SHA için 23 workflow sonucunu yeniden oku; kırmızı job'ların decoded loglarını açarak kalan root-cause'ları düzelt.
2. Flutter Quality analyzer hatalarını ortak köklerden temizleyip test aşamasına geçir; kritik kırmızı varken FINAL deme.
3. Requirements Contract'ı evidence schema düzeltmesi sonrası yeniden doğrula; validator bir sonraki bozuk evidence kaydını gösterirse aynı şekilde düzelt.
4. Kritik CI borcu kontrol altına alındığında canonical editorial batchlere `2035-01-01` tarihinden devam et.
5. Günün Mesajı kapsamını TR ve bağımsız EN olarak 2036-12-31'e kadar kesintisiz ilerlet; strict release completeness/quality auditini ancak 8.036 kayıt tamamlanınca çalıştırıp RC'leri kanıtla.
6. Fiziksel artifact/font/UI/device-test gerektiren maddelere kanıtsız DONE verme.

**FINAL: NO.**
