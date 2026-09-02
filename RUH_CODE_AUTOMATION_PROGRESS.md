# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** SOURCE_LEVEL_IMPLEMENTED / IMPLEMENTED, DONE değildir. DONE yalnız gerekli test, golden, cihaz ve release kanıtlarıyla verilir.

## Requirement durumu

- Exact kapsam: `RC-0001 → RC-1442` / **1.442 requirement**.
- `requirements/requirement_state.csv` sparse explicit-override ledger'dır; bu checkpointte değiştirilmedi.
- Kanıtsız DONE/status override eklenmedi.

## Doğrulanmış ana ilerleme

- Calculation, timezone/date, astronomy provider, Western, numerology, BaZi ve Çin astrolojisi çekirdeklerinde source/test altyapısı mevcut.
- Free/PRO guard ve offline entitlement state mevcut.
- 15 tablolu backup/restore, transaction/rollback ve platform file-store katmanları mevcut.
- Professional/combined PDF planning, preview/build parity ve structural validation mevcut.
- UI action/accessibility contracts mevcut; catastrophic restore rollback persistent accessible integrity alarmıdır.
- Daily Message runtime packaged loader ve production Today wiring mevcut.
- TR/EN localization delegates production app'te explicit bağlı.

## Günün Mesajı doğrulanmış kanıtı

- `2026-01-01 → 2036-12-31`.
- TR **4018/4018**, EN **4018/4018**, toplam **8036/8036**.
- missing exact date/locale: **0**.
- Exact APK packaging proof (`5283cc2381fbf850f86c85cb458f96a6b8250f45`): yaklaşık 53.2 MB release APK, packaged TR 4018, EN 4018, missing 0, duplicate 0.
- APK SHA-256: `2720059bf969681f67e119cd7cf1185e41914224613f74dffcd75fc328d63948`.
- RC-1433 rolling-horizon release gate kaynak seviyesinde mevcut; final release tarihine göre strict pass gerekir.

## Flutter / CI durumu

Historical decoded baselines:

- `f18493949d0229a41e47d2dc05338e2167f599ac`: Analyze SUCCESS, Test `+559 -28`.
- `bf9b954f454f8c8685469010e4519c22073b7773`: Analyze SUCCESS, Test `+573 -17`.
- `b726b3196d9dfa0a15c740bc79a8c41f32379aff`: Analyze SUCCESS, Test `+582 -11`.
- `5283cc2381fbf850f86c85cb458f96a6b8250f45`: Analyze SUCCESS, Test `+590 -3`.
- `30b29b5b552b497a573acb7b370e3ab4c7bca78f`: Analyze SUCCESS, Test `+592 -1`.
- `4d3462a8dc35731473b89370840b78e840962d92`: Analyze SUCCESS, Test `+592 -1`.

Latest completed green baseline before this migration:

- `c432c0e96406fa5020ffea0a9036973d6dfe68fb`: **24 workflow completed green baseline**.
- Bu workflow toplamı bütün RC'lerin DONE olduğu anlamına gelmez.

## RC-1437 — offline/versioned calculation data

- timezone manifesti offline IANA runtime sözleşmesine sahip.
- city manifest status: `SOURCE_SELECTED_NOT_BUNDLED`; generated catalog checksum yok.
- planetary ephemeris + Earth-orientation manifestleri fiziksel bundling/provenance SHA-256 açısından tamamlanmış değil.
- strict/default fail-closed validator ve audit workflow mevcut.

**RC-1437 DONE değil.**

## RC-1439 — physical UI reference images

- reference manifest explicit `NOT_PROVEN`.
- validator fiziksel dosya, unique screen ID/path, filename ve exact SHA-256 doğruluyor.
- generated placeholder reference evidence reddediliyor.

**RC-1439 DONE değil.**

## RC-1442 — clean-checkout release source readiness

Bu checkpointte gerçek ilerleme:

- Existing APK workflow uzun süredir `flutter create --org com.ruhcode --project-name ruh_code` kullanıyordu. Bu nedenle repository build hattının canonical Android identity'si `com.ruhcode.ruh_code` olarak kanıtlandı; yeni/rastgele package ID üretilmedi.
- Flutter `3.44.7` upstream template kaynaklarından Gradle `9.1.0`, AGP `9.0.1`, Kotlin `2.3.20` doğrulandı.
- `12d79b57d10f63c7a0cae527b637745965031599` — tracked Android host eklendi:
  - `android/settings.gradle.kts`
  - `android/build.gradle.kts`
  - `android/app/build.gradle.kts`
  - `android/gradle.properties`
  - manifest + MainActivity
  - light/dark styles
  - Gradle wrapper properties + launcher scripts
- `namespace == applicationId == com.ruhcode.ruh_code`.
- `60fb4b5068be1190515453890c3e6ef0612ecc56` — APK packaging workflow tracked host migration state'ini tanıyacak şekilde düzeltildi. Host tracked ise tüm Android ağacı tekrar üretilmiyor; yalnız fiziksel wrapper JAR yoksa exact Flutter 3.44.7 generated hostundan JAR geçici materialize ediliyor ve provenance `tracked-host-generated-wrapper-jar` olarak yazılıyor.

Açık kalan RC-1442 source blocker:

- `android/gradle/wrapper/gradle-wrapper.jar` fiziksel tracked değil.
- production release signing mevcut değil; app Gradle release build şu an CI/package doğrulaması için debug signing kullanıyor.
- strict RC-1437 ve strict RC-1439 henüz PASS değil.
- signed reproducible clean-checkout APK ve real-device verification ayrıca eksik.

**RC-1442 DONE değil.**

## Açık ana blocker'lar

- exact Gradle wrapper JAR'ını tracked ve hash/provenance doğrulanmış hale getirmek,
- production signing configuration ve signed reproducible clean-checkout APK,
- RC-1437 physical/versioned/checksummed city + planetary ephemeris + EOP datasets ve independent golden accuracy,
- RC-1439 canonical physical reference screenshots/images + screen IDs + SHA-256 seti,
- Daily Message real airplane-mode device lookup proof,
- production Unicode PDF font + license/hash + parser/render/device delivery proof,
- Play/rewarded real-device evidence,
- visual/accessibility real-device regression,
- final exact 1.442-RC lifecycle audit.

## Son checkpoint

`automation_runs/2026-09-02_1652_tracked_android_host_progress.md`

## Sıradaki çalışma

1. Yeni engineering HEAD'in completed CI sonuçlarını oku; tracked host kaynaklı regresyon varsa düzelt.
2. Exact Gradle 9.1.0 wrapper JAR'ını physical tracked artifact olarak ekle ve hash/provenance doğrula.
3. Production signing'i debug signing'den ayır; secret-dependent signed release gate ekle.
4. RC-1437 ve RC-1439 fiziksel blockerlarını bağımsız ilerlet.
5. Exact signed release + final 1.442 RC lifecycle audit tamamlanmadan FINAL deme.

**FINAL: NO.**
