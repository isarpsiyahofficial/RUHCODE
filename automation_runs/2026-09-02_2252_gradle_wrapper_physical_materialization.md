# RUH CODE — 2026-09-02 22:52 Gradle Wrapper Physical Materialization

## Bağlayıcı kapsam

- `RUH_CODE_MASTER_TODO.md`, `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_AUTOMATION_PROGRESS.md` ve `requirements/requirement_state.csv` yeniden okundu.
- Exact kapsam RC-0001→RC-1442 / 1.442 requirement olarak korundu.
- Kanıtsız requirement DONE değişikliği yapılmadı.

## Bu turdaki gerçek değişiklikler

### 1. Wrapper materialization kök nedeni düzeltildi

Önceki materializer ve APK workflow fallback yolu doğrudan `gradle-9.1.0-wrapper.jar` URL'sine ve wrapper JAR'ını `java -jar` ile çalıştırmaya dayanıyordu. Bu yaklaşım release packaging'i Gradle başlamadan kırabiliyordu.

Commit `00e1198176117e09d50ac796e69acf06d7368862` ile:
- resmi Gradle 9.1.0 binary dağıtımı checksum ile doğrulanıyor,
- dağıtımın kendi `wrapper` task'ı minimal temp project üzerinde çalıştırılıyor,
- üretilen `gradle-wrapper.jar` official expected SHA-256 ile doğrulanıyor,
- `android/gradlew --version` ile gerçek wrapper execution doğrulanıyor,
- APK packaging fallback yolu aynı doğrulanmış mekanizmaya geçirildi,
- RC-1442 source validator fiziksel wrapper SHA-256, locked distribution checksum, `.sha256` provenance ve JSON provenance doğruluyor.

### 2. Fiziksel wrapper artık tracked

Materializer başarıyla `main`e bot commit'i oluşturdu:

`469a797d5502539e42a0d83d7ffe83496775a884` — `Track verified Gradle 9.1.0 wrapper and provenance`

Tracked dosyalar:
- `android/gradle/wrapper/gradle-wrapper.jar`
- `android/gradle/wrapper/gradle-wrapper.jar.sha256`
- `android/gradle/wrapper/gradle-wrapper.provenance.json`

Recorded wrapper SHA-256:
`76805e32c009c0cf0dd5d206bddc9fb22ea42e84db904b764f3047de095493f3`

Recorded Gradle 9.1.0 distribution SHA-256:
`a17ddd85a26b6a7f5ddb71ff8b05fc5104c0202c6e64782429790c933686c806`

Bu nedenle önceki "physical tracked Gradle wrapper JAR" blocker'ı source/provenance düzeyinde kapandı.

## Hâlâ açık release kapıları

- strict RC-1437 physical/versioned/checksummed city + ephemeris + EOP data,
- strict RC-1439 canonical physical UI reference images + screen IDs + SHA-256,
- secret-backed production signing,
- signed reproducible clean-checkout APK + exact artifact verification,
- real-device airplane/offline, accessibility/visual, Play/rewarded ve PDF delivery evidence,
- final exact RC-0001→RC-1442 lifecycle audit.

RC-1442 bu nedenle DONE değildir.

## CI continuation

GitHub Actions bot tarafından oluşturulan `469a797...` push'u normal workflow zincirini otomatik tetiklemedi. Bu checkpoint commit'i `main`e normal commit olarak yazılarak yeni exact HEAD üzerinde full push CI zincirinin tetiklenmesi amaçlanır. Sonraki çalışma bu exact HEAD sonuçlarını okuyacak ve kırmızı varsa aynı kök-neden yöntemiyle ilerleyecek.

**FINAL: NO.**
