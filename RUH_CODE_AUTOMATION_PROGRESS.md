# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** `IMPLEMENTED`, `DONE` değildir. `DONE` yalnız requirement-specific kanıt ile; calculation/interpretation/UI/TR-EN/offline/Free-PRO/backup/PDF/security/accessibility/performance/clean-checkout/lifecycle/device ve exact-release kapıları gereken kapsamda yeşil olduğunda verilir. Canonical lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; exact kapsam `RC-0001→RC-1442`, toplam **1.442 requirement**.

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
- Exact `c074c5d5846506dabfd6c9a4b8aa344544d4e26a` üzerinde Requirements Contract, Flutter Quality, Professional PDF Contract, System Boundaries ve Professional Timeline SUCCESS verdi.
- `cancelled` hiçbir zaman SUCCESS sayılmaz. Exact-head listesinde çok sayıda legacy Vedic/calculation workflow hâlâ cancelled; lifecycle yükseltilmez.

## RC-1436 — independent astronomy accuracy proof

Canonical toleranslar `requirements/reference_manifests/astronomy_accuracy_budgets.json` içinden okunur ve test geçsin diye gevşetilmez. Global manifest halen `proven=false`; bütün accuracy sınıfları tamamlanmadan RC-1436 DONE değildir.

### DE440s / ephemeris
- Resmi JPL Horizons cross-model/provenance evidence ile strict same-DE440s bağımsız NAIF CSPICE/SpiceyPy oracle zinciri mevcut.
- Same-kernel regression production Dart SPK Type-2 evaluator'a bağlıdır.

### ASC / MC
- Independent Swiss Ephemeris/pyswisseph oracle 1900/2000/2026/2050/2100 ve cross-hemisphere/longitude/high-latitude kapsamına sahiptir.
- Canonical ASC/MC toleransları `0.05°`; değiştirilmemiştir.
- `RC1436 ASC MC Independent Oracle` run `34443503983` fiziksel SUCCESS verdi.

### Placidus house cusps
- Canonical house cusp toleransı `0.05°`; değiştirilmemiştir.
- Production strict solver + fail-closed polar davranışını korur.
- Exact `91b9894daed74c8108c1f05f8c7dccf210e9a7af` HEAD üzerindeki `RC1436 Placidus Independent Oracle` run `34464643535` **SUCCESS** verdi.

### Sunrise / sunset
- Canonical `sunriseSunsetMaxAbsErrorSeconds=60`; değiştirilmemiştir.
- `a676d123f11065c28a9183f60ad0605eb6730c32` ile independent Swiss `swe.rise_trans` materializer, provider version/binary SHA evidence, fail-closed drift verifier, real `SolarEvents.forDate` regression ve dedicated CI eklendi.
- Beş vaka 1900/2000/2026/2050/2100, N/S hemisphere, E/W longitude, farklı fixed UTC offset ve >60° non-polar latitude kapsar.
- Yerel independent karşılaştırma tüm sunrise/sunset sapmalarını 60 s altında gösterdi; exact-head dedicated Actions SUCCESS görülmeden VERIFIED değildir.

### Planetary-hour boundaries
- Canonical `planetaryHourBoundaryMaxAbsErrorSeconds=60`; değiştirilmemiştir.
- `a148b42828affc9b91a8ed8b9cf3e183b69c10b1` ile independent Swiss planetary-hour boundary proof zinciri eklendi.
- `tools/data/materialize_planetary_hours_swiss_oracle.py` production `PlanetaryHours`/`SolarEvents` çağırmadan Swiss sunrise/sunset/next-sunrise anchor'ları üretir ve 12 day + 12 night unequal-hour intervalini bağımsız biçimde böler.
- `evidence/rc1436/planetary_hours_swiss_oracle.json` aynı cross-range/cross-hemisphere/cross-timezone beş vaka için 25 unique boundary taşır; provider version + binary SHA provenance bağlıdır.
- `test/calculation_core/planetary_hours_independent_oracle_test.dart` gerçek production `PlanetaryHours.forDate` sonucundaki 24 slotun 25 sınırının tamamını canonical 60 s bütçeye karşı doğrular ve strict monotonicity/day-night join şartını kontrol eder.
- `tools/data/verify_planetary_hours_swiss_oracle.py` deterministic metadata/numerical drift'i fail-closed reddeder.
- `.github/workflows/rc1436-planetary-hours-oracle.yml` Python 3.13 + pinned `pyswisseph==2.10.3.2`, regenerate+verify ve Flutter production regression'ını aynı dedicated gate'e bağlar.
- Exact-head CI SUCCESS görülmeden bu alt-kanıt VERIFIED değildir.

## Açık blocker'lar

- Daily-message strict editorial release audit kapanmadan RC-1425/1426/1433/1434 release-DONE değildir.
- Astronomy manifest `proven=false`; solar-events ve planetary-hours exact-head CI sonuçları ile Nakshatra/Pada ve diğer applicable precision kanıtları açık olduğundan RC-1436 DONE değildir.
- `requirements/reference_manifests/rc1439_reference_images.json` status `NOT_PROVEN`, `images=[]`; physical reference-dependent UI release gate'leri açıktır.
- RC-1437 specialist runtime-assets SUCCESS olsa da packaged/version/checksum/offline/legal final closure ayrıca gereklidir.
- Exact AKİLES provenance/independent authoritative values açık.
- Encrypted persistence/key management/migrations, full airplane-mode production instrumentation, rendered TR/EN UI/PDF, accessibility/performance, real entitlement/ad/rewarded verifier ve remaining Vedic/Panchanga/Dasha/Varga/Gochara/BaZi proof zincirleri açık.
- RC-1442 exact clean-checkout artifact + tested commit SHA + artifact SHA eşleşmesi bütün 1.442 RC DONE/unblocked olmadan kapanamaz.

## Sonraki devam noktası

1. Exact final HEAD üzerinde `RC1436 Solar Events Independent Oracle` ve `RC1436 Planetary Hours Independent Oracle` dedicated sonuçlarını fiziksel doğrula; kırmızıysa toleransı gevşetmeden kök nedeni düzelt.
2. Nakshatra (`0.02°`) ve Pada (`0.02°`) independent oracle/boundary kanıtlarını tamamla.
3. RC-1362→1374 airplane-mode release/device koşusunu gerçek production capability instrumentation'a genişlet.
4. Daily-message strict audit, RC-1439 physical references, encrypted persistence/accessibility/performance ve packaged dataset/license zincirlerini bağımsız ilerlet.
5. Cancelled Vedic/calculation workflow'larını SUCCESS kabul etme; exact final HEAD üzerinde zorunlu kritik workflow seti fiziksel çalışmadan lifecycle yükseltme.
6. Yalnız requirement-specific evidence + exact-head SUCCESS varsa matrix state yükselt; global blocker varken DONE verme.
7. RC-0001→RC-1442 tamamı DONE, bütün release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**
