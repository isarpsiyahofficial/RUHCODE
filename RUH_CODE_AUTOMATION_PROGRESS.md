# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** `IMPLEMENTED`, `DONE` değildir. `DONE` yalnız requirement-specific kanıt ile; calculation/interpretation/UI/TR-EN/offline/Free-PRO/backup/PDF/security/accessibility/performance/clean-checkout/lifecycle/device ve exact-release kapıları gereken kapsamda yeşil olduğunda verilir. Canonical lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; exact kapsam `RC-0001→RC-1442`, toplam **1.442 requirement**. `cancelled` hiçbir zaman SUCCESS sayılmaz.

## Canonical durum

- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0950 implementation/matrix zincirleri mevcut; global golden/device/PDF/backup blocker'ları nedeniyle toplu DONE değildir.
- RC-0951→0964 = IMPLEMENTED + blocked=YES (`5f08942462a0b3784725b9fd7e65de0cc22eb50e`).
- RC-0965→0994 traceability release-mode fail-closed; 1.442 requirement doğrudan evidence ile kapanmış değildir.
- RC-0995→1003 authoritative golden contract mevcut; exact AKİLES provenance/independent values eksik.
- RC-1004→1039 = IMPLEMENTED + blocked=YES (`fb71d1b9703f35a4dec499e7d7de33151d57a75e`).
- RC-1040→1058 = IMPLEMENTED + blocked=YES (`d96a3b5c1821d81739b491757795cfced5ba040a`).
- RC-1059→1084 = IMPLEMENTED + blocked=YES (`ed87a5c385425a0c3e7f59f7f884c8dc55cab8f6`).
- RC-1085→1104 = IMPLEMENTED + blocked=YES (`a9c4b832269328935dbf6d4753f603d17fa5b1f7`).
- RC-1105→1130 dependency/offline governance mevcut; `pubspec.lock` fiziksel.
- Stacked PR zinciri #1→#16 mevcut. Branch `agent/rc1421-rc1442-release-closure`, PR #16.
- Fiziksel SUCCESS ile doğrulanan kritik gate'ler arasında RC-1304→1344 Golden Lifecycle, RC-1345→1361 Release Cleanliness, RC-1375→1404 Final Traceability, RC-1405→1420 Local Core Cost Architecture ve RC-1437 Runtime Assets vardır; bunlar global DONE değildir.
- RC-1436 alt-kanıtlarında ASC/MC, Placidus, Solar Events ve Planetary Hours independent oracle gate'leri fiziksel SUCCESS ile doğrulanmıştır. Legacy `cancelled` workflow'lar SUCCESS değildir.

## RC-1436 — independent astronomy accuracy proof

Canonical toleranslar `requirements/reference_manifests/astronomy_accuracy_budgets.json` içinden okunur ve test geçsin diye gevşetilmez. Global manifest halen `proven=false`; bütün applicable accuracy sınıfları tamamlanmadan RC-1436 DONE değildir.

### DE440s / ephemeris
- Resmi JPL Horizons cross-model/provenance evidence ile strict same-DE440s bağımsız NAIF CSPICE/SpiceyPy oracle zinciri mevcut.
- Same-kernel regression production Dart SPK Type-2 evaluator'a bağlıdır.
- DE440s runtime kontratı geometric geocentric **J2000-ecliptic** state üretir; bu semantik artık `EclipticReferenceFrame.j2000Geometric` ile veri modelinde explicit taşınır (`37b2ff4f7fc2adbcc022a37095a3c84e942e611e`, `74300d755efbf3fd020a5443130dfdf9ba93ccbb`). Existing analytical/test providers backward-compatible `tropicalOfDate` defaultunda kalır.

### ASC / MC
- Independent Swiss Ephemeris/pyswisseph oracle 1900/2000/2026/2050/2100 ve cross-hemisphere/longitude/high-latitude kapsamına sahiptir.
- Canonical ASC/MC toleransları `0.05°`; değiştirilmemiştir.
- Exact-head independent oracle fiziksel SUCCESS ile doğrulanmıştır.

### Placidus house cusps
- Canonical house cusp toleransı `0.05°`; değiştirilmemiştir.
- Production strict solver + fail-closed polar davranışını korur.
- Exact-head independent oracle fiziksel SUCCESS ile doğrulanmıştır.

### Sunrise / sunset
- Canonical `sunriseSunsetMaxAbsErrorSeconds=60`; değiştirilmemiştir.
- Independent Swiss `swe.rise_trans` materializer, provenance evidence, drift verifier, real `SolarEvents.forDate` regression ve dedicated CI mevcuttur.
- Swiss compiled-extension build gürültüsü için yalnız reproducibility verifier unit-aware hale getirildi; minute alanlarında `1e-6` dakika ve Julian Day alanlarında `1e-9` gün kullanılır. Canonical 60 saniyelik ürün accuracy budget'ı değişmedi.
- Exact `bce6edc1897d87cf8b9d4df0ebe6da9060e93ab9` üzerinde dedicated Solar Events independent oracle fiziksel SUCCESS verdi; solar alt-kanıt verified durumdadır.

