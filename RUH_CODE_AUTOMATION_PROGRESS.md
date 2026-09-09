# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific evidence ile birlikte independent/golden, TR/EN, offline, Free/PRO, backup/PDF, security, accessibility, performance, clean-checkout/lifecycle/device ve exact-release kapıları kapandığında verilir. Canonical lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; exact kapsam `RC-0001→RC-1442`, toplam 1.442 requirement.

## Canonical durum

- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0950 implementation/matrix zincirleri mevcut; global goldens/device/PDF/backup blocker'ları nedeniyle DONE değil.
- RC-0951→0964 = IMPLEMENTED + blocked=YES (`5f08942462a0b3784725b9fd7e65de0cc22eb50e`).
- RC-0965→0994 traceability release-mode fail-closed; 1.442 requirement doğrudan evidence ile kapanmış değil.
- RC-0995→1003 authoritative golden contract mevcut; exact AKİLES provenance/independent values eksik.
- RC-1004→1039 = IMPLEMENTED + blocked=YES (`fb71d1b9703f35a4dec499e7d7de33151d57a75e`).
- RC-1040→1058 = IMPLEMENTED + blocked=YES (`d96a3b5c1821d81739b491757795cfced5ba040a`).
- RC-1059→1084 = IMPLEMENTED + blocked=YES (`ed87a5c385425a0c3e7f59f7f884c8dc55cab8f6`).
- RC-1085→1104 = IMPLEMENTED + blocked=YES (`a9c4b832269328935dbf6d4753f603d17fa5b1f7`).
- RC-1105→1130 dependency/offline governance mevcut; `pubspec.lock` `09cf4da44c63c8031a149a7c555e37362ef194aa` ile fiziksel.
- PR #1 RC-1131→1144 release governance; PR #2 RC-1145→1160 Android compatibility; PR #3 RC-1161→1174 location; PR #4 RC-1175→1196 security/privacy; PR #5 RC-1197→1205 deletion; PR #6 RC-1206→1221 search; PR #7 RC-1222→1236 cache; PR #8 RC-1237→1248 portable backup; PR #9 RC-1249→1272 PDF export.
- RC-1206→1221 run `34309365775` SUCCESS, fakat production SQLite/FTS/device/UI blocker'ları açık.
- RC-1222→1236 run `34317258421` FAILURE: exact cache contract + cache regression SUCCESS, eski head üzerindeki RC1197 deletion recheck kırmızı.
- RC-1237→1248 run `34317258841` FAILURE: portable-backup contract + regression SUCCESS, upstream cache/deletion gate kırmızı.
- RC-1249→1272 PR #9 açıldı. Lifecycle promotion için dedicated CI sonucu bekleniyor; production renderer/UI, Android scoped-storage/share, process-kill/background ve exact release blocker'ları açık.
- RC-1273→1285 yeni stacked branch `agent/rc1273-rc1285-design-system`; production tokenlar + regression + exact contract + fail-closed validator + dedicated CI oluşturuldu. CI geçmeden lifecycle promotion yok.

## RC-1249→1272 — PDF export governance

`lib/src/pdf/pdf_export_governance.dart` Free demo ile gerçek müşteri export'unu fail-closed ayırır. Free sample `usesDemoData=true`, watermark açık ve gerçek `clientId` olmadan çalışır; gerçek müşteri PDF'si PRO + stable client ID ister ve demo data kabul etmez. Tam profesyonel raporda watermark kapatılabilir.

Cancellation/exception partial PDF'yi success yapamaz; app-private `.partial.pdf` cleanup edilir ve final publish atomic storage adapter sınırından geçer. Output/share-cache sandbox dışına çıkamaz. Aynı müşteri işleri serialize edilir; global eşzamanlılık `maximumConcurrentJobs` ile sınırlandırılır ve permit-transfer yarış koşulu `506a6ca6d221eba75449158313e94f00f62696d8` ile kapatıldı. Deterministic filename collision ve unique content-order policy var.

RC-1272 için `test/fixtures/pdf/rc1272_free_sample_fixture.json` + `test/pdf/pdf_release_fixture_rc1272_test.dart` gerçek `pw.Document` üretip `%PDF` header'ını doğruluyor. Concurrency regression `test/pdf/pdf_export_concurrency_rc1262_test.dart` 6 job üzerinde configured limit 2'yi ölçüyor. Exact contract/validator/workflow mevcut. PR #9 head checkpoint: `45fb168792e500512e5887c1e21a40dedae95696`.

## RC-1273→1285 — typography / spacing / contrast design system

`lib/src/ui/theme/ruh_design_tokens.dart` ve canonical `ui/design_tokens.json` genişletildi:

- `title / section / body / caption` dört ayrı semantic text class. Baselines: 28/20/16/13sp; body 16sp, chart label minimum 13sp.
- Her class explicit line-height taşır; body 1.50, caption 1.35.
- Paragraph 12, section 24, card padding 16, screen edge 16, PDF edge 16, chart legend 8 ve legend-item 12 semantic token oldu.
- Light palette korunurken explicit dark palette eklendi; `RuhAppTheme.light()` ve `RuhAppTheme.dark()` aynı semantic text classes'ı kullanır.
- `test/ui/ruh_design_system_rc1273_rc1285_test.dart` typography ayrımı, font floors, spacing/padding/legend değerleri, theme mapping ve light/dark normal-text contrast >= 4.5 ölçer.

Production commit `f76f479c22fbd34c20106acf6817d5094cc00d73`; canonical token update `b8fe0f85fc80083319937fa48d4cb0875caa6f1d`; regression `ff42bfa7a00df181735d7fc746fa430f73534dbb`; exact contract `6089e5c756238213a5f7b7219a91ee7eea02bbc9`; validator fix `d6d743e9300eeeebdd3503c52cce84607f308075`; dedicated CI `c47af1d0c24b7e13411fcc878b7438eef6c53b4c`.

RC-1273→1285 VERIFIED/DONE değildir: production screen/chart/PDF token adoption audit, rendered TR/EN goldens, supported text-scale/device accessibility ve exact release artifact gereklidir.

## Global blocker'lar

Exact AKİLES provenance; independent authoritative calculation goldens; Panchanga/Vedic ve Dasha/Varga/Gochara/BaZi providers; historical timezone/DST/polar goldens; rendered TR/EN UI/PDF; interpretation/editorial QA; EOP/DE440s/package license evidence; encrypted persistence/key management/migrations; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode physical proof; security/accessibility/performance; branch/review governance; clean-checkout/lifecycle ve exact release artifact.

## Sonraki devam noktası

1. PR #9 RC-1249→1272 ve yeni RC-1273→1285 dedicated CI'larını fiziksel oku; kırmızıysa kök nedeni aynı stacked hatta düzelt. Güncel RC1197 validator/regression recheck'i özellikle doğrula.
2. Binding sırada RC-1286+ sonraki requirement bloğunu exact sırayla ilerlet.
3. RC-1222→1248 kendi contract/regression'ları yeşil olsa da upstream kırmızı kapanmadan promotion verme.
4. RC-0995→1003 provenance/golden ve RC-0965→0994 traceability açıklarını paralel azalt.
5. RC-0001→RC-1442 tamamı DONE ve bütün release kapıları green olmadan FINAL deme.

**FINAL: NO.**
