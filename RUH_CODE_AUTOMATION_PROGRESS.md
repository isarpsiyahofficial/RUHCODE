# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- Önceki physical matrix durumları korunur; RC-0002 DONE ve daha önce physical TESTED promotion ile kanıtlanan hatlar geriye düşürülmez.
- **RC-0061 = IMPLEMENTED + blocked=YES**; active house-system name için gerçek product-screen/widget-device evidence açık.
- **RC-0062 = NOT_STARTED/unresolved promotion**; natal-chart dedicated contract/test/CI mevcut fakat physical promotion hâlâ çözülmemiştir ve atlanmış sayılmaz.
- **RC-0080→0081 = TESTED + blocked=YES** (`de9260ea79934c4f9cee912d451e746512d96943`).
- **RC-0082→0083 = NOT_STARTED/blocked**; exact `9588f2dbd9b240721cbb9dffd7fc34306f25c8af` için görülen Flutter Analyze + requirement-validation failure nedeniyle physical TESTED promotion yok.
- **RC-0084→0085 = TESTED + blocked=YES** (`b9ef26398e5a7d572680d5e8630a2b4a06add8b2`).
- **RC-0086→0087 = IMPLEMENTED + blocked=YES**; production/test/contract/validator/CI mevcut fakat physical `record ... TESTED` promotion henüz bulunamadı.
- **RC-0088→0089 = TESTED + blocked=YES** (`59d31cf362ac2c7a969c5637eb65acd1840a1910`).
- **RC-0090→0091 = TESTED + blocked=YES** (`1eb5112c8d18bb3871d1fedab9d4b06088a0f128`).
- **RC-0092→0093 = TESTED + blocked=YES** (`abac51f4676c4bdb78b7e4befdf8d5b3e2b5ac32`).
- **RC-0094→0095 = IMPLEMENTED + blocked=YES**; calculation regressions PASS. İlk promotion run'ı sonraki Varga refaktörü sonrası stale literal validator nedeniyle kırıldı; validator current semantic evidence'e hizalandı (`2485d0dc3826478a1f237b79e6f4c986ce3b3771`). Physical TESTED promotion bekleniyor.
- **RC-0096→0098 = TESTED + blocked=YES** (`98f233713258fa17fd4d91bd4fb0e6e8e4d31603`).
- **RC-0099→0101 = IMPLEMENTED + blocked=YES**; D16/D20/D24 production, regression, contract, fail-closed validator ve dedicated CI main üzerinde; physical TESTED promotion henüz yok.

## Bu turdaki gerçek geliştirme

### RC-0094 / RC-0095 gate root-cause fix

- İlk dedicated run'da Python binding validator ve Flutter Varga regressions PASS etti.
- Failure yalnız promotion adımında oluştu: D7/D10/D12 refaktörü `vedic_varga.dart` içindeki D3/D4 offset ifadelerini compact biçime çevirmişti; validator eski literal `const offsets = ...` metnini arıyordu.
- Validator mevcut production ve regression kanıtına göre güncellendi. Fix commits: `8d5a9c40a05993e4e2802524e03579266c273d62`, `2485d0dc3826478a1f237b79e6f4c986ce3b3771`.
- Hesaplama formülü değiştirilmedi; yalnız stale evidence binding düzeltildi.

### RC-0099 / RC-0100 / RC-0101

- **Shodasamsa D16:** 16 eşit parça (1.875°). Movable Rashi Aries'ten, fixed Rashi Leo'dan, dual Rashi Sagittarius'tan başlar ve zodiacal ilerler.
- **Vimshamsa D20:** 20 eşit parça (1.5°). Movable Rashi Aries'ten, fixed Rashi Sagittarius'tan, dual Rashi Leo'dan başlar ve zodiacal ilerler.
- **Chaturvimshamsa D24:** 24 eşit parça (1.25°). Odd Rashi Leo'dan, even Rashi Cancer'dan başlar ve zodiacal ilerler.
- Production `08e06456b91cff8181803795e69b9070f2a70f6c`.
- Compiled regressions `d85e4e1fb7f8953d5a6be8f50902e649dc5302a9`.
- Exact contract `21d7395af2233b027bdba14f3589bf7e9a87727d`.
- Fail-closed validator `2379eea67c163bb389f01f0f537c46913490bccc`.
- Dedicated CI/matrix gate `8eeb69ca1e2a8b7f9fb6425ec708214acf55ae1f`.
- Varga shared core duplicate Graha, invalid longitude ve eksik TT/ephemeris/ayanamsha provenance durumlarında fail-closed kalır.

## Açık product-facing / global blocker'lar

RC-0042/0044/0046/0048/0049 product-facing açıkları; RC-0061 active house-system UI; RC-0068+ rendered product UI/interpretation/entitlement kanıtları; independent editorial/astronomy golden evidence; exact AKİLES provenance; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. RC-0094→0095 fixed gate'in exact CI/promotion sonucu okunacak; kırmızıysa exact job/log tekrar çözülecek.
2. RC-0099→0101 dedicated CI/promotion sonucu okunacak; yalnız physical bot promotion varsa TESTED'e yükseltilecek.
3. RC-0082/0083 kırmızı Flutter Analyze + requirement-validation diagnostic'i çözülüp gate yeniden yeşile getirilecek.
4. RC-0086/0087 physical promotion durumu tekrar doğrulanacak.
5. RC-0062 unresolved natal-chart promotion tekrar incelenecek; atlanmayacak.
6. Dependency sırasındaki **RC-0102 Trimsamsa D30 → RC-0103 Shashtiamsa D60 → RC-0104 sistematik diğer Varga altyapısı** yalnız doğrulanabilir klasik matematikle ilerletilecek.
7. Lahiri/Chitrapaksha numerical doğruluğu için bağımsız provider/golden/tolerance kanıtı ayrı kapı olarak kurulacak.
8. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**
