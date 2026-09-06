# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- Önceki physical matrix durumları korunur; RC-0002 DONE ve physical TESTED promotion ile kanıtlanan hatlar geriye düşürülmez.
- **RC-0061 = IMPLEMENTED + blocked=YES**; active house-system product evidence açık.
- **RC-0062 = NOT_STARTED/unresolved promotion**; natal-chart dedicated gate physical promotion sorunu atlanmadı.
- **RC-0082→0083 = NOT_STARTED/blocked**; eski exact ayanamsha run'ındaki Analyze/validator problemi ayrıca kapatılacak.
- **RC-0086→0087 = IMPLEMENTED + blocked=YES**; physical promotion ayrıca doğrulanacak.
- **RC-0099→0101 = TESTED + blocked=YES** (`f3facba3e0be477fc88d4f7e3af959573a13121b`).
- **RC-0102→0104 = TESTED + blocked=YES** (`7e6a91721ddd00ab6aeef8443a7fec5eb87dee84`).
- **RC-0105→0110 = TESTED + blocked=YES** (`4bcd3593b39c7aa1b673178c3755b66ad02065af`).
- **RC-0112, RC-0114 = TESTED + blocked=YES** (`5c6266c5af635e81c963c3c7255c6973875103fe`).
- **RC-0118 = TESTED + blocked=YES** (`28c73506c796bb9ab3d045e4ba36ca16ee6b6737`).
- **RC-0111, RC-0113, RC-0115, RC-0116, RC-0117 = IMPLEMENTED + blocked=YES**; cancelled initial gate was explicitly retriggered at `abda6575a466cb9463dae15957a69a44d195f2dc`. Physical promotion still required before TESTED.
- **RC-0119 = IMPLEMENTED + blocked=YES**. Production `38a2633f7f6bfca5c72c3fb18568491b05b37694`, regressions `08b64627ebf2b9d36f28e4db5fb4f1aa9b9fec01`, contract `186bb7189ed9d73cc9df02bf2878169aee8f4fe6`, validator `75e2e89cae51049e11da03b36d82d5d904780468`, dedicated gate `29b9ad5d66fa5806a31370fa254cd6903963a52c`. Physical promotion pending.

## Bu turdaki gerçek geliştirme

### RC-0118 promotion doğrulaması

- Physical bot promotion `28c73506c796bb9ab3d045e4ba36ca16ee6b6737` doğrulandı; RC-0118 yalnız TESTED seviyesine yükseltildi.
- Verified yoga catalog/source evidence, professional rendered UI, entitlement ve device/release kapıları açık olduğundan VERIFIED/DONE verilmedi.

### RC-0111/0113/0115/0116/0117 Panchanga/Gochara gate retrigger

- Önceki cancelled dedicated gate yeniden tetiklendi (`abda6575a466cb9463dae15957a69a44d195f2dc`).
- Promotion blocker metni RC-0112/RC-0114 artık TESTED olduğu için güncellendi; bu iki madde eski blocker olarak tutulmuyor.
- Bot promotion fiziksel olarak oluşmadan bu beş requirement TESTED ilan edilmeyecek.

### RC-0119 Ashtakavarga rule-data + deterministic evaluator

- `lib/src/calculation_core/vedic/vedic_ashtakavarga.dart` eklendi.
- Unverified klasik bindu tabloları runtime gerçeği olarak hard-code edilmedi; evaluator explicit `id/version/sourceId` taşıyan rule-set istiyor.
- Graha veya Lagna contributor kaynakları ve contributor-relative 1..12 favorable-house kuralları ile Bhinna bindu satırları deterministic üretiliyor.
- Sarvashtakavarga toplamları aynı Bhinna satırlarından türetiliyor; ayrı/uydurma hesap yok.
- Missing contributor, duplicate subject/contributor rule, invalid relative house ve invalid chart provenance fail-closed.
- Compiled regression, exact requirement contract, fail-closed validator ve dedicated Flutter/matrix promotion workflow main üzerinde.
- Authoritative classical rule-data provenance + independent golden/reference karşılaştırması bulunmadan VERIFIED/DONE verilmeyecek.

## Açık product-facing / global blocker'lar

RC-0042/0044/0046/0048/0049 product-facing açıkları; RC-0061 active house-system UI; RC-0068+ rendered product UI/interpretation/entitlement kanıtları; independent editorial/astronomy golden evidence; exact AKİLES provenance; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. RC-0119 exact CI/promotion sonucu okunacak; kırmızıysa validator/test/analyzer kök nedeni aynı hatta düzeltilecek.
2. RC-0111/0113/0115/0116/0117 retrigger sonucunda physical promotion doğrulanacak; kırmızıysa job/log kök nedeni kapatılacak.
3. RC-0120 Shadbala için Sthana/Dig/Kala/Chesta/Naisargika/Drik bileşenleri kanıtsız tek skora indirgenmeyecek; versioned component-evidence mimarisi kurulacak.
4. RC-0121 Vedik gezegen güçleri Shadbala ile aynı requirement gibi birleştirilmeyecek; ayrı aggregation/provenance kapısı olacak.
5. RC-0082/0083 kırmızı Analyze/validator sorunu ve RC-0086/0087/RC-0062 physical promotion açıkları ayrıca çözülecek.
6. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**