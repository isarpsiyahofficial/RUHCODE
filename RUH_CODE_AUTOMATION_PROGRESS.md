# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- Önceki physical matrix durumları korunur; RC-0002 DONE ve physical TESTED promotion ile kanıtlanan hatlar geriye düşürülmez.
- **RC-0061 = IMPLEMENTED + blocked=YES**; active house-system product evidence açık.
- **RC-0062 = NOT_STARTED/unresolved promotion**; natal-chart dedicated gate physical promotion sorunu atlanmadı.
- **RC-0082→0083 = NOT_STARTED/blocked**; eski exact ayanamsha run'ındaki Analyze/validator problemi ayrıca kapatılacak.
- **RC-0086→0087 = IMPLEMENTED + blocked=YES**; physical promotion ayrıca doğrulanacak.
- **RC-0092→0093 = TESTED + blocked=YES** (`abac51f4676c4bdb78b7e4befdf8d5b3e2b5ac32`).
- **RC-0096→0098 = TESTED + blocked=YES** (`98f233713258fa17fd4d91bd4fb0e6e8e4d31603`).
- **RC-0099→0101 = TESTED + blocked=YES** (`f3facba3e0be477fc88d4f7e3af959573a13121b`).
- **RC-0102→0104 = TESTED + blocked=YES** (`7e6a91721ddd00ab6aeef8443a7fec5eb87dee84`).
- **RC-0105→0110 = TESTED + blocked=YES** (`4bcd3593b39c7aa1b673178c3755b66ad02065af`).
- **RC-0111, RC-0113, RC-0115, RC-0116, RC-0117 = IMPLEMENTED + blocked=YES** at `b8dba27395f4e7a9ece0431b0927eada1c7571eb`; dedicated physical CI/promotion sonucu bekleniyor.
- **RC-0112 ve RC-0114 = NOT_STARTED/blocked**; Panchanga umbrella, Vara doğrulanmadan kapatılmayacak. Vara civil weekday shortcut ile değil, location-aware sunrise boundary ile yapılacak.

## Bu turdaki gerçek geliştirme

### RC-0111 Gochara

- `lib/src/calculation_core/vedic/vedic_gochara.dart` eklendi.
- Explicit TT üzerinde independent `VedicCalculationEngine` kullanır; Western transit/chart katmanını import etmez.
- Ephemeris + ayanamsha provenance korunur; duplicate/empty body set fail-closed.

### RC-0113 / RC-0115 / RC-0116 / RC-0117 Panchanga çekirdeği

- `lib/src/calculation_core/vedic/vedic_panchanga.dart` eklendi.
- Tithi: normalize Moon-Sun elongation / 12°.
- Daily Nakshatra: sidereal Moon / 13°20′.
- Yoga: normalize sidereal Sun+Moon / 13°20′.
- Karana: Moon-Sun elongation / 6°; Kimstughna + 7 movable repeating + Shakuni/Chatushpada/Naga fixed sequence.
- TT, ephemeris, ayanamsha provenance veya Sun/Moon completeness bozuksa fail-closed.
- Regression, exact contract, fail-closed validator ve dedicated Flutter/matrix gate aynı committe eklendi.

## Açık product-facing / global blocker'lar

RC-0042/0044/0046/0048/0049 product-facing açıkları; RC-0061 active house-system UI; RC-0068+ rendered product UI/interpretation/entitlement kanıtları; independent editorial/astronomy golden evidence; exact AKİLES provenance; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. RC-0111/0113/0115/0116/0117 exact CI/promotion sonucu okunacak; kırmızıysa aynı gate kök nedeni düzeltilecek.
2. RC-0114 Vara için location-aware sunrise boundary altyapısı kurulacak; ardından RC-0112 Panchanga umbrella gate kapatılacak.
3. RC-0082/0083 kırmızı Analyze/validator sorunu ve RC-0086/0087/RC-0062 physical promotion açıkları ayrıca çözülecek.
4. Sonraki bağımsız sıra RC-0118 Vedik yogalar → RC-0119 Ashtakavarga → RC-0120 Shadbala → RC-0121 Vedik gezegen güçleri; entitlement/trace requirement'ları zayıflatılmayacak.
5. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**