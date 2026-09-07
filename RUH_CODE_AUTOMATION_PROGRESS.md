# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- RC-0061 = IMPLEMENTED + blocked=YES; RC-0062 unresolved promotion.
- RC-0082→0083 = NOT_STARTED/blocked; RC-0086→0087 = IMPLEMENTED + blocked=YES.
- RC-0099→0101 = TESTED + blocked=YES (`f3facba3e0be477fc88d4f7e3af959573a13121b`).
- RC-0102→0104 = TESTED + blocked=YES (`7e6a91721ddd00ab6aeef8443a7fec5eb87dee84`).
- RC-0105→0110 = TESTED + blocked=YES (`4bcd3593b39c7aa1b673178c3755b66ad02065af`).
- RC-0112, RC-0114 = TESTED + blocked=YES (`5c6266c5af635e81c963c3c7255c6973875103fe`).
- RC-0118 = TESTED + blocked=YES (`28c73506c796bb9ab3d045e4ba36ca16ee6b6737`).
- RC-0111/0113/0115/0116/0117 = IMPLEMENTED + blocked=YES; RC-0119→0122 = IMPLEMENTED + blocked=YES.
- RC-0123 = TESTED + blocked=YES (`c29fbb359fee9dd0bf501d8cb7fd195c94a15638`).
- RC-0124→0126 = NOT_STARTED/blocked; exact AKİLES provenance yok.
- RC-0127→0134 = IMPLEMENTED + blocked=YES; RC-0135 = TESTED + blocked=YES (`919afe87d349b4dd61b531830d3927ed43d08aa5`); RC-0136 = TESTED + blocked=YES (`cec58ff86d9631ffce36190581e633f5b35f61a4`).
- RC-0137→0141 = TESTED + blocked=YES (`6d639ca3deceeb1b88892e3ca02b02b6cb5fbbfc`).
- RC-0142→0148 = TESTED + blocked=YES (`e076b1d4698aee48f3a07f49448a27ebee04afde`).
- RC-0149→0153 = TESTED + blocked=YES (`85edfde6f2064991a47cfef2ee10a6c13d923d7e`).
- RC-0154→0157 = TESTED + blocked=YES (`d4c6b14bf6c09ea2ae6830d445148850bc8b0048`).
- RC-0158→0165 = IMPLEMENTED + blocked=YES; RC-0166→0184 = IMPLEMENTED + blocked=YES.
- RC-0185→0186 = TESTED + blocked=YES (`d6413c46c5d7dcf5cd4197f1dbd8a30335db2391`).
- RC-0187→0211 = TESTED + blocked=YES (`ef1dba9efb73d9ce0c5bc852548f704e5dd26aa4`).
- RC-0212→0223 = IMPLEMENTED + blocked=YES; physical TESTED promotion commit’i henüz görülmedi.
- RC-0224→0229 = IMPLEMENTED + blocked=YES; physical TESTED promotion commit’i henüz görülmedi.
- RC-0230→0247 = IMPLEMENTED + blocked=YES; physical TESTED promotion henüz kanıtlanmadı.
- RC-0248→0270 = IMPLEMENTED + blocked=YES; physical TESTED promotion henüz kanıtlanmadı.
- RC-0271→0305 = IMPLEMENTED + blocked=YES; physical TESTED promotion henüz kanıtlanmadı.
- **RC-0306→0323 = IMPLEMENTED + blocked=YES**; production/test/contract/validator/dedicated CI zinciri eklendi. Physical TESTED promotion henüz kanıtlanmadı.

## Son çalıştırmadaki gerçek geliştirme

### RC-0271→0305 — professional PDF + Free/PRO boundary

Bağlayıcı 271→305 maddeleri yeniden okundu. Professional PDF, TR/EN rapor, PDF'nin uygulama hesaplama sonucuyla aynı kaynaktan beslenmesi, Free/PRO tek-uygulama sınırı, Free temel değer, rewarded günlük premium açılım, reklamsız PRO, gelişmiş PRO yüzeyleri ve monetizasyon/calculation ayrımı machine-testable application contract olarak kuruldu.

- `lib/src/application/product/report_entitlement_core.dart` (`ba4a4e37d7039e29fffe2d07ccd35007d68a0349`).
- `test/application/product/report_entitlement_core_test.dart` (`3e9e1d56d7841738238c5bef868a52b939fc3b26`).
- `requirements/contracts/rc0271_rc0305_report_entitlement_contract.json` (`2a89351b1f3099310c27ef6ab3ff86729d25c0c0`).
- `tools/requirements/validate_rc0271_rc0305_report_entitlement.py` (`a7d5b64deedc9ef450601668392b54e690c72e2e`).
- `.github/workflows/rc0271-rc0305-report-entitlement.yml` (`ab24521e7311d6b22091eb4b987bab22dca5923a`). Physical run `34141015875` son kontrolde queued/conclusion=null; TESTED verilmedi.

### RC-0306→0323 — Calculation Manifest + reproducibility + QA separation

Bağlayıcı 306→323 maddeleri implementation seviyesine getirildi.

- `lib/src/calculation/calculation_manifest.dart` (`63c2c91ecb83a8269067587d3ad6e11248bb72e1`): engine ID/version, tropical/sidereal, house system, ayanamsha, node system, timezone DB version, coordinate, UTC/local time, timezone ID ve explicit assumptions tek reproducibility record içinde tutuluyor. Historical artifact engineVersion bilgisini kaybetmiyor.
- Calculation ve interpretation ayrı artifact türleri; biri diğerinin digest/provenance alanı değil.
- `QaRecord` Calculation QA yapılmadan Interpretation QA'ya izin vermiyor; hesaplama doğru/yorum yanlış ve hesaplama yanlış/yorum doğru durumları birbirini maskelemiyor.
- `test/calculation/calculation_manifest_rc0306_rc0323_test.dart` (`8207cd0161323f35fa189d4144ede61916d1a238`).
- `requirements/contracts/rc0306_rc0323_calculation_manifest_contract.json` (`ce99df726e4a36f038cbf70ff69eb3f0477da7f3`).
- `tools/requirements/validate_rc0306_rc0323_calculation_manifest.py` (`617185f6ded651a30b91bdd367e0cc2ab4bd28c5`).
- `.github/workflows/rc0306-rc0323-calculation-manifest.yml` (`05086d7317aeae1c8a73e5b7026d37d96e6e8168`): unique concurrency, validator + Flutter regression, successful physical main run sonrası TESTED matrix promotion. Yeni HEAD workflow'ları fiziksel olarak oluştu ancak son kontrolde queued; promotion kanıtlanmadı.

## Açık blocker'lar

Real rendered TR/EN PDF artifacts, production Calculation Manifest persistence/wiring, independent golden/reference datasets, interpretation provenance/editorial QA, gerçek ad/rewarded ve PRO entitlement sağlayıcıları, rendered Free/PRO UI/store lifecycle, offline/device/accessibility/security/performance/clean-checkout/lifecycle/exact-release kapıları açık. Eski AKİLES, Panchanga/Vedic promotion ve RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-0212→0323 physical CI/promotion sonuçları yeniden okunacak; kırmızıysa exact job/log root-cause düzeltilecek.
2. Binding sıra RC-0324+ reference/golden calculation QA setleri ve boundary/DST testleri üzerinden devam edecek.
3. RC-0158→0184, RC-0127→0134, RC-0119→0122 ve Panchanga physical promotion açıkları kapatılacak.
4. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapılmayacak.
5. 1.442 RC tamamı DONE ve tüm final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**