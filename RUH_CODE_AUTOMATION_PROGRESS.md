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
- RC-0324→0492 = implementation/matrix zincirleri mevcut; production-scale golden, rendered UI/device ve diğer global blocker'lar nedeniyle DONE değil.
- RC-0493→0694 = production + regression + exact contract + fail-closed CI zincirleri mevcut; physical promotion eksikleri ayrı korunuyor.
- RC-0695→0754 = IMPLEMENTED + blocked=YES; central/versioned data model ve copy-first migration zinciri mevcut.
- RC-0755→0773 = IMPLEMENTED + blocked=YES; transactional data-safety zinciri mevcut; physical promotion açık.
- RC-0774→0848 = IMPLEMENTED + blocked=YES; portable relational CSV backup/import zinciri mevcut; RC-0848 exact clean-install round-trip açık; physical promotion açık.
- RC-0849→0858 = IMPLEMENTED + blocked=YES; physical promotion `0fc8d876e8349298b432f99f294f5300c4a7a478`.
- RC-0859→0869 = local human-readable PDF release/privacy boundary implementation zinciri mevcut + blocked=YES; exact release TR/EN glyph/no-network evidence açık.
- RC-0870→0877 = **gerçek vector PDF source/render zinciri bu çalıştırmada eklendi; source implementation + regression + exact contract + validator + CI mevcut. Physical matrix promotion/CI sonucu henüz kanıtlanmadan TESTED/DONE verilmeyecek.**
- RC-0878→0889 = A4 layout/overflow/pagination implementation zinciri mevcut + blocked=YES; rendered golden evidence açık.
- RC-0890→0894 = **IMPLEMENTED + blocked=YES; physical matrix promotion `2883d2318e5b897ccc1e4191ece4c8631f7846f5` doğrulandı.**
- RC-0895→0905 = **optional vector-logo / cover-style / report-system identity / combined-system separation implementation zinciri bu çalıştırmada eklendi. Physical matrix promotion/CI sonucu henüz kanıtlanmadan TESTED/DONE verilmeyecek.**

## Son çalıştırmada yapılan gerçek geliştirme

### RC-0870→0877 — gerçek vector PDF primitives

`lib/src/pdf/pdf_vector_rendering.dart` ve `lib/src/pdf/pdf_vector_widget.dart` eklendi. Western chart artık SVG tabanlı gerçek vector daire/radyal çizgi/planet point/aspect-line primitive'leri üretebiliyor. Vedic chart sabit kare `viewBox` ve 12-house vector geometri kullanıyor. Raster `<image>`, `data:image`, PNG/JPEG payload'ları fail-closed. `PdfVectorWidget`, doğrulanmış SVG'yi `package:pdf` `pw.SvgImage` üzerinden gerçek PDF vector widget'ına çeviriyor. Numerology ve BaZi için rectangular/aligned gerçek PDF table data kuralları eklendi; BaZi en az dört kolon gerektiriyor.

Regression: `test/pdf/pdf_vector_rendering_rc0870_rc0877_test.dart`; testler gerçek `pw.Document` oluşturup `document.save()` çağırıyor.
Contract: `requirements/contracts/rc0870_rc0877_pdf_vector_rendering_contract.json`.
Validator: `tools/requirements/validate_rc0870_rc0877_pdf_vector_rendering.py`.
CI: `.github/workflows/rc0870-rc0877-pdf-vector-rendering.yml`.
CI-gate commit: `993ef260004ab3c71bde263aa12f7cdc57ce9a50`.

Açık kanıt: production chart result projection, rendered TR/EN golden PDF visual inspection, zoom/print inspection ve exact-release artifact. Bu nedenle ceiling IMPLEMENTED.

### RC-0895→0905 — logo/cover/report composition

`lib/src/pdf/pdf_cover_composition.dart` eklendi. Logo kullanımı tamamen opsiyonel. Logo yok veya local resolver asset'i çözemiyorsa `showLogo=false` ve `reserveLogoSpace=false`; phantom/boş logo alanı oluşturulmuyor. Logo gösterilecekse yalnız local olarak çözülmüş vector SVG kabul ediliyor; raster payload fail-closed ve requested asset id ile resolved asset id eşleşmek zorunda.

`PdfCoverCompositionPlanner` report kind ile Western/Vedic/Numerology/BaZi/Combined identity'yi ve `professional/clientFriendly` cover style'ını açık olarak taşıyor. `PdfCoverWidget` gerçek `package:pdf` widget'ı üretiyor. Combined report sınırında her child system için açık heading ve benzersiz concrete system identity zorunlu; aynı Western system'in Vedik diye ikinci kez etiketlenmesine izin verilmiyor.

Production commit: `f7f80de67ae7dbc42966c03c523ac91bc256dcdc`.
Regression commit: `dfcb14bf1e281644d548edd7fe8c7bbdf9554279`.
Contract commit: `b71df0702558f8cb3f442742407970f328134f11`.
Validator commit: `3f126e7ef399a2217b1611655f8c3041909c8df0`.
CI gate commit: `5523d7c2472c8e2fd0e7c9fc358a0f4417fc3732`.

Açık kanıt: production local logo asset resolver wiring, her report kind için rendered TR/EN cover golden ve exact-release PDF inspection. Bu nedenle ceiling IMPLEMENTED.

## Açık blocker'lar

RC-0870→0877 için production calculation-result→vector chart projection ve physical golden/zoom/print evidence açık. RC-0878→0889 için rendered TR/EN overflow/widow-orphan/table/page-break goldens açık. RC-0890→0894 matrix IMPLEMENTED kanıtlandı ancak generated golden PDF metadata görsel kanıtı açık. RC-0895→0905 için production local logo resolver ve cover/system rendered goldens açık.

Global blocker'lar korunuyor: independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; rendered TR/EN UI/PDF/share cards; encrypted persistence/key management; production migration corpus; interpretation/editorial QA; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact. RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-0870→0877 ve RC-0895→0905 dedicated CI/matrix sonuçlarını fiziksel olarak yeniden oku; kırmızıysa root-cause düzelt ve yeniden doğrula. Promotion varsa yalnız kanıtlanan lifecycle seviyesini kaydet.
2. Binding sırada **RC-0906+ müşteri/hesap bilgileri + doğum zamanı unknown davranışı + teknik Calculation Manifest görünürlüğü + selectable/reorderable PDF sections** hattına geç.
3. Bağımsız ilerleyebilen RC-0906+ maddeleri uygulanırken RC-0870/0895 golden blocker'larını kaybetme.
4. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapma.
5. RC-0001→1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL deme.

**FINAL: NO.**
