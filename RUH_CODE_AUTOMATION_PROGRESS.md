# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** `IMPLEMENTED`, `DONE` değildir. `DONE` yalnız requirement-specific kanıt ile; calculation/interpretation/UI/TR-EN/offline/Free-PRO/backup/PDF/security/accessibility/performance/clean-checkout/lifecycle/device ve exact-release kapıları gereken kapsamda yeşil olduğunda verilir. Canonical lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; exact kapsam `RC-0001→RC-1442`, toplam **1.442 requirement**.

## Canonical durum özeti

- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0950 implementation/matrix zincirleri mevcut; global golden/device/PDF/backup blocker'ları nedeniyle toplu DONE değildir.
- RC-0951→0964 = IMPLEMENTED + blocked=YES (`5f08942462a0b3784725b9fd7e65de0cc22eb50e`).
- RC-0965→0994 traceability release-mode fail-closed; 1.442 requirement doğrudan evidence ile kapanmış değil.
- RC-0995→1003 authoritative golden contract mevcut; exact AKİLES provenance/independent values eksik.
- RC-1004→1039 = IMPLEMENTED + blocked=YES (`fb71d1b9703f35a4dec499e7d7de33151d57a75e`).
- RC-1040→1058 = IMPLEMENTED + blocked=YES (`d96a3b5c1821d81739b491757795cfced5ba040a`).
- RC-1059→1084 = IMPLEMENTED + blocked=YES (`ed87a5c385425a0c3e7f59f7f884c8dc55cab8f6`).
- RC-1085→1104 = IMPLEMENTED + blocked=YES (`a9c4b832269328935dbf6d4753f603d17fa5b1f7`).
- RC-1105→1130 dependency/offline governance mevcut; `pubspec.lock` fiziksel.
- Stacked PR zinciri #1→#16 mevcut. Branch: `agent/rc1421-rc1442-release-closure`, PR #16.
- Daha önce fiziksel SUCCESS ile doğrulanan kritik gate'ler arasında RC-1304→1344 Golden Lifecycle, RC-1345→1361 Release Cleanliness, RC-1375→1404 Final Traceability, RC-1405→1420 Local Core Cost Architecture ve RC-1437 Runtime Assets bulunuyor. Bu başarılar tek başına global DONE anlamına gelmez.
- Exact `c074c5d5846506dabfd6c9a4b8aa344544d4e26a` HEAD üzerinde Requirements Contract, Flutter Quality, Professional PDF Contract, System Boundaries ve Professional Timeline fiziksel SUCCESS verdi.
- Cancellation hiçbir zaman SUCCESS sayılmaz. Çok sayıda eski Vedic/calculation workflow'u branch push/concurrency nedeniyle halen `cancelled` durumdadır.

## RC-1436 — independent astronomy accuracy proof

Canonical toleranslar `requirements/reference_manifests/astronomy_accuracy_budgets.json` içinden okunur; test geçsin diye gevşetilmez. Global manifest halen `proven=false` ve bütün accuracy sınıfları tamamlanmadan RC-1436 DONE yapılmaz.

### DE440s / ephemeris

- Resmi JPL Horizons cross-model/provenance evidence ve strict same-DE440s bağımsız NAIF CSPICE/SpiceyPy oracle zinciri mevcut.
- Same-kernel strict evaluator regression production Dart SPK Type-2 evaluator'a bağlıdır.

### ASC / MC

- Independent Swiss Ephemeris/pyswisseph oracle; 1900/2000/2026/2050/2100, iki yarımküre, doğu/batı boylam ve >60° enlem kapsamı mevcut.
- Canonical `ascendantLongitudeMaxAbsErrorDegrees=0.05` ve `mcLongitudeMaxAbsErrorDegrees=0.05` toleransları korunmuştur.
- Materializer/evidence/regression/verifier/dedicated CI zinciri sırasıyla `b9ff49452f6cad0f1fca56701459fac6d03b2a6e`, `81bb8c6fb9598b1b7194bbf91be25898a4f6d9cb`, `76cf55b9d8feecf01926fd5a236b18b7215fa630`, `e908ca751366b39ab0540bd229e3857e4326d28e`, `337cc52cbb344dd060d653efe28c356398d28bc3` ile bağlandı.
- `RC1436 ASC MC Independent Oracle` run `34443503983` fiziksel SUCCESS verdi.

