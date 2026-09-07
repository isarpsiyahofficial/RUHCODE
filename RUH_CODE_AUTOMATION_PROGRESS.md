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
- **RC-0123 = TESTED + blocked=YES**. Physical bot promotion `c29fbb359fee9dd0bf501d8cb7fd195c94a15638`; real gate `c7f11f0bb3f9b93f0b9b51247bc93120f6cec0f4`.
- **RC-0124→0126 = NOT_STARTED/blocked**. Exact AKİLES algorithm + sunrise/sunset source/version/hash/golden provenance repository'de henüz yok; mevcut NOAA/GML/Meeus solar core bu requirement'ları AKİLES diye kapatmak için kullanılamaz.
- **RC-0127→0134 = IMPLEMENTED + blocked=YES**. Physical run `34068566861` failure verdi; root cause calculation/test değil validator'ın `RUH_CODE_MASTER_SARTNAME.md` içinde literal `RC-0127` aramasıydı. Bağlayıcı şartname numbered-list kullandığı için validator numbered requirement 127→134 eşlemesine düzeltildi (`25258bbefcfe6b5e754377d8c69f8194bb4b5249`). Yeni physical success/promotion henüz kanıtlanmadı.
- **RC-0135 = IMPLEMENTED + blocked=YES**. Production/test/contract/gate mevcut; validator'daki aynı literal-RC/spec uyuşmazlığı numbered requirement 135 kontrolüne düzeltildi (`12aade619977b9610bda3915008b34bacf7adb5d`). Physical TESTED promotion hâlâ kanıtlanacak.
- **RC-0136 = IMPLEMENTED + blocked=YES**. Önceki progress kaydındaki “timezone/DST” yorumu yanlıştı; bağlayıcı requirement 136 gerçekte “aynı gezegen için haftanın her günü birebir aynı yorum gösterilmeyecek”. 7 gün × 7 klasik gezegen = 49 kombinasyonlu fail-closed weekday-specific guidance katmanı, compiled regression, contract, validator ve dedicated CI gate eklendi. Gate commit `551d862460d15f2654a927be1fdee93ed5bb797b`; physical promotion henüz kanıtlanmadı.

## Bu turdaki gerçek geliştirme

### RC-0127→0134 kırmızı gate root-cause ve repair

- Run `34068566861` fiziksel olarak `failure` ile tamamlandı.
- Job log exact hata: `RC0127_RC0134_FAIL: binding specification no longer contains RC-0127`.
- `RUH_CODE_MASTER_SARTNAME.md` literal RC ID değil `127. ...`, `128. ...` biçiminde numbered binding entries taşıyor. Validator yanlış sözleşme formatı varsayıyordu.
- `tools/requirements/validate_rc0127_rc0134_planetary_hour_structure.py` regex ile line-start numbered requirement kontrolüne geçirildi; `1270` gibi substring false-positive'leri de kabul etmiyor.
- Calculation core değiştirilmedi; AKİLES golden blocker zayıflatılmadı.

### RC-0135 validator repair

- RC-0135 validator'ında da aynı literal `RC-0135` varsayımı bulundu.
- Binding check numbered requirement `135.` eşleşmesine geçirildi; içerik, AKİLES ve Free/PRO blocker'ları korunuyor.

### RC-0136 weekday × planet guidance

- Binding şartname yeniden okununca RC-0136'nın timezone/DST değil, weekday-specific interpretation requirement olduğu doğrulandı.
- Production `PlanetaryHourWeekdayGuidanceCatalog` artık bütün `CivilWeekday × ClassicalPlanet` kombinasyonlarını zorunlu tutuyor: 7×7 = 49 rule.
- Duplicate/missing day-planet combination, empty interpretation/source/version fail-closed.
- Her bir gezegen için yedi günün tamamında tek bir birebir aynı interpretation tekrar edilirse katalog fail-closed; böylece requirement yalnız UI niyeti olarak değil data-model invariant olarak korunuyor.
- `PlanetaryHourWeekdayGuidance.build` aktif `hours.date.weekday` ve gerçek slot ruler'ını birleştirerek 24 slot için weekday-specific guidance üretiyor.
- Fixture strings authoritative content değildir. Source-tagged gerçek TR/EN 49-combination editorial catalog ayrıca gereklidir.
- Production commit `8d3f6db237cc420daa5ab5391cc1f01c39c11042`; regression `8a7b8a93a890f945ab3ba762e5c26a706211b318`; contract `31ca734142e942bc71464447d9fa4ca953e5e6ca`; validator `baa373f5baffb771af99f0a38ed28b82207a90aa`; dedicated gate `551d862460d15f2654a927be1fdee93ed5bb797b`.

## Açık product-facing / global blocker'lar

RC-0042/0044/0046/0048/0049 product-facing açıkları; RC-0061 active house-system UI; RC-0068+ rendered product UI/interpretation/entitlement kanıtları; independent editorial/astronomy golden evidence; exact AKİLES provenance; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. RC-0127→0136 dedicated workflow/promotion sonuçları fiziksel olarak okunacak; kırmızıysa exact validator/test/analyzer root cause aynı hatta düzeltilecek.
2. RC-0119→0122 exact CI/promotion ve RC-0111/0113/0115/0116/0117 retrigger sonucu okunacak; physical promotion olmadan TESTED verilmeyecek.
3. Bağlayıcı şartname sırasındaki **RC-0137 Çin astrolojisi temel 12 hayvan sistemi** ve devam eden RC-0138+ hesaplama requirement'ları, bağımlılıklar doğrulanarak ilerletilecek.
4. RC-0124→0126 exact AKİLES source/version/hash/golden provenance bulunmadan AKİLES claim yapılmayacak.
5. RC-0082/0083 kırmızı Analyze/validator sorunu ve RC-0086/0087/RC-0062 physical promotion açıkları ayrıca çözülecek.
6. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**