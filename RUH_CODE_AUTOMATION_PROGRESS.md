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
- RC-0859→0950 = PDF release/vector/layout/metadata/content/delivery/performance implementation zincirleri mevcut + blocked=YES; önceki physical promotions korunuyor.
- RC-0951→0964 = IMPLEMENTED + blocked=YES; physical matrix promotion `5f08942462a0b3784725b9fd7e65de0cc22eb50e` doğrulandı.
- RC-0965→0994 = requirement/test traceability audit ve CI hattı mevcut; tüm 1.442 RC doğrudan test/evidence ile kapanmadığı için release-mode bilinçli olarak kırmızı.
- RC-0995→1003 = authoritative golden corpus sözleşmesi var ancak exact AKİLES ve bağımsız production golden değerleri eksik; promotion yapılmayacak.
- RC-1004→1039 = IMPLEMENTED + blocked=YES; physical matrix promotion `fb71d1b9703f35a4dec499e7d7de33151d57a75e` doğrulandı.
- RC-1040→1058 = IMPLEMENTED + blocked=YES; physical matrix promotion `d96a3b5c1821d81739b491757795cfced5ba040a` doğrulandı.
- RC-1059→1084 = terminology/versioned interpretation matching/safety production + regression + exact contract + fail-closed validator + matrix-writing CI mevcut; physical promotion henüz doğrulanmadı.
- RC-1085→1104 = central entitlement/menu parity + monetization resilience + existing rewarded/store/offline ownership zinciri exact contract/validator/CI ile bağlandı; physical promotion henüz doğrulanmadı.
- RC-1105→1130 = offline startup/dependency governance + license inventory + regression/release gates + dedicated CI eklendi. `pubspec.lock` repository'de eksik bulundu; materialization workflow eklendi ve sonucu bekleniyor. EOP/DE440s ve dependency lisans incelemeleri çözülmeden release gate fail-closed kalacak.

## Son çalıştırmada yapılan gerçek geliştirme

### RC-1004→1039 ve RC-1040→1058 physical promotion

Edge-validity physical promotion: `fb71d1b9703f35a4dec499e7d7de33151d57a75e`.
Runtime invariance physical promotion: `d96a3b5c1821d81739b491757795cfced5ba040a`.
İkisi de yalnız IMPLEMENTED + blocked=YES kanıtıdır; global release kapıları nedeniyle TESTED/VERIFIED/DONE değildir.

### RC-1040→1058 runtime invariance/localization isolation

`lib/src/calculation_core/runtime_invariance.dart` calculation identity'den ambient device model/UI locale/system timezone/decimal separator etkisini ayırır. Stored calculation kendi IANA timezone + UTC instant değerini taşır. “Now” calculation explicit current timezone/UTC ister. Core yalnız canonical dot-decimal kabul eder. TR/EN system text exact key parity ile fail-closed; kullanıcı adı/notu localization resolver'a sokulmadan verbatim korunur.

Production `40ad23a74b0b8e029f95ce46c9e5420d26f1729e`; compile-safe fix `ae648969685c49a990e698f0d7b00cd0ca3a0c97`; regression `0fda2b3298d49ac2e39b6893f06e8577e925d71a` + `c0797b22d225a1b21f3834c85a9784506b185dc0`; contract `11b29e654287b55c25a376e8d385d7bab69339a7`; validator `faff7f57b34ee246aaeca8314722be3b50578c9a`; CI `c46c0e4af58c282cfc0c5e916eac87d948f89025`; bot promotion `d96a3b5c1821d81739b491757795cfced5ba040a`.

### RC-1059→1084 terminology + interpretation safety

`lib/src/interpretation/terminology_and_safety.dart` merkezi TR/EN glossary, Vedik technical-term retention, explicit `interpretationVersion`, calculation fact ↔ rule subject/condition matching, placeholder allow-list, duplicate suppression, conflicting factor preservation ve calculated-data/traditional-interpretation ayrımını uygular. Medical diagnosis, legal certainty, financial guarantee ve death-date certainty fail-closed yasaktır.

Production `f77cb92f9ee11ef81c7b86f19b15b89bf99a3769`; regression `17c8f0084955c4f7a153e1adc2bdbd132c925344`; contract `8556d422258bcc04b17d4788d3433f9337614411`; validator `1ce30a139fa3a5f5cfaa3a73860c1e5dd7853b30`; CI `4c6a590598a67106900b623668b0e20a192b019b`. Checkpoint anında dedicated `validate` işi queued olduğundan lifecycle elle yükseltilmedi.

### RC-1085→1104 entitlement + monetization resilience

