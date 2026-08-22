# Ruh Code Automation Checkpoint — Western runtime + persisted PDF service

## Bu turda yapılan gerçek değişiklikler

1. `RuhCodeRuntime` artık aynı production `SqfliteLocalDatabase` örneğine bağlı `WesternNatalPersistenceService` oluşturuyor ve dışarı açıyor. Böylece verified Western snapshot + `CalculationManifest` için atomik persistence boundary runtime composition içinde mevcut.
2. `PersistedWesternNatalPdfService` eklendi. `western.natal` profesyonel PDF hattı tarihi astrolojiyi yeniden hesaplamıyor; sealed persisted snapshot'ı doğruluyor ve yalnız o snapshot'tan placements / houses / aspects projekte ediyor.
3. Aynı PDF handler linked `CalculationManifest` üzerinden technical manifest bölümünü üretiyor; timezone, coordinate, engine, algorithm, data, house ve zodiac bilgileri yeniden hesaplanmıyor.
4. TR ve EN Western PDF etiketleri açık kataloglarla tanımlandı; unsupported locale veya eksik body/sign/motion/aspect/manifest etiketi fail-closed.
5. Persisted record identity drift ve snapshot digest drift fail-closed.
6. `evidence/pdf/persisted_western_pdf_service.json` ve `tools/pdf/validate_persisted_western_pdf_service.py` eklendi.
7. `Persisted Western PDF Service Contract` GitHub Actions workflow'u eklendi.

## Bu turda DONE yapılmayanlar

- Evidence bilinçli olarak `done=false`.
- Production Unicode font binary + lisans + immutable SHA yok.
- Western chart vector painter + approved glyph assets renderer'a bağlı değil.
- 5/25/50+ production render + parser/crop/glyph/visual regression kanıtı tamamlanmadı.
- Exact Actions SUCCESS görünür olmadan ilgili RC'ler DONE'a yükseltilmedi.

## Sıradaki güvenli işler

1. `PersistedWesternNatalPdfService`i approved font provider hazır olduğunda calculation-type router production composition'ına bağlamak; öncesinde fake/demo font kullanmamak.
2. Western save runtime boundary için doğrudan parallel calculation-table write yolunu structural audit ile ara ve yasakla.
3. `persisted_western_pdf_service.json` requirement ownership'ini merkezi semantic evidence auditine ekle.
4. Blocker-independent PDF/table/UI/backup/evidence işlerine devam et.
5. Fiziksel ephemeris/EOP/Lahiri/GeoNames, 8.036 editoryal daily message, APPROVED UI refs, production fonts ve clean-checkout lockfile blocker'larını açık tut.

**FINAL: NO.**
