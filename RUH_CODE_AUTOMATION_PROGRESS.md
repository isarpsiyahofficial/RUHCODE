# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte independent/golden, TR/EN, offline, Free/PRO, backup/PDF, security, accessibility, performance, clean-checkout/lifecycle/device ve exact-release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum — doğrulanmış özet

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
- RC-0212→0223, RC-0224→0229, RC-0230→0247, RC-0248→0270 = IMPLEMENTED + blocked=YES; physical TESTED promotion commit'leri henüz görülmedi.
- **RC-0271→0305 = TESTED + blocked=YES** (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- **RC-0306→0323 = TESTED + blocked=YES** (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- **RC-0324→0341 = IMPLEMENTED + blocked=YES**; reference-QA implementation gate physically passed and matrix evidence was recorded (`2155cfc613f0f5773f277999e8dd21d9f74ee66f`). Production-scale golden corpus blocks TESTED/VERIFIED/DONE.
- RC-0342→0359 = implementation chain added; physical matrix promotion not yet proven, no TESTED claim.
- RC-0360→0371 = implementation chain added; physical matrix promotion not yet proven, no TESTED claim.
- RC-0372→0381 = implementation chain added; physical matrix promotion not yet proven, no TESTED claim.
- RC-0382→0393 = implementation/test/contract/validator/dedicated-CI chain added; physical matrix promotion not yet proven, no TESTED claim.

## Bu çalıştırmadaki gerçek geliştirme

### RC-0324→0341 — reference / golden calculation QA

`lib/src/calculation/reference_qa.dart` ile Western, Vedic, Planetary Hours, BaZi ve Pythagorean/Chaldean/Lo Shu numerology için ayrı reference-suite modeli kuruldu. Her vaka Calculation Manifest + explicit expected values + provenance taşır. Tek kaynak yeterli değildir; primary mathematical + independent reference birlikte zorunludur. Zodiac ingress, Nakshatra, house cusp, DST, Chinese New Year, BaZi solar term, leap-year, midnight ve high-latitude explicit boundary sınıflarıdır. Default release policy Western >=1000 gerçek vaka, Vedic >=1000 gerçek vaka ve Planetary Hours global coordinate/timezone kapsaması ister; küçük fixture'lar production evidence sayılamaz. Physical matrix commit: `2155cfc613f0f5773f277999e8dd21d9f74ee66f`.

### RC-0342→0359 — sade IA + bilinmeyen doğum saati

`lib/src/ui/navigation/information_architecture.dart` Today / Discover / Calculate / Records / Profile ana navigasyonunu, Western/Vedic/Chinese/Numerology/Spiritual/Personal Growth domain ayrımını ve simple/professional görünürlük politikasını tanımlar. Professional araçlar simple modda sızmaz; onboarding kısa tutulur.

`lib/src/domain/profile/birth_profile.dart` doğum tarihini opsiyonel, doğum saatini explicit known/unknown yapar. Saat bilinmiyorsa yükselen/ev gibi time-dependent hesaplar sahte noon/midnight ile üretilmez; fail-closed. Birth place display identity + coordinate + timezone ile doğrulanır. Runtime shell/onboarding/place-picker/all time-dependent route wiring ve gerçek cihaz kanıtı blocker.

### RC-0360→0371 — tenant isolation + offline/remote sınırı

`lib/src/data/profile/profile_storage_contract.dart` self/partner/family/client kayıtlarını owner-scoped tutar; global unscoped repository list API'si yoktur ve cross-owner profil/not erişimi fail-closed. Sensitive birth data ayrıca işaretlenir. Real encryption-at-rest/key management henüz blocker.

`lib/src/application/runtime_capability_policy.dart` core calculations, profile, PDF ve backup export'u local-only; premium verification ve optional cloud sync'i remote-required yapar. Launch network allow-list boş. Premium yetkisi local boolean değil; verifier-backed signed assertion + UTC validity window ister. Real backend/store verifier, tamper/replay/expiry ve airplane-mode evidence blocker.

### RC-0372→0381 — reklam ve bildirim politikası

`lib/src/application/engagement_policy.dart` calculation input/result üzerinde reklamı prohibited yapar; daily-message rewarded yalnız user-initiated. Daily Message, Planetary Hour, Important Transit, Retrograde Boundary ve Moon Phase ayrı notification toggle'larıdır; default off + platform permission şarttır. Minimum-gap spam guard vardır. Real SDK/scheduler/channel/device lifecycle wiring blocker.

### RC-0382→0393 — profesyonel chart okunabilirliği

`lib/src/ui/chart/chart_readability_policy.dart` profesyonel/modern ürün tonunu ve calculation ekranlarında readability önceliğini machine-testable hale getirir. Telefonda derece ve gezegen sembolü için minimum okunabilir boyutlar vardır. `CircularLabelLayout` yakın gezegen etiketlerini presentation koordinatında ayırırken gerçek astronomik longitude'u değiştirmez. Aspect çizgileri telefon/tablet density limitleriyle azaltılır ve priority/tighter-orb sırasına göre korunur. Zoom 1x→4x aralığında explicit desteklenir. Android primary olabilir; domain katmanı Flutter üzerinden platform-neutral tutulur. Real chart renderer, professional tables, screenshot overlap/readability, TR/EN a11y ve cihaz evidence blocker.

## Açık blocker'lar

Independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion açıkları; rendered TR/EN UI/PDF; production Calculation Manifest persistence; interpretation/editorial QA; encrypted persistence/key management; tenant/device isolation; real ad/rewarded/PRO verifier; offline/airplane-mode; backup round-trip; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact kapıları açık. RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-0342→0393 dedicated CI + physical matrix commits yeniden okunacak; kırmızıysa exact validator/Flutter root cause düzeltilecek.
2. Binding sıra RC-0394+ üzerinden ilerleyecek.
3. RC-0212→0270, RC-0158→0184, RC-0127→0134, RC-0119→0122/Panchanga promotion açıkları tekrar kontrol edilecek.
4. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapılmayacak.
5. RC-0001→1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL denmeyecek.

**FINAL: NO.**