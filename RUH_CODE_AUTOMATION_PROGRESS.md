# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- Önceki physical matrix durumları korunur; RC-0002 DONE ve physical TESTED promotion ile kanıtlanan hatlar geriye düşürülmez.
- **RC-0061 = IMPLEMENTED + blocked=YES**; active house-system product evidence açık.
- **RC-0062 = NOT_STARTED/unresolved promotion**; natal-chart dedicated gate physical promotion sorunu atlanmadı.
- **RC-0082→0083 = NOT_STARTED/blocked**; eski exact ayanamsha Analyze/validator problemi ayrıca kapatılacak.
- **RC-0086→0087 = IMPLEMENTED + blocked=YES**; physical promotion ayrıca doğrulanacak.
- **RC-0099→0101 = TESTED + blocked=YES** (`f3facba3e0be477fc88d4f7e3af959573a13121b`).
- **RC-0102→0104 = TESTED + blocked=YES** (`7e6a91721ddd00ab6aeef8443a7fec5eb87dee84`).
- **RC-0105→0110 = TESTED + blocked=YES** (`4bcd3593b39c7aa1b673178c3755b66ad02065af`).
- **RC-0112, RC-0114 = TESTED + blocked=YES** (`5c6266c5af635e81c963c3c7255c6973875103fe`).
- **RC-0118 = TESTED + blocked=YES** (`28c73506c796bb9ab3d045e4ba36ca16ee6b6737`).
- **RC-0111, RC-0113, RC-0115, RC-0116, RC-0117 = IMPLEMENTED + blocked=YES**; physical promotion hâlâ kapatılacak.
- **RC-0119→0122 = IMPLEMENTED + blocked=YES**; dedicated gates mevcut, physical promotion sonuçları ayrıca doğrulanacak.
- **RC-0123 = TESTED + blocked=YES** (`c29fbb359fee9dd0bf501d8cb7fd195c94a15638`).
- **RC-0124→0126 = NOT_STARTED/blocked**; exact AKİLES algorithm/source/version/hash/golden provenance yok.
- **RC-0127→0134 = IMPLEMENTED + blocked=YES**; validator/spec repair mevcut, yeni physical TESTED promotion ayrıca kanıtlanacak.
- **RC-0135 = TESTED + blocked=YES** (`919afe87d349b4dd61b531830d3927ed43d08aa5`).
- **RC-0136 = TESTED + blocked=YES** (`cec58ff86d9631ffce36190581e633f5b35f61a4`).
- **RC-0137→0141 = TESTED + blocked=YES** (`6d639ca3deceeb1b88892e3ca02b02b6cb5fbbfc`).
- **RC-0142→0148 = TESTED + blocked=YES**; physical promotion `e076b1d4698aee48f3a07f49448a27ebee04afde` doğrulandı. Authoritative BaZi calendar provider + independent goldens açık.
- **RC-0149→0153 = TESTED + blocked=YES**; physical promotions mevcut (`85edfde6f2064991a47cfef2ee10a6c13d923d7e` latest observed). Seasonal strength değildir; structural occurrence modelidir.
- **RC-0154→0157 = TESTED + blocked=YES**; physical promotion `d4c6b14bf6c09ea2ae6830d445148850bc8b0048`.
- **RC-0158→0165 = IMPLEMENTED + blocked=YES**; production boundary commit `49e04735f9a3fb0f9af2467c34b05387dd71b3af`. BaZi compatibility, standalone Zi Wei boundary ve distinct Pythagorean/Chaldean/Lo Shu system identity kuruldu; physical TESTED promotion henüz kanıtlanmadı.
- **RC-0166→0184 = IMPLEMENTED + blocked=YES**; commit `1b7e85ca1a8b3860b71d7887446bbe11e5d1246e`. Life Path, Expression/Destiny, Soul Urge, Personality, Birthday, Maturity, Balance, Karmic Lessons/Debt, Hidden Passion, Personal Year/Month/Day, Pinnacles, Challenges, source/version-driven compatibility, TR/EN normalization ve Chaldean/Pythagorean mapping ayrımı için production/test/contract/validator/dedicated CI eklendi. Physical promotion sonucu bekleniyor.
- **RC-0185→0186 = IMPLEMENTED + blocked=YES**; commit `338f8c8aa3b9224f8793efcc442863e691f4f634`. Lo Shu doğum-tarihi digit-grid motoru Pythagorean reduction'dan bağımsız; Kabbalistic numerology ayrı future-system contract. Physical promotion sonucu bekleniyor.

## Bu turdaki gerçek geliştirme

### RC-0166→0184 numerology core

- `lib/src/calculation_core/numerology/numerology_core.dart` eklendi.
- Reduction policy explicit/versioned/source-tagged; master-number preservation policy ayrı tanımlı.
- Pythagorean harf tablosu ve Chaldean harf tablosu iki ayrı `NumerologyAlphabet` olarak tutuluyor; Pythagorean name engine Chaldean alphabet verilirse fail-closed.
- Türkçe Ç/Ğ/İ/I/ı/Ö/Ş/Ü karakterleri açık transliteration kuralıyla işleniyor; gelişi güzel silinmiyor.
- Numerology compatibility universal doctrine olarak hard-code edilmedi; version/source-tagged bounded rule engine olarak bırakıldı.
- Regression, exact contract, fail-closed validator ve unique-concurrency dedicated gate aynı committe kuruldu: `1b7e85ca1a8b3860b71d7887446bbe11e5d1246e`.

### RC-0185→0186 Lo Shu + future Kabbalistic boundary

- `lib/src/calculation_core/numerology/lo_shu_grid.dart` eklendi.
- Lo Shu 1..9 doğum-tarihi digit occurrences ve klasik 4-9-2 / 3-5-7 / 8-1-6 grid düzenini ayrı motor olarak üretir; Life Path/Pythagorean core import etmez.
- Kabbalistic numerology Pythagorean/Chaldean/Lo Shu alias'ı yapılmadı; source/version-tagged bağımsız engine contract bırakıldı.
- Regression, exact contract, fail-closed validator ve unique-concurrency gate commit `338f8c8aa3b9224f8793efcc442863e691f4f634` ile eklendi.

## Açık product-facing / global blocker'lar

RC-0042/0044/0046/0048/0049 product-facing açıkları; RC-0061 active house-system UI; RC-0068+ rendered product UI/interpretation/entitlement kanıtları; independent editorial/astronomy/calendar/numerology golden evidence; exact AKİLES provenance; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. RC-0158→0186 dedicated workflow sonuçları ve physical bot matrix promotions kontrol edilecek; kırmızıysa validator/test/analyzer root cause aynı hatta düzeltilecek.
2. Binding sıra **RC-0187→0211 Bugün alanı**: günlük dashboard/data envelope, Moon sign/phase, current-next planetary hour, Personal Day/transit/retrograde feeds, source identity, personalization ve Free/rewarded/PRO unlock semantics. Mevcut astronomy/numerology/planetary-hour core tekrar kullanılacak; duplicate calculation engine oluşturulmayacak.
3. RC-0127→0134, RC-0119→0122 ve Panchanga physical promotion açıkları ayrıca kapatılacak.
4. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapılmayacak.
5. RC-0082/0083, RC-0086/0087 ve RC-0062 eski promotion/root-cause açıkları ayrıca çözülecek.
6. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**