### Planetary-hour boundaries
- Canonical `planetaryHourBoundaryMaxAbsErrorSeconds=60`; değiştirilmemiştir.
- Independent Swiss proof zinciri 24 slotun 25 unique boundary'sini real production `PlanetaryHours.forDate` ile karşılaştırır.
- Exact `bce6edc1897d87cf8b9d4df0ebe6da9060e93ab9` üzerinde dedicated Planetary Hours independent oracle fiziksel SUCCESS verdi; bu alt-kanıt verified durumdadır.

### Nakshatra / Pada
- Canonical accuracy budget: Nakshatra `0.02°`, Pada `0.02°`; sınıflandırma rounded/display değerden değil ham sidereal longitude'dan yapılmalıdır.
- Kök neden doğrulandı: production DE440s state J2000-ecliptic iken eski Vedic engine date-dependent Lahiri ayanamsha'yı doğrudan bu longitude'dan çıkarıyordu; equinox/frame karışımı oluşuyordu.
- `4ace136ef408403206230f4509238f5aa5282c86` ile Vedic-only `VedicEclipticFrame` eklendi. J2000 ecliptic unit vector önce J2000 equatorial'a, IAU-1976/Meeus precession ile mean equator/equinox-of-date'e, ardından mean obliquity-of-date ile tropical ecliptic-of-date'e dönüştürülür. Shared DE440s kontratı değiştirilmez.
- `22f2ab682f53bc898a4252090209ec1290f1d1d6` ile `VedicCalculationEngine` ayanamsha uygulamadan önce explicit frame normalization kullanır; tropical-of-date provider'lar double-precession yapılmadan olduğu gibi geçer.
- `a06aeae8117c65c417178cbf5f6dc8b09de049d1` + `b5b9a1f71e37a847edf587e191129ec183494799` ile pinned Swiss Ephemeris/Moshier + `SIDM_LAHIRI`, `FLG_TRUEPOS`, `FLG_NONUT` bağımsız oracle/evidence eklendi. 1900/2000/2026/2050/2100 kapsanır.
- `54198666502f395c9beaa24e4242a79c7cb7387f` deterministic evidence drift verifier'ını; `45a1611e7c0d52e3419191783bb302117510f14e` packaged DE440s + real Vedic frame dönüşümünü independent raw sidereal Moon longitude'a ve Nakshatra/Pada classification'a bağlayan Flutter regression'ını ekledi.
- `2b84cb627af15fc2aaab438c23d728d27591ff0e` dedicated `RC1436 Nakshatra Pada Independent Oracle` CI gate'ini ekledi. Exact-head fiziksel SUCCESS görülmeden Nakshatra/Pada alt-kanıtı VERIFIED/DONE değildir.

## Açık blocker'lar

- Daily-message strict editorial release audit kapanmadan RC-1425/1426/1433/1434 release-DONE değildir.
- Astronomy manifest `proven=false`; yeni Nakshatra/Pada exact-head oracle gate sonucu ve remaining applicable precision kanıtları açık olduğundan RC-1436 DONE değildir.
- `requirements/reference_manifests/rc1439_reference_images.json` status `NOT_PROVEN`, `images=[]`; physical reference-dependent UI release gate'leri açıktır.
- RC-1437 specialist runtime-assets SUCCESS olsa da packaged/version/checksum/offline/legal final closure ayrıca gereklidir.
- Exact AKİLES provenance/independent authoritative values açık.
- Encrypted persistence/key management/migrations, full airplane-mode production instrumentation, rendered TR/EN UI/PDF, accessibility/performance, real entitlement/ad/rewarded verifier ve remaining Vedic/Panchanga/Dasha/Varga/Gochara/BaZi proof zincirleri açık.
- RC-1442 exact clean-checkout artifact + tested commit SHA + artifact SHA eşleşmesi bütün 1.442 RC DONE/unblocked olmadan kapanamaz.

## Sonraki devam noktası

1. Yeni exact HEAD üzerinde `RC1436 Nakshatra Pada Independent Oracle` dedicated sonucunu fiziksel doğrula; kırmızıysa `0.02°` budgets'ı gevşetmeden kök nedeni düzelt ve yeniden doğrula.
2. Nakshatra/Pada frame+Moon proof yeşil olduğunda production Lahiri ayanamsha provider'ını ayrıca independent `ayanamshaLongitudeMaxAbsErrorDegrees=0.02°` evidence ile kapat; oracle ayanamsha enjekte edilen frame-isolation testini production ayanamsha proof yerine sayma.
3. RC-1362→1374 airplane-mode release/device koşusunu gerçek production capability instrumentation'a genişlet.
4. Daily-message strict audit, RC-1439 physical references, encrypted persistence/accessibility/performance ve packaged dataset/license zincirlerini bağımsız ilerlet.
5. Cancelled Vedic/calculation workflow'larını SUCCESS kabul etme; exact final HEAD üzerinde zorunlu kritik workflow seti fiziksel çalışmadan lifecycle yükseltme.
6. Yalnız requirement-specific evidence + exact-head SUCCESS varsa matrix state yükselt; global blocker varken DONE verme.
7. RC-0001→RC-1442 tamamı DONE, bütün release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**