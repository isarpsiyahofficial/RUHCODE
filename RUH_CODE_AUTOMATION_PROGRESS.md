# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte independent/golden, TR/EN, offline, Free/PRO, backup/PDF, security, accessibility, performance, clean-checkout/lifecycle/device ve exact-release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Canonical durum özeti

- Erken bloklardaki mevcut status/promotion zincirleri korunuyor; RC-0062/0082/0083/0086/0087, exact AKİLES provenance ve global release blocker'ları açık.
- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0950 = implementation/matrix zincirleri mevcut; production-scale golden, rendered UI/device, PDF/backup ve diğer global blocker'lar nedeniyle DONE değil.
- RC-0951→0964 = IMPLEMENTED + blocked=YES; physical matrix promotion `5f08942462a0b3784725b9fd7e65de0cc22eb50e`.
- RC-0965→0994 = requirement/test traceability audit ve CI hattı mevcut; 1.442 RC'nin tamamı doğrudan evidence ile kapanmadığı için release-mode fail-closed.
- RC-0995→1003 = authoritative golden corpus sözleşmesi var; exact AKİLES ve bağımsız production golden değerleri eksik olduğu için promotion yok.
- RC-1004→1039 = IMPLEMENTED + blocked=YES; promotion `fb71d1b9703f35a4dec499e7d7de33151d57a75e`.
- RC-1040→1058 = IMPLEMENTED + blocked=YES; promotion `d96a3b5c1821d81739b491757795cfced5ba040a`.
- RC-1059→1084 = IMPLEMENTED + blocked=YES; physical promotion `ed87a5c385425a0c3e7f59f7f884c8dc55cab8f6`.
- RC-1085→1104 = IMPLEMENTED + blocked=YES; physical promotion `a9c4b832269328935dbf6d4753f603d17fa5b1f7`.
- RC-1105→1130 = offline startup/dependency governance zinciri mevcut. `pubspec.lock` materialization fiziksel olarak `09cf4da44c63c8031a149a7c555e37362ef194aa` commit'iyle oluştu. EOP/DE440s ve package license review, physical offline/device ve exact-release blocker'ları açık; bu nedenle DONE değil.
- RC-1131→1144 = feature-branch/PR/release governance policy + CODEOWNERS + fail-closed validator + regression + minified release-build CI, PR #1'de. Dedicated workflow fiziksel olarak tetiklendi. Repository-level branch protection/ruleset, independent review, physical/device minified parity ve exact final artifact kanıtı olmadan VERIFIED/DONE yok.
- RC-1145→1160 = explicit Android API floor + Android 17 current-stable compatibility matrix + API 21/API 37 emulator launch gate + production UI regression gate, stacked PR #2'de. UI viewport/font/chart/table/keyboard kanıtları tamamlanmadan VERIFIED/DONE yok.

## Son çalıştırmada yapılan gerçek geliştirme

### Bekleyen promotion ve lockfile doğrulaması

- RC-1059→1084 bot promotion: `ed87a5c385425a0c3e7f59f7f884c8dc55cab8f6`.
- RC-1085→1104 bot promotion: `a9c4b832269328935dbf6d4753f603d17fa5b1f7`.
- `pubspec.lock` artık repository'de gerçek: `09cf4da44c63c8031a149a7c555e37362ef194aa` (`build(rc1123): materialize dependency lockfile`).

### RC-1131→1144 GitHub / PR / release artifact governance

Bu çalışma direct-main yerine `agent/rc1131-rc1144-release-governance` feature branch'inde ve PR #1 üzerinden yapıldı.

`governance/release_governance_policy.json` main günlük geliştirmeyi yasaklar, feature branch + PR + calculation-core review + green-CI şartını tanımlar; final release manifest için exact commit SHA, artifact SHA-256, kapanan RC listesi, CI URL ve minification/obfuscation evidence zorunludur. Debug APK final olamaz.

`.github/CODEOWNERS` calculation core, astronomy/chinese/numerology tooling, governance, requirements ve workflow dosyalarını `@isarpsiyahofficial` review sahipliğine bağlar.

`tools/requirements/validate_rc1131_rc1144_release_governance.py` static policy/CODEOWNERS/contract/workflow varlığını, final manifest SHA ve artifact digest eşleşmesini, release-only build'i, debug artifact reddini, separate release test, minified parity, R8 reflection regression ve final-gate evidence alanlarını fail-closed doğrular.

`test/governance/test_rc1131_rc1144_release_governance.py` valid manifest/artifact, debug artifact reject, digest mismatch reject ve direct-main human push policy vakalarını kapsar.

