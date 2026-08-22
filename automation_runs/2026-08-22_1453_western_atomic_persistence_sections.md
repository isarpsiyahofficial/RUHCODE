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
- `evidence/pdf/persisted_western_natal_snapshot.json` atomiklik ve persisted section projection kaynak/testlerini kapsayacak şekilde genişletildi.
- Evidence RC sahipliğinde yanlışlıkla eklenen `RC-0875/0876` hemen geri çıkarıldı; Western PDF bölümleri için doğru `RC-0920/0921/0922/0923` sahipliği kullanıldı.
- Persisted Western structural validator ve CI workflow yeni source/test dosyalarını kapsayacak şekilde genişletildi.

## Bu turdaki commit zinciri

- `698d5911d78ff1ffbdc7d1abbf1e95725e84824a` — atomic Western persistence service
- `118a3f998d63a73f0d06e3bb22cd7a6fdcc9be13` — persistence/rollback/round-trip tests
- `47fc745b54edd80363c9fec1dfabd6fbb634c45c` — persisted Western PDF section projection
- `0d590b1c97a244e018b870ec02073ed4ac9ebd97` — section projection tests
- `78c835c4730c381a5447c850f30bc9e10319922e` — evidence extension
- `616ce784b61a0656df88297e761008c0c192dcee` — corrected semantic RC ownership
- `8ee8adf31ae24eedb77e7fb981f64348c6665994` — structural validator extension
- `89cae3f065dbfc9a7c1ed783ddb9e961726dcd19` — workflow wiring
- `b67c706a811377bb24b85c0d49b757413ddb4821` — strict manifest engine/zodiac/house identity

## Kanıt durumu

- Source/test/evidence/structural CI contract mevcut.
- Exact latest commit için GitHub combined status yine individual check göstermedi: `statuses=[]`.
- Bu nedenle ilgili RC'ler yalnız source-level ilerledi; **DONE yapılmadı**.
- Astronomik accuracy bu turda kanıtlanmadı; fiziksel ephemeris/EOP hâlâ blocker.
- Final PDF görsel kalitesi production font/glyph/approved visual regression olmadan kanıtlanmadı.

## Sıradaki güvenli çalışma

1. Persisted Western evidence'ı merkezi `validate_evidence_traceability.py` semantic ownership denetimine konservatif exact RC setiyle ekle.
2. Western calculation runtime/save application boundary'sinde bu persistence servisini gerçek natal save akışına bağla; varsa başka doğrudan `calculations` yazma yolunu engelle.
3. Persisted Western sections'i production PDF handler'a bağla; approved font bulunmadan final renderer DONE verme.
4. CalculationManifest teknik PDF section projection'ını persisted manifestten ekle; tarih/konum/timezone/house/zodiac verisini tekrar hesaplama.
5. Blocker gerektirmeyen backup/PDF/UI interaction/evidence auditlerine devam et.
6. Fiziksel ephemeris/EOP/Lahiri/GeoNames, 8.036 editoryal günlük mesaj, APPROVED UI refs, production Unicode PDF fontları ve clean-checkout lockfile blocker'larını açık tut.

**FINAL değil.**