### Placidus house cusps — bu checkpoint

- Canonical `houseCuspLongitudeMaxAbsErrorDegrees=0.05` bütçesi doğrulandı; tolerans değiştirilmedi.
- Production `PlacidusHouses.calculate` strict iteratif Placidus solver kullanıyor; polar bölgede fail-closed davranışı korunuyor.
- `tools/data/materialize_placidus_swiss_oracle.py`: Swiss Ephemeris `swe.houses_ex(..., b"P", FLG_MOSEPH)` üzerinden production runtime'dan bağımsız 12-cusp oracle materializer eklendi.
- `evidence/rc1436/placidus_swiss_oracle.json`: 1900 Reykjavik, 2000 New York, 2026 İstanbul, 2050 Sydney, 2100 Quito vakaları; kuzey/güney, doğu/batı ve >60° non-polar enlem kapsanıyor. Provider version ve binary SHA-256 provenance taşıyor.
- `test/calculation_core/placidus_independent_oracle_test.dart`: production `WesternAscMc.calculate` + `PlacidusHouses.calculate` çıktısındaki 12 cusp'ın tamamını canonical 0.05° bütçeye bağlayan regression eklendi; fallback kabul edilmiyor, strict `PLACIDUS` success zorunlu.
- `tools/data/verify_placidus_swiss_oracle.py` commit `d34a086186b59c69a775b02663d884d09c65266e`: yeniden üretilen oracle metadata, case seti, 12 cusp ve sayısal değer drift'ini fail-closed doğruluyor.
- `.github/workflows/rc1436-placidus-oracle.yml` commit `3bb53e3f3b3cfa5218e794ad0267c80e66317ba6`: Python 3.13 + pinned `pyswisseph==2.10.3.2`, evidence regeneration/verifier ve Flutter production regression aynı dedicated gate'te.
- Exact `3bb53e3f3b3cfa5218e794ad0267c80e66317ba6` üzerinde `RC1436 Placidus Independent Oracle` run `34464410335` fiziksel olarak oluşturuldu ve son kontrolde `queued`; SUCCESS görülmeden house-cusp accuracy alt-kanıtı VERIFIED/DONE sayılmaz.

## Son dönemde kapatılan gerçek kırmızı kök nedenler

- Flutter Quality analyzer ihlalleri temizlendi (`1132b337...`→`02ddc42e...`).
- Requirements semantic spacing validator düzeltildi (`de480d49af696b19141c2043a35e4982d4399605`).
- PDF filename sanitizer boundary separator bug'ı düzeltildi (`80068c44413d5e50b50cb3213d32d88aceb47fb3`).
- Storage entitlement semantic validator düzeltildi (`24bacfabaf7beda45a716a70994baec718ad60de`).
- Transactional snapshot nested generic runtime cast bug'ı düzeltildi (`20f2d0b0f30f6eccac68517add4e36b5574c7a71`).
- Numerology validator gerçek API declaration'larına bağlandı; dedicated exact-head SUCCESS alındı.
- Personal Growth'a gerçek tarihsel period comparison modeli/regression eklendi; dedicated exact-head SUCCESS alındı.
- UI runtime theme semantic spacing/dark palette contract düzeltildi; dedicated exact-head SUCCESS alındı.
- System Boundaries literal requirement trace regression düzeltildi (`f301b23addc6984122137cd85ad98df2ddc7cb75`).
- Backup CSV verified restore async test gerçek completion'ı bekleyecek şekilde düzeltildi (`7435b87f72aa9fe7a125c32339731c79850d3fc0`).
- Professional PDF locale validator güncel `tr/tr-*/en/en-*` semantiğine bağlandı (`c478e03f6d733ab2cf186b79605d8ab3d5397750`).
- Western Natal fixture eksik quincunx orb'u düzeltildi (`e9e050661a2c8ed92b1286bb5d15c3bcc6ca6188`).
- PDF PREVIEW duplicate base/extension registry kökü giderildi (`54c695f23af32c04ab966c053e62c857d8c04ca0`); preflight validator exact-one birleşik registry semantiğine bağlandı (`17c7bb087f6c9b8d86de1596b07481b47b9b7b0f`).
- Professional Timeline enum validator production declaration + gerçek regression semantiğine bağlandı (`eb7120cf79a2d7357ad2c048fcaaf932fde08db1`).
- PDF vector renderer'da Unicode planetary glyph/Helvetica crash'i deterministic ASCII planetary labels ile giderildi; raster fallback eklenmedi (`fac4b9840ba24268368723cf22b73b1e8bcf5488`).

