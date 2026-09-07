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
- **RC-0271→0305 = IMPLEMENTED + blocked=YES**; production/test/contract/validator/dedicated CI zinciri eklendi. Physical TESTED promotion henüz kanıtlanmadı.

## Son çalıştırmadaki gerçek geliştirme — RC-0271→0305

Bağlayıcı 271→305 maddeleri yeniden okundu. Professional PDF, TR/EN rapor, PDF'nin uygulama hesaplama sonucuyla aynı kaynaktan beslenmesi, Free/PRO tek-uygulama sınırı, Free temel değer, rewarded günlük premium açılım, reklamsız PRO, gelişmiş PRO yüzeyleri ve monetizasyon/calculation ayrımı machine-testable application contract olarak kuruldu.

- `lib/src/application/product/report_entitlement_core.dart` (`ba4a4e37d7039e29fffe2d07ccd35007d68a0349`): `CalculationResultRef` + report section/document modeli; rapor katmanında yeniden hesaplama callback/engine'i yok. TR/EN locale explicit. Tek uygulama `AppTier.free/pro`, anlamlı Free temel seti, advanced PRO seti, temporary rewarded daily unlock, reklamsız PRO ve tier'dan bağımsız calculation truth.
- `test/application/product/report_entitlement_core_test.dart` (`3e9e1d56d7841738238c5bef868a52b939fc3b26`): TR/EN aynı manifest kaynağı, PRO-only PDF, Free temel değer, advanced PRO sınırı, expiry/scoped rewarded unlock ve calculation-result identity regressions.
- `requirements/contracts/rc0271_rc0305_report_entitlement_contract.json` (`2a89351b1f3099310c27ef6ab3ff86729d25c0c0`).
- `tools/requirements/validate_rc0271_rc0305_report_entitlement.py` (`a7d5b64deedc9ef450601668392b54e690c72e2e`): binding `271.`→`305.` satırlarını anchored doğrulayan fail-closed validator; report-specific recalculation yüzeylerini yasaklıyor.
- `.github/workflows/rc0271-rc0305-report-entitlement.yml` (`ab24521e7311d6b22091eb4b987bab22dca5923a`): unique concurrency, validator + Flutter regression ve yalnız başarılı physical main run sonrası TESTED matrix promotion.
- Physical workflow run `34141015875` oluşturuldu; son kontrolde `queued`, conclusion `null`. Bu nedenle RC-0271→0305 TESTED/DONE yapılmadı.

## Açık blocker'lar

Real rendered TR/EN PDF artifacts, production Calculation Manifest storage/wiring, gerçek ad/rewarded ve PRO entitlement sağlayıcıları, rendered Free/PRO UI/store lifecycle, offline/device/accessibility/security/performance/clean-checkout/lifecycle/exact-release kapıları açık. Eski AKİLES, Panchanga/Vedic promotion ve RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-0212→0270 ve RC-0271→0305 physical CI/promotion sonuçları yeniden okunacak; kırmızıysa exact job/log root-cause düzeltilecek.
2. Binding sıra RC-0306+ Calculation Manifest / reproducibility / Calculation QA ayrımı üzerinden devam edecek.
3. RC-0158→0184, RC-0127→0134, RC-0119→0122 ve Panchanga physical promotion açıkları kapatılacak.
4. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapılmayacak.
5. 1.442 RC tamamı DONE ve tüm final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**