`.github/workflows/rc1131-rc1144-release-governance.yml` PR/main hattında static validator + regression çalıştırır; Flutter 3.44.7 ile calculation regression sonrası `flutter build apk --release --obfuscate --split-debug-info=build/symbols` üretir, debug artifact reddeder ve release APK SHA-256 evidence yükler. PR merge sonrası main push'unda green job'lar yalnız NOT_STARTED→IMPLEMENTED + blocked=YES promotion yapabilir; TESTED/VERIFIED/DONE üretmez. İlk sürümde legitimate merged-PR push'unu yanlış reddedebilecek `--ci-context` çağrısı ve yalnız bot actor promotion koşulu tespit edildi; `2480036f311f5452056133826acb563f5bc8f9cb` ile aynı çalıştırmada düzeltildi.

GitHub branch-protection read endpoint'i bu bağlantıda `403 Resource not accessible by integration` verdi. Bu nedenle RC-1132/1135/1136 için gerçek repository-level enforcement kanıtı uydurulmadı ve blocker açık tutuldu.

### RC-1145→1160 Android compatibility / viewport güvenliği

Binding şartname RC-1145→1160 için minimum ve güncel Android açılışı, küçük/büyük telefon, tablet, yatay görünüm, büyük font, TR/EN uzun metin, küçük-ekran chart, kontrollü yatay tablo ve keyboard-safe form davranışlarını ayrı requirement olarak tanımlar.

- `android/app/build.gradle.kts` minimum Android API'sini inheritance yerine açıkça `minSdk = 21` olarak sabitler.
- `governance/android_compatibility_policy.json` minimum API 21 ve 2026-09-09 itibarıyla Android 17/API 37 current-stable test hedefini; 320x568 küçük telefon, 430x932 büyük telefon, 800x1280 tablet, 800x360 landscape; text scale 1.0/1.3/2.0 ve TR/EN matrisini kaydeder.
- `.github/workflows/rc1145-rc1160-android-compatibility.yml` API 21 ve API 37 emulatorlarında gerçek APK install + launcher smoke + process-alive + fatal-crash log gate'i çalıştırır; ayrıca repository'nin production `test/ui` regression suite'ini aynı değişiklik üzerinde çalıştırır.
- `requirements/contracts/rc1145_rc1160_android_compatibility_contract.json` RC-1145→1160 maddelerini tek tek evidence/promotion kurallarıyla bağlar.
- Bu çalışma `agent/rc1145-rc1160-android-compatibility` stacked feature branch'inde ve PR #2 üzerinden ilerliyor. Dedicated workflow run `34293458162` fiziksel olarak oluştu ancak son checkpoint'te queued idi.

## Açık blocker'lar

Authoritative independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; historical timezone/DST/polar goldens; production localization catalog + rendered TR/EN UI/PDF/share cards; interpretation/editorial QA; EOP/DE440s exact redistribution/license evidence; dependency license approvals; encrypted persistence/key management; production migration corpus; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode physical device proof; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact açık.

RC-1132/1135/1136 için repository-level branch protection/ruleset enforcement kanıtı ayrıca gereklidir. RC-1143/1144 için compile-only minified build yeterli değildir; behavior parity/reflection path'leri integration/device seviyesinde doğrulanmalıdır. RC-1148→1160 için compatibility matrix tanımı tek başına yeterli değildir; production UI üzerinde viewport/font/chart/table/keyboard evidence gerekir.

## Sonraki devam noktası

1. PR #1 RC-1131→1144 CI sonucunu fiziksel doğrula; kırmızıysa aynı branch'te root-cause düzelt, green olmadan merge/promotion yapma.
2. PR #2 RC-1145→1160 API21/API37 emulator ve production UI gate sonucunu fiziksel doğrula; emulator image veya app startup problemi varsa aynı branch'te düzelt.
3. RC-1148→1160 için production widget/integration viewport + text-scale + TR/EN long-string + chart/table/keyboard testlerini gerçek ekranlara bağla; yalnız policy dosyasıyla DONE verme.
4. Sonraki binding sıra RC-1161+ date/time picker TR/EN, unknown birth-time form, city search 100k-scale/aliases/disambiguation/manual location/permission fallback hattıdır.
5. RC-0995→1003 exact AKİLES provenance/independent goldens ve RC-0965→0994 traceability açıklarını paralel azalt.
6. RC-0001→RC-1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL deme.

**FINAL: NO.**
