# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte independent/golden, TR/EN, offline, Free/PRO, backup/PDF, security, accessibility, performance, clean-checkout/lifecycle/device ve exact-release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Canonical durum özeti

- Erken bloklardaki status/promotion zincirleri korunuyor; RC-0062/0082/0083/0086/0087, exact AKİLES provenance ve global release blocker'ları açık.
- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0950 = implementation/matrix zincirleri mevcut; production-scale golden, rendered UI/device, PDF/backup ve global blocker'lar nedeniyle DONE değil.
- RC-0951→0964 = IMPLEMENTED + blocked=YES; promotion `5f08942462a0b3784725b9fd7e65de0cc22eb50e`.
- RC-0965→0994 = requirement/test traceability CI mevcut; 1.442 RC doğrudan evidence ile kapanmadığı için release-mode fail-closed.
- RC-0995→1003 = authoritative golden corpus sözleşmesi var; exact AKİLES ve bağımsız production golden değerleri eksik, promotion yok.
- RC-1004→1039 = IMPLEMENTED + blocked=YES; promotion `fb71d1b9703f35a4dec499e7d7de33151d57a75e`.
- RC-1040→1058 = IMPLEMENTED + blocked=YES; promotion `d96a3b5c1821d81739b491757795cfced5ba040a`.
- RC-1059→1084 = IMPLEMENTED + blocked=YES; promotion `ed87a5c385425a0c3e7f59f7f884c8dc55cab8f6`.
- RC-1085→1104 = IMPLEMENTED + blocked=YES; promotion `a9c4b832269328935dbf6d4753f603d17fa5b1f7`.
- RC-1105→1130 = offline/dependency governance zinciri mevcut; `pubspec.lock` `09cf4da44c63c8031a149a7c555e37362ef194aa` ile fiziksel olarak oluştu; license/device/exact-release blocker'ları açık.
- RC-1131→1144 = PR #1 release governance; repository-level branch protection/ruleset, independent review, device/minified parity ve exact artifact olmadan VERIFIED/DONE yok.
- RC-1145→1160 = PR #2 Android compatibility; API21/API37 ve production viewport/font/chart/table/keyboard fiziksel kanıtları eksik.
- RC-1161→1174 = PR #3 location input; production picker/form/permission wiring ve real-device performance eksik.
- RC-1175→1196 = PR #4 security/privacy; secure-storage/keystore/biometric/encrypted persistence/release-log kanıtları eksik.
- RC-1197→1205 = PR #5 deletion/restore; production transaction/UI confirmation/tombstone backup serialization hâlâ blocker.
- RC-1206→1221 = PR #6 professional search/pagination; dedicated run `34309365775` SUCCESS; production SQLite/FTS/device/UI pagination blocker.
- RC-1222→1236 = PR #7 calculation cache; exact validator + cache regression yeşil, ancak run `34317258421` downstream RC1197 recheck adımında kırmızı kaldı; matrix promotion yok.
- RC-1237→1248 = PR #8 portable backup; exact validator + portable-backup regression yeşil, run `34317258841` upstream cache/deletion gate adımında kırmızı kaldı; matrix promotion yok.
- RC-1249→1272 = yeni stacked branch `agent/rc1249-rc1272-pdf-export-governance`; production + regression + exact contract + fail-closed validator + dedicated CI oluşturuldu; PR/CI sonucu gelmeden lifecycle promotion yok.

## Bu çalıştırmada yeniden doğrulanan CI gerçeği

RC-1222→1236 run `34317258421` artık queued değil, **FAILURE**. Exact requirement contract ve calculation-cache regression adımları SUCCESS; kırmızı adım `Recheck RC1197-RC1205 deletion validator after root-cause fix`. Run eski `7658e102...` head'inde gerçekleşti. Güncel top branch'te `data_deletion_policy.dart`, validator ve regression tekrar fiziksel olarak mevcut; yeni RC1249 gate bunları aynı head üzerinde yeniden koşacak.

RC-1237→1248 run `34317258841` de **FAILURE**. Portable-backup exact contract ve regression SUCCESS; kırmızı adım `Keep upstream cache/deletion gates green`. Dolayısıyla portable-backup'ın kendi regression'ı yeşil olsa da upstream kırmızı nedeniyle IMPLEMENTED promotion yapılmadı.

## RC-1249→1272 — PDF export / Free-PRO / lifecycle governance

Yeni `lib/src/pdf/pdf_export_governance.dart` gerçek export authorization ve lifecycle sınırı ekler:

