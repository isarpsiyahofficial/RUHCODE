# Ruh Code automation checkpoint — Western aspect grid + classical dignities

## Bu turda uygulanan gerçek değişiklikler

- `lib/src/calculation_core/western/aspect_grid.dart`
  - NatalPlacementSet + NatalAspectSet aynı TT/source/version provenance taşımak zorunda.
  - AstroBody sırasına göre deterministik kare grid.
  - Diagonal self-aspect boş.
  - A-B / B-A simetrik pair lookup.
  - Placement'ta olmayan body reference ve aynı pair için duplicate aspect reddediliyor.
- `test/calculation_core/western/aspect_grid_test.dart`
  - symmetry/square shape, provenance mismatch, duplicate pair regression testleri.
- `lib/src/calculation_core/western/essential_dignities.dart`
  - Classical domicile/exaltation yalnız Sun–Saturn tablosu.
  - Detriment domicile'ın opposite sign'ından, fall exaltation'ın opposite sign'ından türetiliyor.
  - Aynı placement birden fazla statü taşıyabiliyor: Mercury Virgo = domicile+exaltation; Mercury Pisces = detriment+fall.
  - Uranus/Neptune/Pluto/nodes için invented classical dignity yok.
- `test/calculation_core/western/essential_dignities_test.dart`
  - domicile/exaltation/detriment/fall, overlapping states, outer planet/node neutrality.
  - Kritik skipped test bırakılmadı.
- `WesternNatalChartAssembler`
  - aspect grid ve dignity set aynı natal snapshot'a bağlandı.
- Evidence:
  - `evidence/astronomy/western_aspect_grid.json`
  - `evidence/astronomy/western_essential_dignities.json`
- Structural validators:
  - `tools/astronomy/validate_western_aspect_grid.py`
  - `tools/astronomy/validate_western_essential_dignities.py`
- CI contracts:
  - `.github/workflows/western-aspect-grid-contract.yml`
  - `.github/workflows/western-essential-dignities-contract.yml`

## Requirement kapsamı

Source-level ilerleyen alanlar: `RC-0049`, `RC-0050`, `RC-0051`, `RC-0276`, `RC-0277`, `RC-0278`.

Bu RC'ler DONE yapılmadı. Upstream physical ephemeris/accuracy ve latest exact-commit Flutter/Actions SUCCESS kanıtı henüz yok.

## Bu turdaki commit zinciri

- `3d6a0e9efa0d96540cdd183d1fc771d6c5601825` — aspect grid
- `ea8ee3a2a9879e07180f66c80f7dd19bc447dc3e` — classical dignities
- `276dfbdc25923e4cf82713bd7733118aa8a79cf8` — aspect-grid tests
- `f4b4f386700d1c566a6da9b731ef6f75f293e205` — initial dignity tests
- `46fffff63a2db607c165c9f76c81e47748ed1092` — remove skipped test + overlap coverage
- `dede3f07e34fb07bf9bada29732482926d099211` — natal chart assembly integration
- `b75cce5a42ed2a49290b316492f0baf723d3465b` — aspect-grid evidence
- `10f22059528c74d8418552b114f10f3e73ac54d1` — dignity evidence
- `ff53a1b3cf3f988ce520d924fb24e3017a67e714` — aspect-grid validator
- `e1b4a6f713999a9717a2a10b1f8505989510cde5` — dignity validator
- `8b19d94badc3439dc03b4fb28927b9b70b80c47e` — aspect-grid workflow
- `c683256d6394769ce11951e132c962167744c6d0` — dignity workflow

## CI görünürlüğü

GitHub combined-status connector çağrısı latest commit için individual status göstermedi (`statuses=[]`). Bu yüzden CI SUCCESS uydurulmadı.

## Sıradaki güvenli çalışma

1. Yeni Western aspect-grid/dignity workflow'larında görünür hata oluşursa düzelt.
2. Natal chart derived-data snapshot bütünlüğünü testte genişlet: aspect-grid/dignity output'larının assembler inputuyla aynı body setinden geldiğini kanıtla.
3. Classical rulership query API'sini, dignity tablosunu duplicate etmeyecek biçimde aynı canonical table üzerinden üret.
4. Placidus için algoritma/reference/tolerance sözleşmesini kesinleştir; independent golden olmadan DONE deme.
5. Paralelde fiziksel IERS EOP, offline ephemeris, GeoNames artifact, editoryal 8.036 günlük mesaj ve approved UI reference blocker'larını ilerlet.

**FINAL DEĞİL.**
