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
- Exact `cb496ae263217904d353cf7df0bdd38e4a7f837b` üzerinde ASC/MC independent oracle run `34487706250` ve Placidus independent oracle run `34487708475` fiziksel SUCCESS verdi. Çok sayıda legacy Vedic/calculation workflow aynı exact HEAD üzerinde `cancelled`; lifecycle yükseltilmez.

## RC-1436 — independent astronomy accuracy proof

Canonical toleranslar `requirements/reference_manifests/astronomy_accuracy_budgets.json` içinden okunur ve test geçsin diye gevşetilmez. Global manifest halen `proven=false`; bütün applicable accuracy sınıfları tamamlanmadan RC-1436 DONE değildir.

### DE440s / ephemeris
- Resmi JPL Horizons cross-model/provenance evidence ile strict same-DE440s bağımsız NAIF CSPICE/SpiceyPy oracle zinciri mevcut.
- Same-kernel regression production Dart SPK Type-2 evaluator'a bağlıdır.

### ASC / MC
- Independent Swiss Ephemeris/pyswisseph oracle 1900/2000/2026/2050/2100 ve cross-hemisphere/longitude/high-latitude kapsamına sahiptir.
- Canonical ASC/MC toleransları `0.05°`; değiştirilmemiştir.
- Exact `cb496ae263217904d353cf7df0bdd38e4a7f837b` üzerinde run `34487706250` fiziksel SUCCESS verdi.

### Placidus house cusps
- Canonical house cusp toleransı `0.05°`; değiştirilmemiştir.
- Production strict solver + fail-closed polar davranışını korur.
- Exact `cb496ae263217904d353cf7df0bdd38e4a7f837b` üzerinde run `34487708475` fiziksel SUCCESS verdi.

### Sunrise / sunset
- Canonical `sunriseSunsetMaxAbsErrorSeconds=60`; değiştirilmemiştir.
- `a676d123f11065c28a9183f60ad0605eb6730c32` ile independent Swiss `swe.rise_trans` materializer, provenance evidence, drift verifier, real `SolarEvents.forDate` regression ve dedicated CI eklendi.
- `d5a3f9456b34f3854f979c6b6bef8af7220d3ae5` build-dependent compiled-extension binary SHA equality'sini kaldırdı; iki SHA'nın da geçerli 64-hex olması zorunlu kaldı.
- Exact `cb496ae263217904d353cf7df0bdd38e4a7f837b` run `34487708791` yeniden FAILURE verdi. Kök neden ürün doğruluk bütçesi değil: pinned Swiss source iki build arasında New York sunrise oracle değerinde `564.7683026641607` vs `564.7683025896549` dakika, yani yalnız yaklaşık **4.47 mikrosaniye** floating-point drift üretti; eski generic `1e-9` dakika reproducibility eşiği bunu reddetti.
- `8bf7d726e69cf7927342c745271ca67de69ad9f0` ile verifier unit-aware hale getirildi: yalnız oracle `MinutesFromCivilDateMidnight` alanlarında `1e-6` dakika (=60 mikrosaniye), oracle `JulianDayUt` alanlarında `1e-9` gün (=86.4 mikrosaniye) reproducibility eşiği kullanılır; metadata ve diğer numerikler `1e-9` absolute kontrolünde kalır. Bu eşikler canonical 60 saniye ürün bütçesinden en az yüz binlerce kat daha sıkıdır; ürün astronomy toleransı değiştirilmemiştir.
- Yeni exact-head dedicated CI fiziksel SUCCESS görülmeden solar alt-kanıt VERIFIED değildir.

