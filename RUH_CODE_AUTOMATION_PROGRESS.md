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
- RC-0995→1003 = authoritative golden corpus sözleşmesi henüz tamamlanmış değil. `GoldenDatasetPolicy` domain/provenance/edge coverage'ı fail-closed tanımlar; ancak exact AKİLES ve bağımsız production golden değerleri bulunmadan lifecycle promotion yapılmayacak.
- RC-1004→1039 = production edge/validity core + regression + exact contract + fail-closed validator + dedicated matrix-writing CI eklendi. CI/promotion sonucu görülmeden lifecycle yükseltilmeyecek.

## Son çalıştırmada yapılan gerçek geliştirme

### RC-0951→0964 physical promotion

Önceki PDF validation gate'i GitHub Actions tarafından başarıyla matrix'e yazıldı: `5f08942462a0b3784725b9fd7e65de0cc22eb50e` (`requirements(rc0951-rc0964): record PDF validation IMPLEMENTED`). Bu yalnız IMPLEMENTED kanıtıdır; parser/rasterizer, versioned TR/EN golden ve exact-release evidence açık olduğundan TESTED/VERIFIED/DONE değildir.

### RC-0995→1003 authoritative golden corpus sınırı

`lib/src/calculation_core/golden/golden_dataset_policy.dart` eklendi. Western, Vedic, planetary hours, BaZi, Pythagorean, Chaldean ve Lo Shu için bağımsız golden domain zorunluluğu; AKİLES regression case'leri için exact source/version provenance; bütün edge-case coverage ve authoritative fingerprint zorunluluğu tanımlandı. Non-authoritative veya provenance eksik case release corpus'a giremez.

Bu blok bilinçli olarak promotion almıyor: repository'de exact AKİLES source/version değerleri ve bağımsız authoritative Western/Vedic/BaZi/numerology golden corpus tamamlanmadan RC-0995→1003 DONE/IMPLEMENTED sayılmayacak.

### RC-1004→1039 edge-case + fail-closed calculation validity

`lib/src/calculation_core/calculation_validity.dart` eklendi. Burç/0°/29°59′/Nakshatra/Pada/house cusp/retrograde station/sunrise/sunset/DST/historical timezone/30-45 dakikalık timezone/UTC+14/date-line/polar edge taxonomy production seviyesinde tanımlandı.

`CalculationOutcome<T>` sonucu `valid / partial / unavailable / error` olarak explicit taşır. `unavailable/error` durumunda sahte değer üretilemez; `valid/partial` değer gerektirir. `null`/`NaN` teknik metinleri kullanıcı mesajına sızdırılmaz. `MissingBirthTimePolicy`, doğum saati bilinmiyorsa ascendant, houses ve saat isteyen Vedik sonuçları `unavailable` yapar; saat gerektirmeyen hesaplar yalnız `partial` olarak sunulur. `PlanetaryHourAvailabilityPolicy`, güvenilir sunrise/sunset sınırı yoksa özellikle polar koşullarda gezegen saati uydurmaz ve TR/EN açıklama verir. `CalculationDeterminismKey` + `DeterminismGuard`, aynı input/config/engine sürümünün farklı sonucu sessizce üretmesini reddeder.

Regression: `test/calculation_core/calculation_validity_rc1004_rc1039_test.dart`.
Contract: `requirements/contracts/rc1004_rc1039_edge_validity_contract.json`.
Validator: `tools/requirements/validate_rc1004_rc1039_edge_validity.py`.
CI: `.github/workflows/rc1004-rc1039-edge-validity.yml`.

Ana commitler: production `bb3754925e513421a852098af1d1687294bdcd6b` + compile-safe fix `028a769d3809ea790d9e3bbdd63c8926d1b2dd2d`; golden policy `a595cac23df90ada47382ebfe81e98d371cd8f52`; regression `3f44f9eff4bd5b5dbd0ede06632519f1bba7f27d`; contract `afec502773219a4c3a77c215098106180cf1a59a`; validator `f4fa7e672f2de939f03b671bdc4ea8f4604571ca`; CI `42b5c517f98d29d14041d993048b5992d1e23a10`.

Yeni CI çalışmaları fiziksel olarak oluştu ancak checkpoint anında queued durumundaydı; bu nedenle RC-1004→1039 lifecycle elle yükseltilmedi.

## Açık blocker'lar

Authoritative independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; historical timezone/DST/polar golden fixtures; rendered TR/EN UI/PDF/share cards; encrypted persistence/key management; production migration corpus; interpretation/editorial QA; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact açık. RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-1004→1039 dedicated CI/matrix sonucunu fiziksel olarak yeniden oku; kırmızıysa root-cause düzelt, yeşil promotion varsa yalnız kanıtlanan lifecycle seviyesini kaydet.
2. RC-0995→1003 için exact AKİLES provenance ve bağımsız authoritative golden değerleri bulunmadan promotion yapma; blocker dışındaki bağımsız işi sürdür.
3. Binding sırada RC-1040+ maddelerini exact şartnameden yeniden oku ve bağımlılık sırasıyla gerçek kod/test/CI üret.
4. RC-0965→0994 traceability açığını requirement-by-requirement azalt.
5. RC-0001→RC-1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL deme.

**FINAL: NO.**