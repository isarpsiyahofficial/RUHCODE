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
- RC-0212→0223 = IMPLEMENTED + blocked=YES; physical TESTED promotion commit'i henüz görülmedi.
- RC-0224→0229 = IMPLEMENTED + blocked=YES; physical TESTED promotion commit'i henüz görülmedi.
- RC-0230→0247 = IMPLEMENTED + blocked=YES; physical TESTED promotion commit'i henüz görülmedi.
- RC-0248→0270 = IMPLEMENTED + blocked=YES; physical TESTED promotion commit'i henüz görülmedi.
- **RC-0271→0305 = TESTED + blocked=YES** (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- **RC-0306→0323 = TESTED + blocked=YES** (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- **RC-0324→0341 = IMPLEMENTED + blocked=YES**; reference QA harness gate physically passed and matrix evidence was recorded (`2155cfc613f0f5773f277999e8dd21d9f74ee66f`). Production-scale golden corpus is deliberately still blocking TESTED/VERIFIED/DONE.
- RC-0342→0359 = production/test/contract/validator/dedicated CI implementation chain added; physical matrix promotion not yet proven, therefore no TESTED claim.
- RC-0360→0371 = production/test/contract/validator/dedicated CI implementation chain added; physical matrix promotion not yet proven, therefore no TESTED claim.
- RC-0372→0381 = production/test/contract/validator/dedicated CI implementation chain added; physical matrix promotion not yet proven, therefore no TESTED claim.

## Bu çalıştırmadaki gerçek geliştirme

### RC-0324→0341 — Reference / golden calculation QA

`lib/src/calculation/reference_qa.dart` ile motor bazlı golden/reference QA modeli kuruldu. Western, Vedic, Planetary Hours, BaZi ve üç numeroloji motoru ayrı tutuluyor. Her vaka Calculation Manifest + explicit expectation + provenance taşıyor. Tek kaynak release için yeterli değil; primary mathematical + independent reference kanıtı zorunlu. Zodiac ingress, Nakshatra, house cusp, DST, Chinese New Year, BaZi solar term, leap year, midnight ve high-latitude durumları explicit boundary sınıflarıdır.

Default release policy Western için >=1000 ve Vedic için >=1000 gerçek reference vaka, Planetary Hours için çoklu koordinat/timezone kapsaması ve tüm boundary sınıflarını şart koşuyor. Küçük regression fixture'ları bu eşiği kandıramıyor. Test, exact contract, fail-closed validator ve dedicated gate eklendi. Physical matrix commit: `2155cfc613f0f5773f277999e8dd21d9f74ee66f`.

### RC-0342→0359 — sade bilgi mimarisi + birth-time semantics

`lib/src/ui/navigation/information_architecture.dart` ile Today / Discover / Calculate / Records / Profile ana bilgi mimarisi, Western/Vedic/Chinese/Numerology/Spiritual/Personal Growth domain ayrımı ve simple/professional görünürlük politikası oluşturuldu. Expert/Professional domain simple modda sızmıyor; onboarding kısa tutuluyor.

`lib/src/domain/profile/birth_profile.dart` doğum tarihini opsiyonel, doğum saatini ise explicit `known/unknown` olarak modelliyor. Saat bilinmiyorsa yükselen/ev gibi saat-bağımlı calculation için sahte noon/midnight üretilmiyor; `requireLocalBirthDateTime()` fail-closed. Birth place display name + coordinate + timezone ile ayrı doğrulanıyor. TR/EN feature notice contract'ı mevcut. Runtime shell/onboarding/place picker/all time-dependent route wiring ve gerçek cihaz kanıtı blocker.

### RC-0360→0371 — tenant isolation + offline/online sınırı

`lib/src/data/profile/profile_storage_contract.dart` owner-scoped self/partner/family/client kayıt modeli ve global unscoped listelemeyi dışlayan repository contract'ı ekliyor; cross-owner profil/not erişimi fail-closed. Sensitive birth data ayrı işaretleniyor. Gerçek encryption-at-rest implementation/key management henüz yok ve bu yüzden DONE verilmez.

`lib/src/application/runtime_capability_policy.dart` Western/Vedic/Chinese/BaZi/Numerology/Planetary Hours calculation, profile, PDF ve backup export'u local-only; premium verification ve optional cloud sync'i remote-required olarak ayırıyor. Launch network allow-list boş. Premium authority mutable local boolean değil; verifier-backed signed assertion provenance + UTC validity window istiyor. Production store/backend verifier, tamper/replay/expiry ve airplane-mode/device kanıtları blocker.

### RC-0372→0381 — non-interruptive monetization + notification preferences

`lib/src/application/engagement_policy.dart` calculation input/result yüzeylerinde reklamı explicit `prohibited` yapıyor; daily-message rewarded yalnız user-initiated. Bildirimler Daily Message, Planetary Hour, Important Transit, Retrograde Boundary ve Moon Phase olarak ayrı category toggle'larıdır; varsayılanları kapalıdır ve platform permission olmadan etkinleşmez. Minimum-gap spam guard vardır. Real ad SDK audit, notification scheduler/channels/permissions ve verified trigger/device lifecycle wiring blocker.

## Açık blocker'lar

Independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic eski promotion açıkları; gerçek rendered TR/EN UI ve PDF; production Calculation Manifest persistence; editorial/interpretation QA; encrypted persistence/key management; multi-user tenant/device isolation; real ad/rewarded/PRO verification; offline/airplane-mode; backup round-trip; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact kapıları açık. RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-0342→0381 dedicated CI sonuçları ve physical matrix commits yeniden okunacak; kırmızıysa exact validator/Flutter root cause aynı hatta düzeltilecek.
2. Binding sıra RC-0382+ UI visual/readability/chart policy ile devam edecek.
3. RC-0212→0270, RC-0158→0184, RC-0127→0134, RC-0119→0122/Panchanga promotion açıkları tekrar kontrol edilip bağımsız blocker dışındakiler kapatılacak.
4. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapılmayacak.
5. RC-0001→1442 tamamı DONE ve tüm release gate'leri green olmadan FINAL denmeyecek.

**FINAL: NO.**