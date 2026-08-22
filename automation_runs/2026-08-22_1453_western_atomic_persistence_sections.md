# Ruh Code automation checkpoint — Western atomic persistence + PDF sections

## Bu turda yapılan gerçek değişiklikler

- `WesternNatalPersistenceService` eklendi.
- `CalculationManifest` ve `calculations` kaydı **aynı LocalDatabase transaction** içinde yazılıyor.
- Snapshot yazılmadan önce canonical JSON SHA-256 ile `PersistedWesternNatalEnvelope` olarak mühürleniyor.
- Existing calculation/manifest ID collision fail-closed.
- Manifest `engineId`, `engineVersion`, `algorithmVersion`, `dataVersion`, `houseSystemId` ve `zodiacSystemId` snapshot ile doğrulanıyor.
- Calculation ikinci yazısı başarısız olduğunda manifest yazısının rollback edildiğini doğrulayan test eklendi.
- Persisted calculation, `LocalDatabaseProfessionalPdfSnapshotSource` üzerinden tekrar okunup snapshot SHA/canonical JSON round-trip doğrulanıyor.
- `PersistedWesternNatalSectionAdapter` eklendi.
- PDF `placements`, `houses`, `aspects` bölümleri yalnız persisted snapshot üzerinden üretiliyor; ephemeris/natal/house hesap motorları import edilmiyor.
- Yerleşim satırları stored longitude/house/motion, ev satırları stored cusps, açı satırları stored aspect geometry üzerinden hazırlanıyor.
- Lokalize label boşsa PDF projection fail-closed.
- `PersistedManifestSectionAdapter` eklendi; teknik PDF bölümü koordinat/timezone/tarih/engine/house/zodiac değerlerini yalnız persisted `CalculationManifest` üzerinden gösteriyor, yeniden hesaplama yapmıyor.
- Teknik manifest bölümünde locale etiketi eksikse fail-closed; snapshot digest lowercase SHA-256 olmak zorunda.
- `evidence/pdf/persisted_western_natal_snapshot.json` atomiklik ve persisted section projection kaynak/testlerini kapsayacak şekilde genişletildi.
- Evidence RC sahipliğinde yanlışlıkla eklenen `RC-0875/0876` hemen geri çıkarıldı; Western PDF bölümleri için doğru `RC-0920/0921/0922/0923` sahipliği kullanıldı.
- `evidence/pdf/persisted_manifest_section.json` ile `RC-0911/0912/0913/0914/0916` konservatif sahipliği ayrı tutuldu.
- Persisted Western için ayrı semantic MASTER keyword/RC validator eklendi.
- Persisted Western structural validator ve CI workflow yeni source/test/evidence/semantic validator dosyalarını kapsayacak şekilde genişletildi.

## Bu turdaki commit zinciri

- `698d5911d78ff1ffbdc7d1abbf1e95725e84824a` — atomic Western persistence service
- `118a3f998d63a73f0d06e3bb22cd7a6fdcc9be13` — persistence/rollback/round-trip tests
- `47fc745b54edd80363c9fec1dfabd6fbb634c45c` — persisted Western PDF section projection
- `0d590b1c97a244e018b870ec02073ed4ac9ebd97` — section projection tests
- `616ce784b61a0656df88297e761008c0c192dcee` — corrected semantic RC ownership
- `8ee8adf31ae24eedb77e7fb981f64348c6665994` — structural validator extension
- `b67c706a811377bb24b85c0d49b757413ddb4821` — strict manifest engine/zodiac/house identity
- `6750a86cc1d056ff587ff23ea67c38f311ce0435` — persisted Western semantic RC validator
- `e8814cc19f73a062d9a5f826039a1243793fa3a3` — semantic validator workflow wiring
- `f35f6f2b986f52eaae21d646041fcc561d7218cb` — persisted CalculationManifest technical PDF section
- `cdf96dd3f749d97c539e327fe7a3784b973d4637` — technical manifest tests + valid digest fixture
- `4e326b5aee34ee6d9549d14547c911a0d0f57674` — technical manifest evidence
- `0992f55815604e935d9258a79e4ccf4e09affc72` — technical manifest validator
- `e87f9a6dcde344a12ef96d3754c3778a8ac42952` — expanded persisted Western/manifest CI contract

## Kanıt durumu

- Source/test/evidence/structural + semantic CI contract mevcut.
- GitHub combined status source commitlerinde individual check göstermedi: `statuses=[]`.
- Bu nedenle ilgili RC'ler yalnız source-level ilerledi; **DONE yapılmadı**.
- Astronomik accuracy bu turda kanıtlanmadı; fiziksel ephemeris/EOP hâlâ blocker.
- Final PDF görsel kalitesi production font/glyph/approved visual regression olmadan kanıtlanmadı.

## Sıradaki güvenli çalışma

1. Western calculation runtime/save application boundary'sinde `WesternNatalPersistenceService`i gerçek natal save akışına bağla; varsa paralel doğrudan `calculations` yazma yolunu engelle.
2. Persisted Western sections + technical manifest section'ı production `western.natal` PDF handler'a bağla; approved font bulunmadan final renderer DONE verme.
3. `persisted_manifest_section` evidence'ını merkezi semantic evidence audit kapsamına al.
4. Requirement-bearing kalan evidence dosyalarını semantic RC ownership audit'e al.
5. Blocker gerektirmeyen backup/PDF/UI interaction işlerine devam et.
6. Fiziksel ephemeris/EOP/Lahiri/GeoNames, 8.036 editoryal günlük mesaj, APPROVED UI refs, production Unicode PDF fontları ve clean-checkout lockfile blocker'larını açık tut.

**FINAL değil.**
