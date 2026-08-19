# Ruh Code automation checkpoint — Western foundations

Bu çalışma turunda requirement kapsamı ve mevcut automation progress yeniden okundu. Kanıtlanmamış işler DONE yapılmadı.

## İlerletilen bloklar

### Mean tropical ASC / MC
- `lib/src/calculation_core/western/asc_mc.dart`
- UT1 ve TT ayrı input olarak korunuyor; UTC sessizce UT1 yerine kullanılmıyor.
- USNO tabanlı mevcut GMST katmanı kullanılıyor.
- IAU 2006 mean-obliquity polynomial ayrı fonksiyon olarak bulunuyor.
- Longitude east-positive, latitude north-positive sözleşmesi açık.
- Exact coğrafi kutuplar stable ASC olmadığı için reddediliyor.
- ASC/MC [0,360) normalize ediliyor.
- Equator/cardinal sidereal boundary testleri eklendi.
- `evidence/astronomy/western_asc_mc.json`, structural validator ve CI workflow eklendi.
- Independent golden accuracy henüz yok; evidence `SOURCE_LEVEL_ONLY`, `independent_golden_proven=false`.

### Western natal placements
- `lib/src/calculation_core/western/natal_placements.dart`
- Versioned `EclipticState` listesi + seçilmiş `HouseCusps` tüketiliyor.
- Tropical zodiac sign, degree-in-sign, house number ve direct/stationary/retrograde üretiliyor.
- 0°, 29.999999°, 30°, 359.999999° boundary testleri eklendi.
- Aynı natal snapshot içinde mixed TT instant, mixed provenance ve duplicate body reddediliyor.
- `evidence/astronomy/western_natal_placements.json`, structural validator ve CI workflow eklendi.
- Fiziksel ephemeris kanıtı olmadığı için SOURCE_LEVEL_ONLY tutuluyor.

## Commit zinciri
- ASC/MC source: `2c09aad03f3b8774de9e6d59204c3bb2dbc815be`
- ASC/MC tests: `17a51292ffd03fb673b9cff6aef6078335c59945`
- ASC/MC evidence: `73888bf7e3f8e3fe5c1d09f35cd2faad78f59cfa`
- ASC/MC validator: `f64195f4bbb8a275daf53be09fa8778e7d8738a4`
- ASC/MC workflow: `ac3b87dbfdbf89d63d4f0fdd0632d1879ba89fbd`
- Natal placements source: `6f1bc62bf03740791446de2faa1bba354be660c5`
- Natal placements tests: `ca44a4b5c444bfe74b06eef2a5abfc709b76ef82`
- Natal placements evidence: `73f85f9fc51aae29463c7e0ad5133931e00b8cf4`
- Natal placements validator: `2d823409ed8ac4dd4a1c5c503171c45d384b987b`
- Natal placements workflow: `f3f23e6cf504b1fcc9c7185990be668ad2b3dc69`

## Doğrulama durumu
- GitHub combined-status endpoint latest commits için individual check sonucu döndürmedi; CI SUCCESS iddiası yapılmadı.
- Automation container GitHub DNS çözümleyemediği için local clone/Flutter run yapılamadı; bu transient environment sınırlaması requirement state yükseltmek için kullanılmadı.
- Structural contractlar repository içinde CI tarafından çalıştırılacak şekilde eklendi.

## Sıradaki güvenli işler
1. Western natal major-aspect engine'i natal placement snapshot'ına bağla; configurable orb ve boundary tests ekle.
2. ASC/MC independent golden-reference dataset/runner bağlantısını accuracy-budget sistemine ekle.
3. Physical EOP + ephemeris kanıtı geldiğinde ASC/MC ve placements end-to-end golden doğrulamasını yap.
4. Whole Sign / Equal House sonuçlarını verified ASC ile tek natal chart assembly katmanına bağla.
5. Sonra Placidus'a geç; independent reference olmadan DONE işaretleme.

**FINAL DEĞİL.**
