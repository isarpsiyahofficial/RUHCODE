# Ruh Code — tracked Android host checkpoint

## Exact CI baseline re-read

- `c432c0e96406fa5020ffea0a9036973d6dfe68fb`: 24 workflow run; completed green baseline used before new source changes.
- `requirements/requirement_state.csv` was not changed and no RC was promoted to DONE.

## RC-1442 / Android host progress

The existing APK workflow already defined the deterministic Flutter identity using `flutter create --org com.ruhcode --project-name ruh_code`; therefore the canonical Android application identity used by the repository build line is `com.ruhcode.ruh_code` rather than an invented new identifier.

Upstream Flutter `3.44.7` template constants were checked before tracking the host: Gradle `9.1.0`, AGP `9.0.1`, Kotlin `2.3.20`.

Commit `12d79b57d10f63c7a0cae527b637745965031599` added a tracked Android host including:

- `android/settings.gradle.kts`
- `android/build.gradle.kts`
- `android/app/build.gradle.kts`
- `android/gradle.properties`
- `android/app/src/main/AndroidManifest.xml`
- `android/app/src/main/kotlin/com/ruhcode/ruh_code/MainActivity.kt`
- light/dark Android styles
- Gradle wrapper properties and launcher scripts

The tracked host uses matching `namespace` and `applicationId`: `com.ruhcode.ruh_code`.

The physical `android/gradle/wrapper/gradle-wrapper.jar` is still not tracked. Therefore RC-1442 strict source readiness remains NOT READY and production signing/reproducibility is not claimed.

Commit `60fb4b5068be1190515453890c3e6ef0612ecc56` hardened `Daily Message APK Packaging` for the migration state: it now recognizes a tracked host, and only materializes the missing wrapper JAR from the exact Flutter `3.44.7` generated host when necessary. The provenance report explicitly records `tracked-host-generated-wrapper-jar`, so this temporary CI bridge cannot be mistaken for full tracked release readiness.

## Remaining release blockers

- track and verify the exact Gradle wrapper JAR;
- replace debug release signing with production upload/release signing evidence;
- strict RC-1437 physical city/ephemeris/EOP data;
- strict RC-1439 physical UI references;
- signed reproducible clean-checkout artifact;
- real-device airplane-mode/accessibility/Play/rewarded evidence;
- final exact 1,442-RC lifecycle audit.

**FINAL: NO.**