## Fiziksel blocker doğrulamaları

- Daily-message katalog kapsamı fiziksel olsa da strict release editorial audit kapanmadan RC-1425/1426/1433/1434 release-DONE değildir.
- `astronomy_accuracy_budgets.json` global `proven=false`; ASC/MC SUCCESS olsa da Placidus gate sonucu, sunrise/sunset, planetary-hour boundary, Nakshatra/Pada kanıtları eksik. RC-1436 DONE değildir.
- `requirements/reference_manifests/rc1439_reference_images.json` status `NOT_PROVEN`, `images=[]`; RC-1431/1439 ve reference-dependent final UI gate'leri açık.
- RC-1437 specialist runtime-assets gate geçmişte SUCCESS; exact packaged/version/checksum/offline/legal release closure ayrıca gereklidir.
- RC-1442 exact clean-checkout artifact, tested commit SHA ve artifact SHA eşleşmesi tüm 1.442 RC DONE/unblocked olmadan kapanamaz.
- Exact AKİLES provenance/independent authoritative values halen açık.
- Encrypted persistence/key management/migrations; full airplane-mode production instrumentation; rendered TR/EN UI/PDF; accessibility/performance; physical UI references; real entitlement/ad/rewarded verifier; remaining Vedic/Panchanga/Dasha/Varga/Gochara/BaZi proof zincirleri halen açık.

## Sonraki devam noktası

1. Exact HEAD üzerindeki `RC1436 Placidus Independent Oracle` run `34464410335` sonucunu fiziksel doğrula. Kırmızıysa verifier/evidence/production numerical farkının kök nedenini bul ve toleransı gevşetmeden düzelt; SUCCESS olmadan promotion yapma.
2. RC-1436 için sıradaki bağımsız accuracy sınıfı olarak sunrise/sunset evidence + production regression'ı canonical `60 s` bütçeye bağla.
3. Ardından planetary-hour boundary (`60 s`) ile Nakshatra (`0.05°`) / Pada (`0.02°`) bağımsız oracle zincirlerini tamamla.
4. RC-1362→1374 airplane-mode release/device koşusunu gerçek production capability instrumentation'a genişlet.
5. Daily-message strict audit, RC-1439 physical references, encrypted persistence/accessibility/performance ve packaged dataset/license zincirlerini bağımsız ilerlet.
6. Cancelled Vedic/calculation workflow'larını SUCCESS kabul etme; exact final HEAD üzerinde zorunlu kritik workflow seti fiziksel çalışmadan lifecycle yükseltme.
7. Yalnız dedicated exact-head SUCCESS ve requirement-specific evidence varsa matrix state yükselt; global blocker varken DONE verme.
8. RC-0001→RC-1442 tamamı DONE, bütün release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**
