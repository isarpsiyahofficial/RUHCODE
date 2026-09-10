# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** `IMPLEMENTED`, `DONE` değildir. `DONE` yalnız requirement-specific kanıt ile; calculation/interpretation/UI/TR-EN/offline/Free-PRO/backup/PDF/security/accessibility/performance/clean-checkout/lifecycle/device ve exact-release kapıları gereken kapsamda yeşil olduğunda verilir. Canonical lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; exact kapsam `RC-0001→RC-1442`, toplam **1.442 requirement**.

## Canonical durum özeti

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
- Fiziksel SUCCESS ile daha önce doğrulanan kritik gate'ler arasında RC-1304→1344 Golden Lifecycle, RC-1345→1361 Release Cleanliness, RC-1375→1404 Final Traceability, RC-1405→1420 Local Core Cost Architecture ve RC-1437 Runtime Assets vardır. Bunlar tek başına global DONE değildir.
- Exact `c074c5d5846506dabfd6c9a4b8aa344544d4e26a` üzerinde Requirements Contract, Flutter Quality, Professional PDF Contract, System Boundaries ve Professional Timeline SUCCESS verdi.
- Cancellation hiçbir zaman SUCCESS sayılmaz; eski Vedic/calculation workflow'larının cancelled olanları yeniden fiziksel SUCCESS almadan lifecycle yükseltilmez.

## RC-1436 — independent astronomy accuracy proof

Canonical toleranslar `requirements/reference_manifests/astronomy_accuracy_budgets.json` içinden okunur ve test geçsin diye gevşetilmez. Global manifest halen `proven=false`; bütün accuracy sınıfları tamamlanmadan RC-1436 DONE değildir.

### DE440s / ephemeris

- Resmi JPL Horizons cross-model/provenance evidence ile strict same-DE440s bağımsız NAIF CSPICE/SpiceyPy oracle zinciri mevcut.
- Same-kernel evaluator regression production Dart SPK Type-2 evaluator'a bağlıdır.

### ASC / MC

- Independent Swiss Ephemeris/pyswisseph oracle 1900/2000/2026/2050/2100 ve cross-hemisphere/longitude/high-latitude kapsamına sahiptir.
- Canonical ASC/MC toleransları `0.05°`; değiştirilmemiştir.
- `RC1436 ASC MC Independent Oracle` run `34443503983` fiziksel SUCCESS verdi.

### Placidus house cusps

- Canonical house cusp toleransı `0.05°`; değiştirilmemiştir.
- Production `PlacidusHouses.calculate` strict solver + fail-closed polar davranışını korur.
- Independent Swiss Ephemeris materializer/evidence/regression/verifier/dedicated workflow zinciri fiziksel repository'dedir.
- Exact `91b9894daed74c8108c1f05f8c7dccf210e9a7af` HEAD üzerindeki `RC1436 Placidus Independent Oracle` run `34464643535` **SUCCESS** verdi. Böylece house-cusp accuracy alt-kanıtı fiziksel CI ile doğrulanmıştır; RC-1436 bütünü henüz DONE değildir.

### Sunrise / sunset — mevcut checkpoint

- Canonical `sunriseSunsetMaxAbsErrorSeconds=60` bütçesi korunmuştur.
- Commit `a676d123f11065c28a9183f60ad0605eb6730c32` ile production `SolarEvents.forDate` için bağımsız Swiss Ephemeris `swe.rise_trans` oracle zinciri eklendi.
- `tools/data/materialize_solar_events_swiss_oracle.py`: production NOAA/Meeus algoritmasını çağırmadan pinned Swiss Ephemeris ile sunrise/sunset eventleri üretir; civil-date eşleşmesi explicit fixed UTC offset ile yapılır.
- `evidence/rc1436/solar_events_swiss_oracle.json`: İstanbul 2026, New York 2000, Sydney 2050, Reykjavik 1900, Quito 2100; kuzey/güney yarımküre, doğu/batı boylam, farklı UTC offsetleri ve >60° non-polar enlem kapsar. Provider version ve binary SHA-256 provenance taşır.
- `test/calculation_core/solar_events_independent_oracle_test.dart`: production `SolarEvents.forDate` sunrise ve sunset UTC dakikalarını canonical 60 saniye bütçeye bağlar; 5 vakanın tümü non-polar normal state zorunludur.
- `tools/data/verify_solar_events_swiss_oracle.py`: metadata/case/numerical drift'i fail-closed reddeder.
- `.github/workflows/rc1436-solar-events-oracle.yml`: Python 3.13 + pinned `pyswisseph==2.10.3.2`, deterministic evidence regeneration, verifier ve Flutter production regression'ını aynı gate'e bağlar.
- Local independent comparison beş vakanın tüm sunrise/sunset sapmalarını canonical 60 saniye altında gösterdi; ancak dedicated exact-head GitHub Actions SUCCESS görülmeden bu alt-kanıt VERIFIED sayılmaz.

