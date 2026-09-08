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
- RC-0755→0773 = IMPLEMENTED + blocked=YES; transactional data-safety zinciri mevcut; bot promotion commit'i son kontrolde bulunamadı.
- RC-0774→0848 = IMPLEMENTED + blocked=YES; portable relational CSV backup/import zinciri mevcut; exact clean-install round-trip RC-0848 açık ve bot promotion commit'i son kontrolde bulunamadı.
- **RC-0849→0858 = IMPLEMENTED + blocked=YES; physical matrix promotion commit `0fc8d876e8349298b432f99f294f5300c4a7a478` doğrulandı.**
- **RC-0859→0869 = implementation chain present + blocked=YES; local human-readable PDF release boundary, regression, exact contract, validator ve matrix-writing CI gate eklendi; matrix satırları physical CI promotion olmadan yükseltilmeyecek.**
- **RC-0870→0877 = NOT_STARTED/blocked; gerçek vector chart/symbol/aspect render + numerology/BaZi/Vedic PDF primitives gerekli. Policy yazılarak tamamlanmış sayılmayacak.**
- **RC-0878→0889 = implementation chain present + blocked=YES; A4 physical layout safety, >=12 mm margins, Unicode long-text preservation, controlled section pagination ve bounded table chunking eklendi; physical promotion bekleniyor.**
- **RC-0890→0894 = implementation chain present + blocked=YES; page numbers + optional report date + client/subject + professional + brand metadata renderer'a bağlandı; physical promotion bekleniyor.**

## Bu çalıştırmada yapılan gerçek geliştirme

### RC-0859→0869 — PDF release/privacy boundary

`lib/src/pdf/pdf_release_boundary.dart` eklendi ve `PdfLocalReportService` içine zorunlu gate olarak bağlandı. Production boundary PDF'nin teknik backup olmadığını, tamamen cihaz üzerinde üretildiğini, kişisel veriyi dışarı göndermediğini, calculation'ı PDF içinde yeniden hesaplamadığını, uygulama screenshot'larını PDF layout kaynağı yapmadığını ve düşük çözünürlüklü chart JPEG yolunu kabul etmediğini fail-closed biçimde modelliyor. Mevcut `pw.MultiPage` + embedded TTF renderer canonical PDF layout motoru olarak korunuyor. TR/EN font bundle kapsamı mevcut font provider ile contract'a bağlandı. Dosya adı üretiminde OS-reserved karakterleri temizleyen Unicode-safe sanitizer eklendi.

Regression: `test/pdf/pdf_release_boundary_rc0859_rc0869_test.dart`.
Contract: `requirements/contracts/rc0859_rc0869_pdf_release_boundary_contract.json`.
Validator: `tools/requirements/validate_rc0859_rc0869_pdf_release_boundary.py`.
CI: `.github/workflows/rc0859-rc0869-pdf-release-boundary.yml`.
Ana commitler: `554651d4a9367f745b9619377cd03d32ffc647d6`, `425b5d8e60c35b792ab612f26842851521e764e9`, `a1a22e1027aae3850c4aecc44c79197792ae7620`, `2fe613e6f868865e8f9fff24eb05a75fed9b9c77`, `28c134e241432f0ee24618af16abfd4934b94dc4`, `3053d59ceb8c789e2969687b28515f29fc482575`.

### RC-0878→0889 — A4 layout / overflow / pagination

`lib/src/pdf/pdf_document_layout_safety.dart` eklendi ve local PDF service içine bağlandı. Profesyonel PDF v1 gerçek A4 ölçüsünü ve minimum 12 mm güvenli margin'i zorunlu tutuyor. Uzun TR/EN metinleri ekran genişliğine göre kesmek yerine Unicode olarak koruyor; unsupported control karakterleri fail-closed. Mevcut renderer'daki `pw.Inseparable` başlık + ilk paragraf koruması, `pw.NewPage(freeSpace: ...)` kontrollü bölüm pagination'ı ve `PdfTableLayout` bounded table chunks exact contract'a bağlandı.

Regression: `test/pdf/pdf_document_layout_rc0878_rc0889_test.dart`.
Contract: `requirements/contracts/rc0878_rc0889_pdf_document_layout_contract.json`.
Validator: `tools/requirements/validate_rc0878_rc0889_pdf_document_layout.py`.
CI: `.github/workflows/rc0878-rc0889-pdf-document-layout.yml`.
Ana commitler: `18e7f9bb00c14ba094f81eda5059b249f75adb1f`, `2e990cc42934f09b37a86f43f22b04143940a663`, `5dc76afd7b83eaf9e0c20d3a1268145fe616723b`, `e374a0a2d04a3741c146281712b712ee4b7eab11`, `d710df969c56afc70390bb131dd4f6033cc6d44f`, `a6169ce21642bdf9693466898f8942a78ea271c2`.

### RC-0890→0894 — report metadata

`PdfReportOptions` artık opsiyonel `subjectName` ve `generatedAtUtc` taşıyor. Local service bu metadata'yı renderer'a iletiyor. Renderer sayfa numaralarını koruyor; generation date verilirse TR için `Rapor tarihi`, EN için `Report date` footer metni üretiyor; client/subject name cover'a eklenebiliyor; professional name ve brand name mevcut branding zincirinden render ediliyor. Calculation snapshot/data akışına dokunulmuyor.

Regression: `test/pdf/pdf_metadata_rc0890_rc0894_test.dart`.
Contract: `requirements/contracts/rc0890_rc0894_pdf_metadata_contract.json`.
Validator: `tools/requirements/validate_rc0890_rc0894_pdf_metadata.py`.
CI: `.github/workflows/rc0890-rc0894-pdf-metadata.yml`.
Ana commitler: `d09639f9e4f3c9efbb04569c524a0bb60451c5bf`, `71d456e51ba99baeac11aabfdbf64f2d4ea0cc1e`, `3a47a66c1689b597a74f40e027f147f35efd75b0`, `879c1c2dd489691c2be1f5f2703657392744c26f`, `173eacab6dfe07087a178bd986813fd76ed48923`, `ca91131c57b91efde0b2310429b6c6dc125b6451`, `33757a1f8171b5e62bcaf6b8faaa8663f83e027b`.

## Açık blocker'lar

RC-0859→0869 için exact release TR/EN glyph/fallback output inspection ve physical on-device/no-network evidence açık. RC-0870→0877 gerçek vector chart/symbol/aspect renderer, gerçek PDF numerology table/BaZi column/Vedic chart golden output kanıtı olmadan kapatılmayacak. RC-0878→0889 için rendered TR/EN golden overflow/widow-orphan/table/page-break incelemesi açık. RC-0890→0894 için generated golden PDF metadata görsel kanıtı açık.

Global blocker'lar korunuyor: independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; rendered TR/EN UI/PDF/share cards; encrypted persistence/key management; production migration corpus; interpretation/editorial QA; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact. RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-0859→0869, RC-0878→0889 ve RC-0890→0894 dedicated CI/matrix sonuçları fiziksel olarak yeniden okunacak; kırmızıysa aynı çalıştırmada root-cause düzeltilecek. Bot promotion commit'i varsa yalnız kanıtlanan lifecycle seviyesi kaydedilecek.
2. Binding sıra önce **RC-0870→0877** gerçek vector PDF primitives/rendering açığını kapatmaya çalışacak; blok gerçekten güvenli biçimde kapanamıyorsa blocker korunarak **RC-0895+ logo/cover/report composition** hattındaki bağımsız maddelere devam edilecek.
3. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapılmayacak.
4. RC-0001→1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL denmeyecek.

**FINAL: NO.**
