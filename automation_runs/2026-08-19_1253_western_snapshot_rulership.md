# Ruh Code automation checkpoint — Western snapshot integrity + rulership

## Bu turda ilerletilen işler

1. `WesternNatalChartAssembler` derived-data bütünlüğü sertleştirildi.
   - Placement body seti duplicate olamaz.
   - `NatalAspectGrid.bodies` placement body setiyle birebir aynı olmak zorunda.
   - `EssentialDignitySet.assessments` placement body setiyle birebir aynı olmak zorunda.
   - Bu kontroller final chart döndürülmeden önce çalışıyor.

2. `natal_chart_test.dart` genişletildi.
   - placement/aspectGrid/dignity body set eşitliği doğrulanıyor.
   - aspect grid boyutu placement body count ile eşit olmak zorunda.

3. Klasik rulership query API eklendi.
   - `domicilesForBody(body)`
   - `rulersOfSign(sign)`
   - `classicalRulerOfSign(sign)`
   - API mevcut `_domiciles` dignity tablosundan türetiliyor; ikinci bir rulership tablosu yok.
   - Modern outer-planet rulership varsayımları classical API'ye eklenmedi.

4. `essential_dignities_test.dart` genişletildi.
   - Mercury → Gemini/Virgo domicile sorgusu.
   - Scorpio → Mars klasik yönetici.
   - Aquarius → Saturn klasik yönetici.
   - Leo → Sun tek yönetici.
   - Uranus/Neptune/Pluto için invented classical domicile olmadığının testi.

## Commitler

- `876089be7dc4953fd96a1fe59d26f140d94065ac` — natal derived snapshot integrity.
- `cf46f69f05007c49e150a13f81d3021ddf5c11e3` — canonical classical rulership API.
- `53fade22b6fc06fb466976928a7f69e7fd9c4ec7` — rulership tests.
- `d271cc3b843932af5b885652f119f2d5f4e0fab8` — derived body-set integration test.

## Kanıt durumu

GitHub combined-status connector latest exact commit için `statuses=[]` döndürdü. Bu nedenle Flutter/contract CI SUCCESS varsayılmadı ve ilgili RC maddeleri DONE'a yükseltilmedi.

## Sıradaki güvenli işler

1. Existing Western dignity/natal workflow'larında görünür failure oluşursa düzelt.
2. Placidus için algoritma/reference/tolerance contractını bağımsız golden kaynak zorunluluğuyla kur; golden veri olmadan DONE deme.
3. Physical IERS EOP + checksum/provenance zincirini tamamla.
4. Physical offline ephemeris kernel/runtime ingest + license/checksum kanıtını tamamla.
5. ASC/MC ve house-system independent golden accuracy datasetlerini bağla.
6. GeoNames physical compact catalog ve 8.036 editorial Daily Message blockers üzerinde bağımsız ilerle.

**FINAL DEĞİL.**