- Free sample yalnız `freeDemo + usesDemoData=true + watermarkEnabled=true` ile üretilebilir; gerçek `clientId` taşıyamaz.
- Gerçek müşteri PDF'si `professionalClient + isPro=true + clientId` ister; demo verisi kullanamaz. Tam profesyonel raporda watermark kapatılabilir.
- `PdfExportCancellationToken` üretim öncesi/sonrası ve publish öncesi kontrol edilir; cancellation veya exception successful output olarak raporlanmaz.
- Temporary `.partial.pdf` app-private share cache altında tutulur, success/cancel/failure sonunda temizlenir; final publish storage adapter üzerinden atomic operation ister.
- Output/share-cache path sandbox dışına çıkamaz; path traversal fail-closed.
- Aynı müşteri/report key için işler serialize edilir. Global PDF işi `maximumConcurrentJobs` ile sınırlandırılır; permit waiter'a doğrudan transfer edilerek race/oversubscription önlenir.
- Filename collision policy mevcut dosyayı ezmeden deterministik `(2)`, `(3)` isim üretir.
- `PdfAppLifecycleMode` foreground/background politikasını explicit taşır; gerçek process-kill davranışı fiziksel platform kanıtı olmadan DONE sayılmaz.
- Content section order explicit, unique ve deterministic olmak zorundadır.

Ana production düzeltmesi: `506a6ca6d221eba75449158313e94f00f62696d8`.

Regression kanıtları:

- `test/pdf/pdf_export_governance_rc1249_rc1272_test.dart`: Free/demo izolasyonu, PRO client export, cancellation/failure/success cleanup, sandbox, same-client serialization, collisions ve deterministic order.
- `test/pdf/pdf_export_concurrency_rc1262_test.dart`: 6 bağımsız job ile configured `maximumConcurrentJobs: 2` sınırını ölçer; commit `b37f1c030a108f4b67a2928c541494ce1b94acdf`.
- `test/fixtures/pdf/rc1272_free_sample_fixture.json`: versioned deterministic Free sample fixture; commit `cedeffb3e13003269fbf26923c22dac8bbd48ef3`.
- `test/pdf/pdf_release_fixture_rc1272_test.dart`: fixture'dan gerçek `pw.Document` oluşturup `document.save()` ile PDF üretir ve `%PDF` header'ını doğrular; commit `eef95e3e5e1fdbc43305b93072da0d8d393bf796`.

Exact requirement contract `requirements/contracts/rc1249_rc1272_pdf_export_contract.json`; contract/evidence düzeltme commit'i `8eacab7f0b3ec0d9cc3eccbaef0254a0c361a9a1`.
Fail-closed validator `tools/requirements/validate_rc1249_rc1272_pdf_export.py`; commit `c46f7816e62ff05b96553ee23292ade3aaa31752`.
Dedicated matrix-writing CI `.github/workflows/rc1249-rc1272-pdf-export.yml`; upstream PDF/entitlement yanında RC1197 deletion validator+regression'ını da güncel head üzerinde tekrar koşar; son workflow commit'i `b19499186ac363bd924e02b5b644c8a7740ecbb7`.

## Açık blocker'lar

RC-1249→1272 için production renderer/UI wiring, gerçek Android scoped-storage/share adapter, real background/process-kill lifecycle, physical cleanup verification ve exact release artifact gereklidir. Bunlar olmadan RC-1266/1270 dahil blok VERIFIED/DONE değildir.

Global blocker'lar: authoritative independent production goldens; exact AKİLES provenance; Panchanga/Vedic; Dasha/Varga/Gochara/BaZi providers; historical timezone/DST/polar goldens; production localization + rendered TR/EN UI/PDF; interpretation/editorial QA; EOP/DE440s redistribution/license evidence; package license approvals; encrypted persistence/key management; migration corpus; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; airplane-mode/device proof; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact.

## Sonraki devam noktası

1. RC-1249→1272 PR/dedicated CI sonucunu fiziksel oku; kırmızıysa aynı branch'te kök nedeni düzelt. Özellikle güncel RC1197 validator+regression recheck'in sonucunu kanıtla.
2. Binding sırada RC-1273→1285 typography/spacing/card-padding/chart-legend/dark-light contrast design-system hattını production + regression ile ilerlet.
3. RC-1222→1248 upstream kırmızılarını güncel stacked HEAD doğrulamasıyla azalt; kendi contract/regression'ları yeşil olsa bile upstream kırmızı varken promotion verme.
4. RC-0995→1003 exact AKİLES provenance/independent goldens ve RC-0965→0994 traceability açıklarını paralel azalt.
5. RC-0001→RC-1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL deme.

**FINAL: NO.**
