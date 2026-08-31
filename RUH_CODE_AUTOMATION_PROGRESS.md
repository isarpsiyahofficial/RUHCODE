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

- TR ledger: `2026-01-01 → 2036-07-31` = **3865**
- EN ledger: `2026-01-01 → 2036-07-31` = **3865**
- Ledger toplamı: **7730 / 8036**
- Ledger kalan: **306**
- Ledger'ın sıradaki exact başlangıcı: **2036-08-01**

Haziran ve Temmuz 2036 canonical shardları commit sonrası `main` üzerinden yeniden okunarak locale başına toplam 61 exact tarih, doğru locale alanları ve canonical şema doğrulandıktan sonra ledger ileri taşındı.

## Bu turdaki doğrulama ve ilerleme

- Binding master TODO/index, mevcut progress ve editorial ledger yeniden okundu; kapsam `RC-0001 → RC-1442` olarak doğrulandı.
- Baseline exact HEAD `33cee79ff671fc4a5dbc9614b549786cb05121e1` için 23 Actions run tamamlandıktan sonra iki kritik kırmızı doğrulandı: `Requirements Contract` ve `Flutter Quality`.
- Requirements decoded log kök nedeni: `evidence/pdf/report_planning_contract.json` semantik ownership mismatch, missing `RC-0903`.
- `RC-0903` evidence requirement listesine eklendi; evidence `done:false` ve RC-0903 release blocker açık tutuldu.
- Flutter Quality decoded log `flutter analyze --fatal-infos` aşamasında 29 diagnostic ile kırıldı; test aşaması analyzer kırmızı olduğu için çalışmadı.
- Backup testlerinin kullandığı `BackupImportMode`, tek canonical enum korunarak `backup_import_coordinator.dart` üzerinden re-export edildi.
- Numerology PDF/UI testlerindeki `PdfSubjectKind` import driftleri explicit `pdf_data_contract.dart` importlarıyla düzeltildi.
- `PdfReportOptions`, `pdf_report_contract.dart` üzerinden görünür hale getirildi.
- Combined PDF adapter'daki invalid `const StateError` kaldırıldı.
- PDF asset-font testinde gereksiz `dart:typed_data` kaldırıldı ve `FlutterError` doğru Flutter foundation importundan alındı.
- `persisted_calculation_pdf_router.dart` stale unused importu kaldırıldı.
- Yeni exact-head CI tamamlanmadan bu değişikliklere SUCCESS statüsü verilmedi.
- Bu turda daily-message ledger ileri taşınmadı; kanıtsız editorial kayıt sayılmadı.

## Açık ana blocker'lar

- newest exact HEAD üzerinde bütün zorunlu GitHub Actions/Flutter Quality kapılarının tamamlanmış SUCCESS olması
- baseline analyzer logundan kalan invalid PDF const/import/deprecation borçlarının kapatılması ve ardından gerçek test aşamasının çalıştırılması
- remaining daily-message editorial kapsamı: TR+EN `2036-08-01 → 2036-12-31` ve ardından strict 8.036-record release audit
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

`automation_runs/2026-08-31_1857_ci_contract_analyzer_repair.md`

## Sıradaki çalışma

1. En yeni exact SHA Actions sonucunu yeniden oku; Requirements Contract ve Flutter Quality kırmızıysa newest decoded log üzerinden kalan kök nedenleri kapat.
2. Analyzer yeşil olduğunda açılan `flutter test` sonuçlarını gerçek test kapısı olarak ele al ve kırmızıları düzelt.
3. Canonical editorial batchlere `2036-08-01` tarihinden devam et; TR ve EN tracklerini bağımsız tut.
4. Günün Mesajı kapsamını `2036-12-31` tarihine kadar kesintisiz tamamla; strict release auditini ancak 8.036 kayıt tamamlanınca çalıştır.
5. Fiziksel artifact/font/UI/device-test gerektiren maddelere kanıtsız DONE verme.

**FINAL: NO.**
