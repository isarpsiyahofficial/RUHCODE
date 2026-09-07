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
- **RC-0111, RC-0113, RC-0115, RC-0116, RC-0117 = IMPLEMENTED + blocked=YES**; cancelled initial gate retriggered at `abda6575a466cb9463dae15957a69a44d195f2dc`; physical promotion still required.
- **RC-0119 = IMPLEMENTED + blocked=YES**. Gate `29b9ad5d66fa5806a31370fa254cd6903963a52c`; physical promotion still pending.
- **RC-0120 = IMPLEMENTED + blocked=YES**. Gate `d13e7bdec28ed7c24f9d6b04546c4be9db817a6e`; physical promotion still pending.
- **RC-0121 = IMPLEMENTED + blocked=YES**. Gate `cfe29e29a7b7f485130ce54b9484bace41ca10ff`; physical promotion still pending.
- **RC-0122 = IMPLEMENTED + blocked=YES**. Gate `7139a6af49b975bd52a1e97693234c62ad592959`; physical promotion still pending.
- **RC-0123 = TESTED + blocked=YES**. Physical bot promotion `c29fbb359fee9dd0bf501d8cb7fd195c94a15638`; checkpointteki önceki gate SHA yazımı düzeltilerek gerçek gate `c7f11f0bb3f9b93f0b9b51247bc93120f6cec0f4` olarak doğrulandı.
- **RC-0124→0126 = NOT_STARTED/blocked**. Exact AKİLES algorithm + sunrise/sunset source/version/hash/golden provenance repository'de henüz yok; mevcut NOAA/GML/Meeus solar core bu requirement'ları AKİLES diye kapatmak için kullanılamaz.
- **RC-0127→0134 = IMPLEMENTED + blocked=YES**. Existing production planetary-hours core için requirement-specific regression `test/calculation_core/planetary_hours_rc0127_rc0134_test.dart`, contract, fail-closed validator ve dedicated gate eklendi. Gate fix HEAD `315887370b044b516c529de4417c996718120f0c`; physical run `34068566861` son kontrolde queued, bu yüzden TESTED promotion henüz verilmedi.
- **RC-0135 = IMPLEMENTED + blocked=YES**. Source-tagged complete guidance model + compiled regression + contract + validator + dedicated gate eklendi; gate `435d274dba740b11da7fc1d115ebc53c06494aa1`. Authoritative TR/EN editorial catalog, entitlement/UI ve physical CI promotion açık.
- **RC-0136 = NOT_STARTED/blocked**; timezone/DST rendered behavior bağımsız requirement olarak korunuyor.

## Bu turdaki gerçek geliştirme

### RC-0123 physical promotion düzeltmesi

- Önceki checkpointte gate SHA yanlış kaydedilmişti; gerçek gate `c7f11f0bb3f9b93f0b9b51247bc93120f6cec0f4` ve physical bot promotion `c29fbb359fee9dd0bf501d8cb7fd195c94a15638` doğrulandı.
- RC-0123 yalnız TESTED seviyesine yükseltildi; authoritative Muhurta rule-data/golden, UI/entitlement/device/release kapıları açık olduğundan VERIFIED/DONE verilmedi.

### RC-0124→0126 AKİLES blocker doğrulaması

- Existing `planetary_hours.dart` gerçek sunrise/sunset/next-sunrise tabanlı 12+12 calculation yapıyor, ancak solar implementation repository'de NOAA/GML/Meeus-derived olarak tanımlı.
- `rc0005-akiles-reference.yml` exact AKİLES source/artifact/version/commit/hash/capture reference eksikliğini açık blocker olarak tutuyor.
- Bu nedenle RC-0124/0125/0126 uydurma eşdeğerlikle TESTED/DONE yapılmadı.

### RC-0127→0134 Planetary Hours structure

- Day arc = sunset − sunrise ve day hour = day arc / 12 compiled regression ile bağlandı.
- Night arc = next sunrise − sunset ve night hour = night arc / 12 compiled regression ile bağlandı.
- Monday fixture'ında first-hour ruler Moon ve tüm 24 slot boyunca Chaldean continuation doğrulanacak şekilde test eklendi.
- Exact 24 contiguous ordered slot listesi test ediliyor.
- İlk regression yazımında production modelinde olmayan `.duration` alanına yanlış başvuru fark edilip aynı turda `endUtc.difference(startUtc)` kullanacak şekilde düzeltildi (`315887370b044b516c529de4417c996718120f0c`).
- Contract/validator AKİLES blocker'ını özellikle koruyor; dedicated workflow physical success olmadan matrix promotion yok.

### RC-0135 Planetary-hour guidance

- Authoritative yorum/mantra metni hard-code edilmedi.
- `PlanetaryHourGuidanceCatalog` yedi klasik gezegenin tamamını zorunlu tutuyor; duplicate/missing planet ve boş editorial/provenance alanları fail-closed.
- 24 slotun her biri planet, start/end, quality, interpretation, PRO action, do-not, mantra, sourceId ve version ile deterministic olarak birleştiriliyor.
- Fixture strings yalnız compiled regression içindir; authoritative TR/EN content evidence yerine geçmez.
- Production `c0c8a3ec55257d709a767570e67494cc65969414`, regressions `58d458ba3b9bf28f146660099173d39ede6b24b3`, contract `a509f689c2c51e48001c1dacc69efdbfcdea3ad1`, validator `060154b99591cc0c0b5ffe72b1ee5c6ad2473238`, gate `435d274dba740b11da7fc1d115ebc53c06494aa1`.

## Açık product-facing / global blocker'lar

RC-0042/0044/0046/0048/0049 product-facing açıkları; RC-0061 active house-system UI; RC-0068+ rendered product UI/interpretation/entitlement kanıtları; independent editorial/astronomy golden evidence; exact AKİLES provenance; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. RC-0127→0135 dedicated workflow/promotion sonuçları fiziksel olarak okunacak; kırmızıysa exact validator/test/analyzer root cause aynı hatta düzeltilecek.
2. RC-0119→0122 exact CI/promotion ve RC-0111/0113/0115/0116/0117 retrigger sonucu okunacak; physical promotion olmadan TESTED verilmeyecek.
3. RC-0136 timezone/DST behavior product/runtime altyapısı incelenip requirement-specific evidence eklenecek.
4. RC-0124→0126 exact AKİLES source/version/hash/golden provenance bulunmadan AKİLES claim yapılmayacak.
5. RC-0082/0083 kırmızı Analyze/validator sorunu ve RC-0086/0087/RC-0062 physical promotion açıkları ayrıca çözülecek.
6. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**