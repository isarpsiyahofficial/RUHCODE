# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte independent/golden, TR/EN, offline, Free/PRO, backup/PDF, security, accessibility, performance, clean-checkout/lifecycle/device ve exact-release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Canonical durum özeti

- RC-0061 = IMPLEMENTED + blocked=YES; RC-0062 unresolved promotion.
- RC-0082→0083 = NOT_STARTED/blocked; RC-0086→0087 = IMPLEMENTED + blocked=YES.
- RC-0099→0157 arasında önceki TESTED promotion kanıtları korunuyor; RC-0124→0126 exact AKİLES provenance eksikliği nedeniyle açık.
- RC-0158→0270 = implementation/test zincirleri mevcut; eksik physical promotion ve global blocker'lar korunuyor.
- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0694 = implementation/matrix zincirleri mevcut; production-scale golden, rendered UI/device ve diğer global blocker'lar nedeniyle DONE değil.
- RC-0695→0754 = IMPLEMENTED + blocked=YES; central/versioned data model ve copy-first migration zinciri mevcut.
- RC-0755→0773 = IMPLEMENTED + blocked=YES; transactional data-safety zinciri mevcut; physical promotion açık.
- RC-0774→0848 = IMPLEMENTED + blocked=YES; portable relational CSV backup/import zinciri mevcut; RC-0848 exact clean-install round-trip açık; physical promotion açık.
- RC-0849→0858 = IMPLEMENTED + blocked=YES; physical promotion `0fc8d876e8349298b432f99f294f5300c4a7a478`.
- RC-0859→0869 = local human-readable PDF release/privacy boundary implementation zinciri mevcut + blocked=YES.
- RC-0870→0877 = vector PDF source/render implementation + regression + exact contract + validator + CI mevcut; rendered golden/zoom/print evidence açık.
- RC-0878→0889 = A4 layout/overflow/pagination implementation zinciri mevcut + blocked=YES.
- RC-0890→0894 = IMPLEMENTED + blocked=YES; physical matrix promotion `2883d2318e5b897ccc1e4191ece4c8631f7846f5`.
- RC-0895→0905 = **IMPLEMENTED + blocked=YES; physical matrix promotion `fc97701a02c3c7c47d1733a4a2d4dbfebe8cf305` doğrulandı.**
- RC-0906→0932 = **müşteri/doğum/hesaplama bilgisi + Calculation Manifest + selectable/reorderable report sections + preview/final ortak section model implementation zinciri eklendi. Physical matrix promotion/CI sonucu görülmeden TESTED/DONE verilmeyecek.**
- RC-0933→0941 = **collision-safe filename + local share/email/messaging/files delivery policy implementation zinciri eklendi. Physical matrix promotion/CI sonucu görülmeden TESTED/DONE verilmeyecek.**

## Son çalıştırmada yapılan gerçek geliştirme

### RC-0906→0932 — PDF müşteri/hesap bilgisi ve bölüm kompozisyonu

`lib/src/pdf/pdf_report_content.dart` eklendi. `PdfSubjectReportData` doğum tarihi, doğum saati, doğum yeri ve IANA timezone bilgisini merkezi `BirthData` modelinden tüketiyor. `BirthTimePrecision.unknown` durumunda saat uydurulmuyor; TR için `Bilinmiyor`, EN için `Unknown` üretiliyor. Teknik raporlar `CalculationManifestRecord` üzerinden engine/algorithm/data/tzdb, zodiac system, house system, node mode ve ayanamsha özetini taşıyor; teknik mod manifest olmadan fail-closed.

`PdfSectionCompositionPlanner` profesyonelin bölüm aç/kapat ve sıralama tercihlerini gerçek content availability ile birleştiriyor. Müşteri/account bölümü ilk içerik bloğu olarak zorunlu. Chart, placements, houses, aspects, transits, numerology, custom notes ve prepared interpretations ayrı seçilebilir bölümler. Prepared interpretations tamamen kapatılabiliyor. İçeriksiz transit/diğer bölümler oluşturulmuyor. Preview ve final PDF aynı immutable ordered section listesini tüketiyor.

Production commits: `6c22dfec33a1533f2a025617c9dc78543b64a191`, `8444988bee00a0ba687308bed02cf05678898b05`.
Regression: `2bb5b141f20eb2540a30fc4276557ed739d7ce6d`.
Contract: `448937fb51ea8ddd75748d3cf683689656ee3ff9`.
Validator: `f4f77c5cb675df0dbceffa8e9430ae086855e23c`.
CI gate: `36d76cb67c4b38f47400231397bda82fdea6a2bb`.

Açık kanıt: production UI toggle/reorder wiring, rendered TR/EN preview→final golden comparison ve exact release PDF inspection. Bu nedenle ceiling IMPLEMENTED.

### RC-0933→0941 — local PDF dosya adı ve teslimat politikası

`lib/src/pdf/pdf_local_delivery.dart` eklendi. `PdfFileNamePolicy` işletim sistemlerinde sorun çıkaran karakterleri temizliyor, bounded dosya adı üretiyor ve aynı isim varsa `(2)`, `(3)` şeklinde collision-safe isim tahsis ediyor; eski raporun sessizce üzerine yazılmıyor. `PdfLocalDeliveryTarget` system share sheet, email app, messaging app ve device files hedeflerini ayırıyor. `PdfLocalDeliveryPolicy` internet veya owned server gerektirmiyor ve remote-PDF URL girişini kabul etmiyor; yalnız tamamlanmış non-empty local PDF bytes teslimata alınabiliyor.

Production: `7f2dd7a5fc2cd4bc7708d5848a1aa3ece7ae7d26`.
Regression: `b38bae847bc7939d7a895c04b8acd7236c8d3d25`.
Contract: `c2603a66bad072c933e9c9d4e5ab3409534d3c50`.
Validator: `79424d4e3a8607f054b65e5ab5624c9b82046c94`.
CI gate: `9800a44f2c86b7197edcc7409f89156bd83e0ab3`.

Açık kanıt: Android/iOS platform share/files adapter wiring, airplane-mode device integration ve exact-release delivery verification. Bu nedenle ceiling IMPLEMENTED.

## Açık blocker'lar

RC-0870→0877 için production calculation-result→vector chart projection ve physical golden/zoom/print evidence açık. RC-0878→0889 için rendered TR/EN overflow/widow-orphan/table/page-break goldens açık. RC-0890→0894 için generated golden PDF metadata görsel kanıtı açık. RC-0895→0905 için production local logo resolver ve cover/system rendered goldens açık. RC-0906→0932 için gerçek report-builder UI wiring ve rendered preview/final goldens açık. RC-0933→0941 için platform adapter + airplane-mode device kanıtı açık.

Global blocker'lar korunuyor: independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; rendered TR/EN UI/PDF/share cards; encrypted persistence/key management; production migration corpus; interpretation/editorial QA; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact. RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-0906→0932 ve RC-0933→0941 dedicated CI/matrix sonuçlarını fiziksel olarak yeniden oku; kırmızıysa root-cause düzelt ve yeniden doğrula. Promotion varsa yalnız kanıtlanan lifecycle seviyesini kaydet.
2. Binding sırada **RC-0942+ uzun PDF/performance/atomic completion/validation/golden regression** hattına geç.
3. RC-0870/0878/0895/0906/0933 rendered/device blocker'larını kaybetmeden bağımsız ilerleyebilen maddeleri sürdür.
4. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapma.
5. RC-0001→1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL deme.

**FINAL: NO.**