# Ruh Code — Latest Automation Checkpoint

Latest checkpoint:

`automation_runs/2026-09-02_1652_tracked_android_host_progress.md`

## Bu turda ilerleyen ana bloklar

1. **Exact CI baseline yeniden doğrulandı**
   - `c432c0e96406fa5020ffea0a9036973d6dfe68fb` üzerinde 24 workflow tamamlanmış green baseline olarak yeniden okundu.
   - Bu başarı 1.442 requirement'ın tamamını DONE yapmaz.

2. **Canonical Android identity artık repository build hattından kanıtlı**
   - APK workflow'u zaten `flutter create --org com.ruhcode --project-name ruh_code` kullanıyordu.
   - Buna göre tracked host identity `com.ruhcode.ruh_code` olarak sabitlendi; yeni/rastgele package ID üretilmedi.
   - Flutter 3.44.7 upstream template sürümleri doğrulandı: Gradle 9.1.0, AGP 9.0.1, Kotlin 2.3.20.

3. **Tracked Android host eklendi**
   - commit: `12d79b57d10f63c7a0cae527b637745965031599`.
   - settings/root/app Gradle, gradle.properties, manifest, MainActivity, light/dark styles, wrapper properties ve launcher scripts repository'de tracked.
   - `namespace == applicationId == com.ruhcode.ruh_code`.

4. **APK packaging migration guard eklendi**
   - commit: `60fb4b5068be1190515453890c3e6ef0612ecc56`.
   - Tracked host bulunduğunda artık tüm Android host yeniden üretilmiyor.
   - Fiziksel wrapper JAR henüz tracked olmadığı için CI exact Flutter 3.44.7 hostundan yalnız JAR'ı geçici materialize ediyor ve provenance `tracked-host-generated-wrapper-jar` olarak kaydediliyor.
   - Bu bridge RC-1442 release PASS sayılmaz.

## Doğrulanmış açık blocker

- `android/gradle/wrapper/gradle-wrapper.jar` fiziksel tracked değil.
- Production release signing ve signed reproducible clean-checkout APK kanıtı yok.
- RC-1437 physical/versioned/checksummed city + ephemeris + EOP eksik.
- RC-1439 canonical physical reference images + screen IDs + SHA-256 eksik.
- Real-device airplane-mode/accessibility/Play/rewarded kanıtları açık.

## Requirement disiplini

- Exact scope `RC-0001 → RC-1442` / 1.442 requirement.
- `requirements/requirement_state.csv` değiştirilmedi.
- Tracked host ilerlemesi tek başına RC-1442'yi DONE yapmadı.

**FINAL: NO.**