Mevcut merkezi `RuhFeatureIds` / `RuhFeatureCatalog` / `PolicyEntitlementService` korunarak `FeatureAccessGuard` UI + menu + route + service yüzeylerinde aynı Feature ID kararına bağlandı. Menu parity production `9dcd68bcfaa97461f53bc171228156461273f16a`, regression `0ad05ce425243797553c6b653c7cb41880efa8fc`.

`lib/src/entitlements/monetization_resilience.dart` satın alma/reklam failure/cancel/unavailable durumunda entitlement state'in değiştiğini iddia etmeyi fail-closed reddeder; kullanıcı verisini ve önceden hesaplanmış Free sonucu aynen korur; local+entitled PRO capability için offline usability açıkça modellenir. Production `7c9fea4398a22ddd6bb0c2929c88f90ca84d4c3d`; regression `9520e4b6930c0c4eb509db796573bc1827b9225e`.

Exact contract `1c0bc13a85850611ab379c17c09ded3a5fa5b090`; validator `b3c1602486b140647bb1370c07b5c8c7c8913e8e`; CI `692b85c8bbe8a8e30f923809131467dad1216c6d`. Existing rewarded temporary access, rollback-resistant local time anchor ve Google Play lifetime ownership cache/test zinciri de contract evidence'e dahil edildi. Real Play/ad SDK/device proof ve exact release açık.

### RC-1105→1130 offline startup + legal/dependency governance

`lib/src/architecture/offline_startup_and_dependency_governance.dart` eklendi (`43fa1b98a7ba266bada079d5a124c5d6767bb797`). Local database/settings gibi başlangıç işleri network bekleyemez; monetization/harici network işi local-ready sonrasına bırakılır. `VerificationReferencePolicy` QA kaynağını runtime bağımlılığına otomatik çevirmeyi engeller. `DependencyChangeGate` CI + calculation regression + PDF regression + backup round-trip + lockfile olmadan release promotion'ını reddeder.

`governance/runtime_license_inventory.json` eklendi (`cdcd756874ab204112fcaae73a447db78fd852c5`). GeoNames bundled city catalog repository'deki mevcut `CC BY 4.0` attribution ile approved kaydedildi. `assets/data/eop/finals2000A.all` ve `assets/data/ephemeris/de440s.bsp` için repository içinde exact lisans kanıtı bulunmadığından lisans uydurulmadı; `review_required` + runtime redistribution blocked tutuldu. Tüm pubspec package dependency'leri envantere alındı; package lisansları doğrulanana kadar review_required. AKİLES ve Swiss Ephemeris `development_qa_reference_only`, runtimeApproved=false.

Regression `13c25bc130c5b81534ccacffeb9ae1dd63bc39ec`; exact contract `f48e88ecf9acca2825f36ccdfd04bbebbb18b24a`; fail-closed validator `fed960909d995d57c2531cdb4dda1d39a48bd414`; dedicated calculation/PDF/backup-gated CI `9b4b098f061098dba3208acda3a9bf962629fda3`.

RC-1123 kontrolünde `pubspec.lock` fiziksel olarak bulunamadı. Bu eksik saklanmadı: `.github/workflows/materialize-pubspec-lock.yml` (`be034cf31842ee618940893f18ececb30a813793`) Flutter 3.44.7 ile exact dependency graph üretip lockfile'ı main'e commit edecek şekilde eklendi. Checkpoint anında materialize işi queued ve `pubspec.lock` hâlâ yok; RC-1123 DONE/TESTED değildir.

## Açık blocker'lar

Authoritative independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; historical timezone/DST/polar golden fixtures; production localization catalog integration; rendered TR/EN UI/PDF/share cards; interpretation/editorial QA; EOP/DE440s exact redistribution/license evidence; dependency license approvals; committed lockfile; encrypted persistence/key management; production migration corpus; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode physical device proof; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact açık. RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-1059→1084, RC-1085→1104 ve RC-1105→1130 dedicated CI/matrix sonuçlarını fiziksel olarak yeniden oku; kırmızıysa root-cause düzelt, yeşil promotion varsa yalnız kanıtlanan lifecycle seviyesini kaydet.
2. `materialize-pubspec-lock` sonucunu doğrula; lockfile oluşmazsa aynı çalıştırmada kök nedeni düzelt. Lock oluşsa bile lisans review blocker'ları kalkmadan RC-1111→1123 release seviyesine yükselme.
3. Binding sırada RC-1131+ GitHub branch/PR/review/release governance ve release artifact traceability maddelerini exact şartnameden ilerlet; mevcut direct-main çalışma gerçeğini saklamadan blocker olarak ele al.
4. RC-0995→1003 exact AKİLES provenance/independent goldens ve RC-0965→0994 traceability açıklarını paralel azalt.
5. RC-0001→RC-1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL deme.

**FINAL: NO.**
