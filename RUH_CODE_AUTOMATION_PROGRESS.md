# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** SOURCE_LEVEL_IMPLEMENTED / IMPLEMENTED, DONE değildir. DONE yalnız gerekli test, golden, cihaz ve release kanıtlarıyla verilir.

## Requirement durumu

- Exact kapsam: `RC-0001 → RC-1442`.
- Repository-wide evidence integrity, semantic ownership ve matrix provenance kapıları aktif.
- Calculation, UI, backup, PDF, entitlement ve content kanıtları eksik final doğrulamalarını atlayarak DONE üretemez.
- `requirements/requirement_state.csv` için kanıtsız DONE/status override eklenmedi.

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
- Daily-message legacy source adapter: committed 5-sütun shardlar canonical 6-sütun in-memory şemaya deterministik normalize edilir; yeni editorial batch girişleri yalnız canonical şema kabul eder.

## Günün Mesajı — doğrulanmış ledger

Başlangıç hedefi: **4.018 tarih × 2 bağımsız dil = 8.036 kayıt**.

- TR ledger: `2026-01-01 → 2034-08-31` = **3165**
- EN ledger: `2026-01-01 → 2034-08-31` = **3165**
- Ledger toplamı: **6330 / 8036**
- Ledger kalan: **1706**
- Ledger'ın sıradaki exact başlangıcı: **2034-09-01**

`2034-08-01 → 2034-08-31` için daha önce eklenen **31 TR + 31 bağımsız EN = 62 kayıt**, bu turda source-schema adapter zinciriyle production builder/editorial-progress sözleşmesine bağlandı ve evidence ledger fiziksel shard setiyle eşitlendi.

### Content-schema blocker — çözülen source-level bölüm

Repository'deki legacy aylık shard formatı `date,title,teaser,message,theme`; canonical runtime/build formatı `date,locale,title,teaser,full_text,theme_tag`.

Bu turda:

- `tools/content/daily_message_schema.py` tek normalization sözleşmesi olarak eklendi.
- Legacy committed shardlar yalnız deterministik adapter üzerinden okunuyor; `message → full_text`, `theme → theme_tag`, locale ise shard dizininden exact türetiliyor.
- `tools/content/build_daily_message_catalog.py` adapter üzerinden canonical katalog üretiyor.
- `tools/content/validate_daily_message_editorial_progress.py` aynı adapter üzerinden exact date/locale/nonblank/duplicate/contiguity/leap/ledger eşitliği denetliyor.
- `tools/content/append_daily_message_batch.py` geçmiş legacy shardları okuyabiliyor fakat **yeni batch girdilerini yalnız canonical 6-sütun şemada kabul ediyor**; yeni/yeniden yazılan hedef shard canonical olur.
- `tools/content/test_daily_message_schema.py` legacy normalization, canonical preservation, legacy-new-batch rejection ve locale mismatch vakalarını kapsıyor.
- `.github/workflows/daily-message-editorial-contract.yml` yeni schema testini ve adapter path trigger'ını içeriyor.
- `evidence/content/daily_messages_editorial_progress.json` August 2034 fiziksel shardlarıyla **6330/8036** seviyesine getirildi.

Bu düzeltme yalnız source-level/ledger ilerlemesidir; strict full 8.036 release auditinin yerine geçmez. RC-1424/1425/1426/1427/1433/1434 bu nedenle DONE yapılmadı.

## Açık ana blocker'lar

- remaining daily-message editorial kapsamı: TR+EN `2034-09-01 → 2036-12-31` ve sonrasında strict 8.036-record release audit
- exact HEAD üzerindeki GitHub Actions daily-message contract sonucunun görünür SUCCESS olması
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

`automation_runs/2026-08-30_0856_daily_message_schema_adapter_august_2034.md`

## Sıradaki çalışma

1. Exact HEAD üzerinde `Daily Message Editorial Contract` workflow sonucunu doğrula; kırmızıysa root-cause düzelt ve yeniden çalıştır.
2. Sonraki editorial batch `2034-09-01` tarihinden başlasın ve doğrudan canonical `date,locale,title,teaser,full_text,theme_tag` şemasıyla üretilecek/eklenecek.
3. Günün Mesajı kapsamını TR ve bağımsız EN olarak 2036-12-31'e kadar kesintisiz ilerlet; strict release completeness/quality auditini ancak 8.036 kayıt tamamlanınca çalıştırıp RC'leri kanıtla.
4. Blocker gerektirmeyen PDF/UI/accessibility/evidence requirement'larını paralel ilerlet.
5. Fiziksel artifact/font/UI/device-test gerektiren maddelere kanıtsız DONE verme.

**FINAL: NO.**
