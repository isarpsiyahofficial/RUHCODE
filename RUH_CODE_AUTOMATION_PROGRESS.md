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
- **RC-0142→0148 = TESTED + blocked=YES** (`e076b1d4698aee48f3a07f49448a27ebee04afde`).
- **RC-0149→0153 = TESTED + blocked=YES**; latest observed promotion `85edfde6f2064991a47cfef2ee10a6c13d923d7e`.
- **RC-0154→0157 = TESTED + blocked=YES** (`d4c6b14bf6c09ea2ae6830d445148850bc8b0048`).
- **RC-0158→0165 = IMPLEMENTED + blocked=YES**; production boundary commit `49e04735f9a3fb0f9af2467c34b05387dd71b3af`, physical TESTED promotion henüz kanıtlanmadı.
- **RC-0166→0184 = IMPLEMENTED + blocked=YES**; commit `1b7e85ca1a8b3860b71d7887446bbe11e5d1246e`. Numerology metric core/test/contract/validator/dedicated CI mevcut; physical TESTED promotion henüz kanıtlanmadı.
- **RC-0185→0186 = TESTED + blocked=YES**; implementation `338f8c8aa3b9224f8793efcc442863e691f4f634`, physical bot promotion `d6413c46c5d7dcf5cd4197f1dbd8a30335db2391`.
- **RC-0187→0211 = IMPLEMENTED + blocked=YES**; commit `862bcec56eb40c97b37a77add6d79a43aec6a3ba`. Daily Today data/provenance envelope, deterministic message recipe, system identity, Western/Vedic anti-fusion, finite rewarded unlock ve explicit PRO access policy için production/test/contract/validator/dedicated CI eklendi. Physical TESTED promotion sonucu bekleniyor.

## Bu turdaki gerçek geliştirme

### RC-0166→0184 numerology core

- Life Path, Expression/Destiny, Soul Urge, Personality, Birthday, Maturity, Balance, Karmic Lessons/Debt, Hidden Passion, Personal Year/Month/Day, Pinnacles ve Challenges calculation core eklendi.
- Reduction policy explicit/version/source-tagged; Pythagorean ve Chaldean tabloları ayrıldı.
- Türkçe Ç/Ğ/İ/I/ı/Ö/Ş/Ü karakterleri explicit transliteration ile işleniyor; gelişi güzel silinmiyor.
- Compatibility universal doctrine olarak hard-code edilmedi; version/source-tagged bounded rule engine.
- Commit: `1b7e85ca1a8b3860b71d7887446bbe11e5d1246e`.

### RC-0185→0186 Lo Shu + future Kabbalistic boundary

- Lo Shu birth-date digit grid ayrı motor olarak oluşturuldu; Pythagorean reduction import etmiyor.
- Kabbalistic numerology ayrı source/version-tagged future engine contract.
- Physical matrix promotion başarılı: `d6413c46c5d7dcf5cd4197f1dbd8a30335db2391`.

### RC-0187→0211 Bugün core

- `lib/src/application/daily/daily_today_core.dart` eklendi.
- Tarih, Moon sign/phase, current-next planetary hour, Personal Day, transit, retrograde ve günlük görünüm için source/system provenance taşıyan snapshot modeli kuruldu.
- Günün mesajı random-pool değildir; version/source/system-tagged deterministic recipe ile üretilir.
- Western ve Vedic yorum aynı recipe içinde tek gerçekmiş gibi birleştirilemez.
- Rewarded unlock scope + UTC expiry ile sınırlı; PRO erişimi explicit; reklam prompt politikası user-initiated ve session cap kontrollü.
- Regression, exact contract, fail-closed validator ve unique-concurrency promotion gate aynı committe: `862bcec56eb40c97b37a77add6d79a43aec6a3ba`.
- Rendered UI, real verified provider wiring, authoritative TR/EN editorial recipes ve gerçek rewarded-ad/PRO integration henüz blocker; bu nedenle TESTED/DONE erken verilmedi.

## Açık product-facing / global blocker'lar

RC-0042/0044/0046/0048/0049 product-facing açıkları; RC-0061 active house-system UI; RC-0068+ rendered product UI/interpretation/entitlement kanıtları; independent editorial/astronomy/calendar/numerology golden evidence; exact AKİLES provenance; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. RC-0158→0184 ve RC-0187→0211 dedicated workflow/physical bot promotion sonuçları kontrol edilecek; kırmızıysa validator/test/analyzer root cause aynı hatta düzeltilecek.
2. Binding sıra **RC-0212+ Spiritüel araçlar / Tarot** exact spec üzerinden okunup hesaplama çekirdeğinden bağımsız domain sınırıyla ilerletilecek; placeholder kart/metin, telifli içerik veya kanıtsız yöntem DONE sayılmayacak.
3. RC-0127→0134, RC-0119→0122 ve Panchanga physical promotion açıkları ayrıca kapatılacak.
4. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapılmayacak.
5. RC-0082/0083, RC-0086/0087 ve RC-0062 eski promotion/root-cause açıkları ayrıca çözülecek.
6. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**
