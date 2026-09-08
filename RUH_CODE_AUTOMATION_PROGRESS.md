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
- RC-1040→1058 = runtime invariance/localization boundary + regression + exact contract + fail-closed validator + dedicated matrix-writing CI eklendi; CI/promotion sonucu görülmeden lifecycle yükseltilmeyecek.
- RC-1059→1084 = terminology/versioned interpretation matching/safety boundary + regression + exact contract + fail-closed validator + dedicated matrix-writing CI eklendi; CI/promotion sonucu görülmeden lifecycle yükseltilmeyecek.

## Son çalıştırmada yapılan gerçek geliştirme

### RC-1004→1039 physical promotion

Önceki edge-validity gate'i GitHub Actions tarafından başarıyla matrix'e yazıldı: `fb71d1b9703f35a4dec499e7d7de33151d57a75e` (`requirements(rc1004-rc1039): record edge validity IMPLEMENTED`). Bu yalnız IMPLEMENTED kanıtıdır; authoritative golden/reference corpus, exact AKİLES provenance, historical timezone/polar fixtures, rendered UI ve exact-release evidence açık olduğundan TESTED/VERIFIED/DONE değildir.

### RC-1040→1058 runtime calculation invariance + localization isolation

`lib/src/calculation_core/runtime_invariance.dart` eklendi. Stored calculation context kendi subject/local datetime/IANA timezone/UTC instant değerini taşır; ambient cihaz timezone'u calculation identity'ye giremez. `CurrentCalculationContext` yalnız gerçekten “şimdi” hesaplarında explicit timezone + UTC instant kabul eder. `CanonicalDecimal` calculation core sınırında yalnız locale-independent noktalı canonical decimal kabul eder; `12,50` gibi locale sunum metni core içinde yorumlanmaz. Device model, UI language, system timezone ve decimal separator presentation environment olarak calculation key'in dışında tutulur.

TR/EN system text için `LocalizationCatalogPair` exact key parity ister ve eksik key'de fail-closed davranır. `UserDataLocalizationBoundary` müşteri adı/not/kullanıcı metnini localization key resolver'a sokmadan verbatim korur.

Regression: `test/calculation_core/runtime_invariance_rc1040_rc1058_test.dart`.
Contract: `requirements/contracts/rc1040_rc1058_runtime_invariance_contract.json`.
Validator: `tools/requirements/validate_rc1040_rc1058_runtime_invariance.py`.
CI: `.github/workflows/rc1040-rc1058-runtime-invariance.yml`.

Ana commitler: production `40ad23a74b0b8e029f95ce46c9e5420d26f1729e`; compile-safe correction `ae648969685c49a990e698f0d7b00cd0ca3a0c97`; regression `0fda2b3298d49ac2e39b6893f06e8577e925d71a` + const fix `c0797b22d225a1b21f3834c85a9784506b185dc0`; contract `11b29e654287b55c25a376e8d385d7bab69339a7`; validator `faff7f57b34ee246aaeca8314722be3b50578c9a`; CI `c46c0e4af58c282cfc0c5e916eac87d948f89025`.

Yeni workflow fiziksel olarak tetiklendi ve checkpoint anında queued durumundaydı; bu nedenle matrix elle yükseltilmedi.

### RC-1059→1084 terminology + interpretation safety

`lib/src/interpretation/terminology_and_safety.dart` eklendi. Merkezi glossary `Ascendant/Yükselen`, `House/Ev` ve Vedik teknik terimlerini tek key üzerinden tutar. `InterpretationRule` explicit `interpretationVersion`, subject ve condition taşır; `InterpretationRuleMatcher` Sun/Moon gibi yanlış subject eşleşmesini fail-closed reddeder. Placeholder'lar allow-list ile doğrulanır ve doldurulmamış placeholder render edilemez. `InterpretationComposer` tekrarları kaldırır fakat çelişkili faktörleri tek kesin hükme sıkıştırmadan ayrı korur. Astronomik/numerolojik veri ile geleneksel yorum ayrı etiketlenir.

`InterpretationSafetyPolicy` medical diagnosis, legal certainty, financial guarantee ve death prediction certainty kategorilerini fail-closed yasaklar.

Regression: `test/interpretation/terminology_and_safety_rc1059_rc1084_test.dart`.
Contract: `requirements/contracts/rc1059_rc1084_interpretation_safety_contract.json`.
Validator: `tools/requirements/validate_rc1059_rc1084_interpretation_safety.py`.
CI: `.github/workflows/rc1059-rc1084-interpretation-safety.yml`.

Ana commitler: production `f77cb92f9ee11ef81c7b86f19b15b89bf99a3769`; regression `17c8f0084955c4f7a153e1adc2bdbd132c925344`; contract `8556d422258bcc04b17d4788d3433f9337614411`; validator `1ce30a139fa3a5f5cfaa3a73860c1e5dd7853b30`; CI `4c6a590598a67106900b623668b0e20a192b019b`.

## Açık blocker'lar

Authoritative independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; historical timezone/DST/polar golden fixtures; production localization catalog integration; rendered TR/EN UI/PDF/share cards; interpretation/editorial QA; encrypted persistence/key management; production migration corpus; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact açık. RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-1040→1058 ve RC-1059→1084 dedicated CI/matrix sonuçlarını fiziksel olarak yeniden oku; kırmızıysa root-cause düzelt, yeşil promotion varsa yalnız kanıtlanan lifecycle seviyesini kaydet.
2. RC-0995→1003 için exact AKİLES provenance ve bağımsız authoritative golden değerleri bulunmadan promotion yapma; blocker dışındaki bağımsız işi sürdür.
3. Binding sırada RC-1085+ entitlement/Free-PRO maddelerini exact şartnameden yeniden oku ve bağımlılık sırasıyla gerçek kod/test/CI üret.
4. RC-0965→0994 traceability açığını requirement-by-requirement azalt.
5. RC-0001→RC-1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL deme.

**FINAL: NO.**