## Son dönemde kapatılan gerçek kırmızı kök nedenler

- Flutter analyzer ihlalleri temizlendi (`1132b337...`→`02ddc42e...`).
- Requirements semantic spacing validator (`de480d49...`), PDF filename separator bug'ı (`80068c44...`), storage entitlement validator (`24bacfab...`), transactional snapshot runtime cast (`20f2d0b0...`) kapatıldı.
- Numerology validator gerçek API declaration'larına bağlandı; Personal Growth'a gerçek historical-period comparison eklendi; UI runtime theme semantic spacing/dark palette contract düzeltildi.
- System Boundaries trace regression (`f301b23a...`), Backup verified-restore async test (`7435b87f...`), Professional PDF locale validator (`c478e03f...`) ve Western Natal quincunx fixture (`e9e05066...`) düzeltildi.
- PDF PREVIEW duplicate registry kökü (`54c695f2...`) ve exact-one preflight validator (`17c7bb08...`) kapatıldı.
- Professional Timeline validator (`eb7120cf...`) gerçek enum/test semantiğine bağlandı.
- PDF vector renderer Unicode planetary glyph crash'i deterministic ASCII planetary labels ile giderildi; raster fallback eklenmedi (`fac4b984...`).

## Fiziksel blocker'lar

- Daily-message katalog kapsamı mevcut olsa da strict editorial release audit kapanmadan RC-1425/1426/1433/1434 release-DONE değildir.
- Astronomy manifest `proven=false`; sunrise/sunset dedicated CI sonucu, planetary-hour boundary, Nakshatra/Pada ve diğer applicable precision kanıtları eksik olduğundan RC-1436 DONE değildir.
- `requirements/reference_manifests/rc1439_reference_images.json` status `NOT_PROVEN`, `images=[]`; RC-1431/1439 ve reference-dependent UI release gate'leri açıktır.
- RC-1437 specialist runtime-assets SUCCESS olsa da packaged/version/checksum/offline/legal final closure ayrıca gereklidir.
- Exact AKİLES provenance/independent authoritative values açık.
- Encrypted persistence/key management/migrations, full airplane-mode production instrumentation, rendered TR/EN UI/PDF, accessibility/performance, real entitlement/ad/rewarded verifier ve remaining Vedic/Panchanga/Dasha/Varga/Gochara/BaZi proof zincirleri açık.
- RC-1442 exact clean-checkout artifact + tested commit SHA + artifact SHA eşleşmesi bütün 1.442 RC DONE/unblocked olmadan kapanamaz.

## Sonraki devam noktası

1. Exact final HEAD üzerindeki `RC1436 Solar Events Independent Oracle` sonucunu fiziksel doğrula; kırmızıysa toleransı gevşetmeden verifier/evidence/production numerical kök nedenini düzelt.
2. SUCCESS sonrası planetary-hour boundary (`60 s`) independent oracle + production regression zincirini tamamla.
3. Nakshatra (`0.02°`) ve Pada (`0.02°`) independent oracle/boundary kanıtlarını tamamla.
4. RC-1362→1374 airplane-mode release/device koşusunu gerçek production capability instrumentation'a genişlet.
5. Daily-message strict audit, RC-1439 physical references, encrypted persistence/accessibility/performance ve packaged dataset/license zincirlerini bağımsız ilerlet.
6. Cancelled Vedic/calculation workflow'larını SUCCESS kabul etme; exact final HEAD üzerinde zorunlu kritik workflow seti fiziksel çalışmadan lifecycle yükseltme.
7. Yalnız requirement-specific evidence + exact-head SUCCESS varsa matrix state yükselt; global blocker varken DONE verme.
8. RC-0001→RC-1442 tamamı DONE, bütün release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**
