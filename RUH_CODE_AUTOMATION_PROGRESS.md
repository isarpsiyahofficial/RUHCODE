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
- RC-1436 alt-kanıtlarında ASC/MC, Placidus, Solar Events, Planetary Hours, Nakshatra/Pada ve Lahiri Ayanamsha independent oracle gate'leri fiziksel SUCCESS ile doğrulanmıştır. Legacy `cancelled` workflow'lar SUCCESS değildir.

## RC-1436 — independent astronomy accuracy proof

Canonical toleranslar `requirements/reference_manifests/astronomy_accuracy_budgets.json` içinden okunur ve test geçsin diye gevşetilmez. Global manifest halen `proven=false`; bütün applicable accuracy sınıfları tamamlanmadan RC-1436 DONE değildir.

### DE440s / ephemeris
- Resmi JPL Horizons cross-model/provenance evidence ile strict same-DE440s bağımsız NAIF CSPICE/SpiceyPy oracle zinciri mevcut.
- Same-kernel regression production Dart SPK Type-2 evaluator'a bağlıdır.
- DE440s runtime kontratı geometric geocentric **J2000-ecliptic** state üretir; bu semantik `EclipticReferenceFrame.j2000Geometric` ile explicit taşınır (`37b2ff4f7fc2adbcc022a37095a3c84e942e611e`, `74300d755efbf3fd020a5443130dfdf9ba93ccbb`).
- `2953598cb6b147be8b8970754a044029eb9eb033` ile independent CSPICE `ECLIPJ2000` geocentric longitude materializer eklendi. Oracle, CSPICE `unitim(JDTDT -> ET)` + `spkgeo(... observer=399, frame=ECLIPJ2000)` kullanır; production TT→TDB ve ecliptic rotation kodunu reuse etmez.
- `40bee6682e7f6f7fefedf007f94b89f3e1ba0bf5` ile packaged `De440sEphemerisProvider` için 10 fiziksel gövde × 5 epoch = 50 vaka regression eklendi. Test canonical Sun `0.01°`, Moon `0.02°`, planet `0.02°` bütçelerini manifestten okur ve 1900/2000/2026/2050/2100 aralığını kapsar.
- `928fb7e1d630e21fd070d20ff614c383767ed714` dedicated `RC1436 DE440s Geocentric Longitude Independent Oracle` CI gate'ini ekledi. Gate physical SUCCESS vermeden Sun/Moon/planet longitude alt-kanıtları VERIFIED değildir.

### ASC / MC
- Independent Swiss Ephemeris/pyswisseph oracle 1900/2000/2026/2050/2100 ve cross-hemisphere/longitude/high-latitude kapsamına sahiptir.
- Canonical ASC/MC toleransları `0.05°`; exact-head independent oracle fiziksel SUCCESS ile doğrulanmıştır.

### Placidus house cusps
- Canonical house cusp toleransı `0.05°`; production strict solver + fail-closed polar davranışı korunur.
- Exact-head independent oracle fiziksel SUCCESS ile doğrulanmıştır.

### Sunrise / sunset
- Canonical `sunriseSunsetMaxAbsErrorSeconds=60`; değiştirilmemiştir.
- Independent Swiss `swe.rise_trans` materializer/provenance/evidence/drift verifier/real `SolarEvents.forDate` regression zinciri exact-head fiziksel SUCCESS vermiştir.

### Planetary-hour boundaries
- Canonical `planetaryHourBoundaryMaxAbsErrorSeconds=60`; değiştirilmemiştir.
- Independent Swiss proof 24 slotun 25 unique boundary'sini real production `PlanetaryHours.forDate` ile karşılaştırır ve physical SUCCESS vermiştir.

### Nakshatra / Pada
- Canonical budget Nakshatra `0.02°`, Pada `0.02°`; classification raw/unrounded sidereal longitude kullanır.
- J2000-ecliptic → tropical-of-date Vedic frame normalization (`4ace136ef408403206230f4509238f5aa5282c86`, `22f2ab682f53bc898a4252090209ec1290f1d1d6`) shared DE440s kontratını değiştirmeden production Vedic path'e bağlıdır.
- Pinned Swiss Ephemeris/Moshier + `SIDM_LAHIRI`, `FLG_TRUEPOS`, `FLG_NONUT` oracle/evidence ve packaged DE440s production regression zinciri mevcuttur.
- Dedicated `RC1436 Nakshatra Pada Independent Oracle` physical SUCCESS vermiştir. Bu alt-kanıt VERIFIED kabul edilebilir; RC-1436 bütünü değildir.