### Planetary-hour boundaries
- Canonical `planetaryHourBoundaryMaxAbsErrorSeconds=60`; değiştirilmemiştir.
- `a148b42828affc9b91a8ed8b9cf3e183b69c10b1` ile independent Swiss boundary proof zinciri eklendi; 24 slotun 25 unique boundary'si real production `PlanetaryHours.forDate` ile karşılaştırılır.
- `03aa1cb72fb7301a15619bf42c5a159786e77307` ile planetary-hour verifier da aynı unit-aware, build-noise-only reproducibility politikasına bağlandı: minute oracle alanları `1e-6` dakika, Julian Day oracle alanları `1e-9` gün; metadata ve diğer numerikler `1e-9` kalır. Canonical 60 saniyelik accuracy budget değişmedi.
- Yeni exact-head independent dedicated CI SUCCESS görülmeden planetary-hour alt-kanıt VERIFIED değildir.

### Nakshatra / Pada
- Canonical accuracy budget: Nakshatra `0.02°`, Pada `0.02°`; sınıflandırma rounded/display değerden değil ham sidereal longitude'dan yapılmalıdır.
- Production `VedicAyanamshaCatalog` varsayılanı `lahiri-chitrapaksha` olarak fail-closed bağlar; `VedicNakshatra.fromSnapshot` ham normalize sidereal Moon longitude'u 27 Nakshatra × 4 Pada olarak partition eder.
- Independent Swiss/Lahiri end-to-end oracle eklenmeden önce production DE440s state'in J2000-ecliptic frame semantiği ile Vedic tropical-of-date/sidereal dönüşüm zinciri authoritative oracle'a karşı doğrulanmalıdır. Yanlış frame/ayanamsha varsayımıyla sahte green üretmek yasaktır; bu alt-kanıt açıktır.

## Açık blocker'lar

- Daily-message strict editorial release audit kapanmadan RC-1425/1426/1433/1434 release-DONE değildir.
- Astronomy manifest `proven=false`; solar-events ve planetary-hours yeni exact-head independent CI sonuçları ile Nakshatra/Pada ve diğer applicable precision kanıtları açık olduğundan RC-1436 DONE değildir.
- `requirements/reference_manifests/rc1439_reference_images.json` status `NOT_PROVEN`, `images=[]`; physical reference-dependent UI release gate'leri açıktır.
- RC-1437 specialist runtime-assets SUCCESS olsa da packaged/version/checksum/offline/legal final closure ayrıca gereklidir.
- Exact AKİLES provenance/independent authoritative values açık.
- Encrypted persistence/key management/migrations, full airplane-mode production instrumentation, rendered TR/EN UI/PDF, accessibility/performance, real entitlement/ad/rewarded verifier ve remaining Vedic/Panchanga/Dasha/Varga/Gochara/BaZi proof zincirleri açık.
- RC-1442 exact clean-checkout artifact + tested commit SHA + artifact SHA eşleşmesi bütün 1.442 RC DONE/unblocked olmadan kapanamaz.

## Sonraki devam noktası

1. Exact final HEAD üzerinde `RC1436 Solar Events Independent Oracle` ve `RC1436 Planetary Hours Independent Oracle` dedicated sonuçlarını fiziksel doğrula; kırmızıysa canonical 60 saniyelik accuracy budget'ı gevşetmeden kök nedeni düzelt.
2. Nakshatra/Pada için DE440s J2000-ecliptic → Vedic tropical-of-date/sidereal frame zincirini authoritative independent oracle'a karşı doğrula; ardından Nakshatra `0.02°` ve Pada `0.02°` evidence/boundary gate'ini kur.
3. RC-1362→1374 airplane-mode release/device koşusunu gerçek production capability instrumentation'a genişlet.
4. Daily-message strict audit, RC-1439 physical references, encrypted persistence/accessibility/performance ve packaged dataset/license zincirlerini bağımsız ilerlet.
5. Cancelled Vedic/calculation workflow'larını SUCCESS kabul etme; exact final HEAD üzerinde zorunlu kritik workflow seti fiziksel çalışmadan lifecycle yükseltme.
6. Yalnız requirement-specific evidence + exact-head SUCCESS varsa matrix state yükselt; global blocker varken DONE verme.
7. RC-0001→RC-1442 tamamı DONE, bütün release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**
