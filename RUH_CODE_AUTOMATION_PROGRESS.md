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
- **RC-0111, RC-0113, RC-0115, RC-0116, RC-0117 = IMPLEMENTED + blocked=YES** at `b8dba27395f4e7a9ece0431b0927eada1c7571eb`; initial dedicated run was cancelled before jobs and physical TESTED promotion is still missing.
- **RC-0118 = IMPLEMENTED + blocked=YES**. Production `fe5232177d798cd63ba27afb4da9e96487039da2`, regressions `8b8a85c332cbf7a954d4cf85bed6980550fec0f8`, contract `c972c3493ac8d053af3d2c3f0a340d8f5882b297`, validator `fed5eba8fd7a07e0a1938e30ad61e72880e11c28`, dedicated gate `d9f985a617ddd25ec0db49f0cb35d277d60bbbe9`. Physical promotion pending.

## Bu turdaki gerçek geliştirme

### RC-0112 / RC-0114 promotion doğrulaması

- Panchanga umbrella + sunrise-boundary Vara dedicated hattının physical bot promotion commit'i `5c6266c5af635e81c963c3c7255c6973875103fe` olarak doğrulandı.
- Bu iki requirement yalnız TESTED seviyesinde tutuluyor; real sunrise golden/reference, TR/EN rendered UI ve device/release kanıtları hâlâ blocker.

### RC-0118 Vedik yoga profesyonel değerlendirme çekirdeği

- `lib/src/calculation_core/vedic/vedic_yoga_engine.dart` eklendi.
- Tartışmalı/kanıtsız yoga katalogları hesaplama gerçeği gibi hard-code edilmedi.
- Profesyonel yoga tanımları explicit `id/version/sourceId` provenance ile giriliyor.
- Engine bağımsız sidereal `VedicRashiChart` / Whole Sign verisi üzerinde `sameHouse`, `sameRashi`, `houseDistance` ilişkilerini deterministic değerlendiriyor.
- Duplicate yoga id, kaynak/version eksikliği, invalid house/rashi ve chart provenance eksikliği fail-closed.
- Match çıktısı hem yoga-definition provenance'ını hem ephemeris/ayanamsha provenance'ını koruyor.
- Compiled regression, exact requirement contract, fail-closed validator ve dedicated Flutter/matrix promotion workflow main üzerinde.
- Dedicated workflow run `34056428449` fiziksel olarak oluştu; son kontrolde queued olduğundan RC-0118 henüz TESTED ilan edilmedi.

## Açık product-facing / global blocker'lar

RC-0042/0044/0046/0048/0049 product-facing açıkları; RC-0061 active house-system UI; RC-0068+ rendered product UI/interpretation/entitlement kanıtları; independent editorial/astronomy golden evidence; exact AKİLES provenance; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. RC-0118 exact CI/promotion sonucu okunacak; kırmızıysa validator/test/job kök nedeni aynı hatta düzeltilecek.
2. RC-0111/0113/0115/0116/0117 cancelled dedicated run yeniden fiziksel gate üzerinden ilerletilecek; bot promotion olmadan TESTED denmeyecek.
3. RC-0119 Ashtakavarga için klasik bindu kuralları kaynaklanmadan yaklaşık tablo üretilmeyecek; önce versioned rule-data + deterministic evaluator mimarisi kurulacak.
4. RC-0120 Shadbala ve RC-0121 Vedik gezegen güçleri birbirine karıştırılmadan ayrı provenance/golden kapılarıyla ilerletilecek.
5. RC-0082/0083 kırmızı Analyze/validator sorunu ve RC-0086/0087/RC-0062 physical promotion açıkları ayrıca çözülecek.
6. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**