### Lahiri / Chitrapaksha ayanamsha
- Canonical `ayanamshaLongitudeMaxAbsErrorDegrees=0.02`; değiştirilmemiştir.
- Önceki Nakshatra/Pada regression oracle ayanamsha enjekte ettiği için production ayanamsha doğruluğu yerine sayılmamıştır.
- `dd68940aa3a2bc6ec902a76f2caec8bd2dde7ff1` ile independently generated Swiss Ephemeris `SIDM_LAHIRI` 5-year tabulated physical dataset `assets/data/ayanamsha/lahiri_chitrapaksha_5y.json` eklendi. Dataset 1895→2105 coverage taşır ve explicit source version/checksum içerir.
- `e17660261cffff660dc5f39f2a9a01d47d30f9df` ile `BundledLahiriAyanamsha` production adapter'ı gerçek `TabulatedAyanamshaProvider` fail-closed interpolation path'ini `VedicAyanamshaProvider` runtime kontratına bağladı; extrapolation mevcut provider tarafından yasaktır.
- `6fb77163a37ffed36c73a132e9b03476a7a3a0af` ile ayanamsha asset dizini Flutter package asset setine eklendi.
- `009323944f2385d951bcd1ec07e3ef09cc71f5d8` ile 1900/2000/2026/2050/2100 independent Swiss Lahiri oracle cases fiziksel evidence olarak eklendi. Oracle tarihler tablonun 5-year Jan-01 örnekleri değildir; böylece interpolation gerçek bağımsız ara noktalar üzerinden sınanır.
- `9b018481f16d1c3b83dc0ae035f42fb4f221b21b` real packaged `BundledLahiriAyanamsha.load()` sonuçlarını canonical `0.02°` budget'a bağlayan regression ekledi.
- `3f309fd4cd59fc207df2e9560d1b41a5fe70bf8b` dedicated `RC1436 Lahiri Ayanamsha Independent Oracle` CI gate'ini ekledi.
- `8f289ad590df576b5044503f0d5dbcbbf5865ce2` / `7a29595fc7fa71a713b6767875f04d33f204ea95` reproducibility verifier + pinned CI zincirini bağladı.
- Dedicated `RC1436 Lahiri Ayanamsha Independent Oracle` run **34525091663 = SUCCESS**. Lahiri alt-kanıtı VERIFIED kabul edilebilir; global RC-1436 değildir.

## CI / entitlement düzeltmesi

- Exact `7a29595f...` HEAD'de `Feature Entitlement Contract` run `34525089261` yalnız source validator'ın stale test-title tokenı nedeniyle kırmızıydı; gerçek test artık menu yüzeyini de kapsayan `UI menu route and service surfaces use the same EntitlementService result` adını taşıyor.
- `ab34e71d95142bb4aadf6918ba1468196f56e82a` validator tokenını gerçek regression adıyla hizaladı. Requirement/evidence semantiği veya entitlement policy gevşetilmedi. Yeni exact-head CI fiziksel SUCCESS vermeden bu kırmızı kapı kapanmış sayılmaz.

## Açık blocker'lar

- Daily-message strict editorial release audit kapanmadan RC-1425/1426/1433/1434 release-DONE değildir.
- Astronomy manifest `proven=false`; DE440s geocentric longitude gate sonucu ve node longitude bağımsız accuracy proof'u açık olduğundan RC-1436 DONE değildir.
- `requirements/reference_manifests/rc1439_reference_images.json` status `NOT_PROVEN`, `images=[]`; physical reference-dependent UI release gate'leri açıktır.
- RC-1437 specialist runtime-assets SUCCESS olsa da packaged/version/checksum/offline/legal final closure ayrıca gereklidir.
- Exact AKİLES provenance/independent authoritative values açık.
- Encrypted persistence/key management/migrations, full airplane-mode production instrumentation, rendered TR/EN UI/PDF, accessibility/performance, real entitlement/ad/rewarded verifier ve remaining Vedic/Panchanga/Dasha/Varga/Gochara/BaZi proof zincirleri açık.
- RC-1442 exact clean-checkout artifact + tested commit SHA + artifact SHA eşleşmesi bütün 1.442 RC DONE/unblocked olmadan kapanamaz.

## Sonraki devam noktası

1. Exact HEAD üzerinde `Feature Entitlement Contract` düzeltmesini ve `RC1436 DE440s Geocentric Longitude Independent Oracle` dedicated sonucunu fiziksel doğrula; kırmızıysa canonical bütçeleri gevşetmeden kök nedeni düzelt.
2. Sun/Moon/planet longitude physical SUCCESS sonrası `nodeLongitudeMaxAbsErrorDegrees=0.02` için production lunar-node motorunu bağımsız oracle ile kapat; kanıtsız `proven=true` yapma.
3. RC-1362→1374 airplane-mode release/device koşusunu gerçek production capability instrumentation'a genişlet.
4. Daily-message strict audit, RC-1439 physical references, encrypted persistence/accessibility/performance ve packaged dataset/license zincirlerini bağımsız ilerlet.
5. Cancelled Vedic/calculation workflow'larını SUCCESS kabul etme; exact final HEAD üzerinde zorunlu kritik workflow seti fiziksel çalışmadan lifecycle yükseltme.
6. Yalnız requirement-specific evidence + exact-head SUCCESS varsa matrix state yükselt; global blocker varken DONE verme.
7. RC-0001→RC-1442 tamamı DONE, bütün release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**