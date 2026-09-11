# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** `IMPLEMENTED`, `DONE` değildir. `DONE` yalnız requirement-specific kanıt ile; calculation/interpretation/UI/TR-EN/offline/Free-PRO/backup/PDF/security/accessibility/performance/clean-checkout/lifecycle/device ve exact-release kapıları gereken kapsamda yeşil olduğunda verilir. Canonical lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; exact kapsam `RC-0001→RC-1442`, toplam **1.442 requirement**. `cancelled` hiçbir zaman SUCCESS sayılmaz.

## Canonical durum

- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0950 implementation/matrix zincirleri mevcut; global golden/device/PDF/backup blocker'ları nedeniyle toplu DONE değildir.
- RC-0951→0964 = IMPLEMENTED + blocked=YES (`5f08942462a0b3784725b9fd7e65de0cc22eb50e`).
- RC-0965→0994 traceability fail-closed; 1.442 requirement doğrudan evidence ile kapanmış değildir.
- RC-0995→1003 authoritative golden contract mevcut; exact AKİLES provenance/independent values eksik.
- RC-1004→1104 implementation/test zincirleri mevcut fakat global blocker'lar açıktır.
- RC-1105→1130 dependency/offline governance mevcut; `pubspec.lock` fiziksel. Yeni Android integration harness SDK bağımlılığı Flutter 3.44.7 `flutter pub get` ile CI'da çözülmeli; lockfile exact clean-checkout öncesi tekrar normalize edilmeden dependency gate final sayılmaz.
- Stacked PR zinciri #1→#16 mevcut. Aktif branch `agent/rc1421-rc1442-release-closure`, PR #16.
- Fiziksel SUCCESS ile doğrulanan kritik gate'ler arasında RC-1304→1344 Golden Lifecycle, RC-1345→1361 Release Cleanliness, RC-1375→1404 Final Traceability, RC-1405→1420 Local Core Cost Architecture ve RC-1437 Runtime Assets vardır; bunlar global DONE değildir.

## RC-1436 independent astronomy accuracy

Canonical toleranslar `requirements/reference_manifests/astronomy_accuracy_budgets.json` içinden okunur ve test geçirmek için gevşetilmez. Global manifest halen `proven=false`.

Fiziksel SUCCESS ile doğrulanan alt-kanıtlar:

- ASC/MC — independent Swiss, canonical `0.05°`.
- Placidus 12 cusp — independent Swiss, canonical `0.05°`.
- Sunrise/sunset — independent Swiss, canonical `60 s`.
- Planetary hours — 25 boundary, canonical `60 s`.
- Nakshatra/Pada — packaged DE440s + Vedic frame normalization + Swiss/Lahiri, canonical `0.02° / 0.02°`.
- Lahiri/Chitrapaksha — packaged 1895→2105 table + independent Swiss, canonical `0.02°`.
- Mean lunar node — independent Swiss, canonical `0.02°`.
- DE440s geocentric longitude — exact head `3c9c87339d05c9298ee3b9c654441c5a522a27cf` üzerinde dedicated run `34586949674` fiziksel SUCCESS; Sun `0.01°`, Moon `0.02°`, gezegenler `0.02°`.
- True lunar node — önceki dedicated run'lar fiziksel SUCCESS; canonical `0.02°`. Global RC-1436 yine DONE değildir.

### DE440s evidence lifecycle / Flutter Quality

- `f450e1cfdef026c23ba52c10534e9c075d2e8cd8` (`fix(ci): materialize RC1436 longitude evidence before full tests`) ile Flutter Quality full testten önce pinned `spiceypy==6.0.0` kurup canonical DE440s materializer'ı çalıştırıyor; Sun/Moon/planet toleransları veya production hesap kodu değiştirilmedi.
- Repair exact head `3c9c87339d05c9298ee3b9c654441c5a522a27cf` üzerinde Flutter Quality run `34586952087` fiziksel `SUCCESS` verdi. Böylece önceki full-suite evidence lifecycle blocker'ı bu head için kapandı.
- Aynı head üzerinde RC1436 Nakshatra/Pada run `34586952057`, DE440s run `34586949674`, Solar Events run `34586951855`, ASC/MC run `34586950781` ve Lahiri run `34586950553` fiziksel `SUCCESS` durumundadır. Legacy `cancelled` calculation/Vedic workflow'ları bunların yerine veya SUCCESS olarak sayılmaz.

## Daily Message strict editorial/release audit

- TR `4018` + EN `4018` = `8036` reviewed exact-date kayıt korunuyor; runtime AI generation/random fallback yasakları korunuyor.
- `Daily Message APK Packaging` önceki fiziksel SUCCESS ile release APK build ve packaged TR/EN asset doğrulamasını kapattı.
- `Daily Message Editorial Contract` run `34586951903` exact `3c9c873...` head üzerinde de fiziksel `SUCCESS`; structural lifecycle, committed editorial ledger, schema normalization, leap-date, rolling release horizon, catalog auditor, packaged offline Flutter catalog loader ve strict catalog zinciri yeşil kalıyor.
- `evidence/content/daily_messages_editorial_progress.json` `EDITORIAL_RELEASE_AUDIT_VERIFIED_DEVICE_PROOF_PENDING` durumunda ve `done=false`; strict CI SUCCESS gerçek Android device proof yerine sayılmaz.
- Kalan: final approved Today/Daily Message UI bağlantısı, Android airplane-mode release APK open/serve kanıtı ve rolling future-stock maintenance.

## RC-1362→1374 airplane-mode lifecycle

- Bağlayıcı contract açıkça RC-1362 test device/emulator airplane-mode egzersizi ile RC-1363→1372 Western/Vedic/Numerology/BaZi/planetary-hours/records/PDF/CSV/professional-client gerçek offline akışlarını ve RC-1374 end-to-end evidence'ı ayrı ayrı ister.
- Önceki workflow yalnız release APK build + emulator install + airplane-mode launch + process-survival smoke sağlıyordu; bu nedenle VERIFIED/DONE için yeterli sayılmadı.
- `58285c3f76385fb68cbc53a2efde42656d8cc9f0` ile `tools/offline/validate_airplane_release_evidence.py` eklendi. Validator startup kanıtını full capability kanıtından fail-closed ayırır.
- `11748535121bb8915b450f9f4062ac44aa671a04` ile airplane workflow exact runtime provenance üretir: checked-out commit SHA, release APK SHA-256/path, emulator serial/model/API, airplane/Wi-Fi/mobile-data state, package PID ve crash log sonucu. JSON + APK checksum + logcat Actions artifact olarak yüklenir ve manifest ikinci kez doğrulanır.
- Startup manifest bilinçli olarak `evidenceScope=startup-smoke`, `exercisedCapabilities=[]`, `endToEndCapabilitiesComplete=false`, `verifiableAsDone=false` taşır. Böylece startup smoke hiçbir zaman RC-1363→1374 E2E kanıtı gibi yanlış yükseltilemez.
- `3b3e8b6bd90380ed0fac9606ce3fb928d70ffb3d` contract'a provenance validator'ı ve bu fail-closed lifecycle kuralını bağladı.
- Önceki exact head `8f49e1a15347b6a13016274fff92149b9452f1b6` için airplane run `34607885267` fiziksel olarak oluşturuldu ancak son kontrolde hâlâ `queued`; SUCCESS değildir ve startup TESTED/VERIFIED yükseltilmez.

### Android calculation capability harness — IMPLEMENTED, proof pending

- `f8347b59bd989377624dc2f783d13049fdfd40b9` ile Flutter SDK `integration_test` dev dependency eklendi. Bu dependency Flutter 3.44.7 tarafından CI'da çözülür; lockfile'ın generated exact sonucu ayrıca clean-checkout öncesi doğrulanacaktır.
- `a1a8a54072b7469741f00c7dfa310b7bc09098d7` ile `integration_test/offline_calculation_capabilities_test.dart` eklendi. Harness gerçek production sınıfları üzerinden Western chart, Vedic, Numerology, BaZi ve Planetary Hours hesaplarını Android device/emulator üzerinde çalıştırır; stub engine kullanmaz.
- `a89ab0785d339b3c0f84a428182ec0f34a35104c` ile `tools/offline/validate_airplane_capability_evidence.py` eklendi. Partial device kanıtını fail-closed doğrular: scope `device-calculation-smoke`, `releaseArtifact=false`, yalnız beş hesaplama capability'si exercised, records/PDF/CSV export+restore/professional-client remaining, `endToEndCapabilitiesComplete=false`, `verifiableAsDone=false` zorunludur.
- `d7d395d24c0dec13ebb0032eeebdd7b7e2645381` ile airplane workflow aynı emulator üzerinde release startup smoke sonrasında, radio state hâlâ airplane=1/Wi-Fi=0/data=0 iken Android integration harness'i çalıştıracak şekilde genişletildi. Harness success olursa ayrı JSON + log artifact üretir; exact release APK kanıtıyla birleştirilmez.
- `6bacd645b7b141e51dafe895d8650853295a3ee4` ile bağlayıcı RC-1362→1374 contract yeni harness/validator'a bağlandı ve partial calculation evidence'ın exact-release E2E yerine geçemeyeceği yazılı olarak sabitlendi.
- Bu beş capability henüz VERIFIED değildir: yeni exact-head CI fiziksel SUCCESS vermedi ve integration harness test artifact çalıştırdığı için requirement'ın exact-release E2E kapısını tek başına kapatamaz.
- Kalan esas blocker: RC-1368 records, RC-1369 PDF, RC-1370 CSV export, RC-1371 CSV restore, RC-1372 professional client management device harness kapsamına eklenmeli; ardından on capability exact release artifact üzerinde production UI/application yolu ile end-to-end çalıştırılıp artifact/device evidence bağlanmalıdır.

## RC-1439 physical references

- `requirements/reference_manifests/rc1439_reference_images.json` bağlayıcı addendum gereği gerçek proje-sahibi/user-supplied fiziksel PNG/JPG referansları ister.
- Generated/placeholder/synthetic referans bu requirement'ı karşılamaz; repository'de required physical source olmadığı için RC-1439 bu açıdan external blocker olarak açık tutulur.
- Bu blocker diğer bağımsız işlerin ilerlemesini durdurmaz ve kanıtsız DONE verilmez.

## Açık blocker'lar

- RC-1362→1374 yeni exact-head workflow fiziksel SUCCESS ile doğrulanmalı. Partial Android calculation harness yalnız RC-1363→1367 için ara cihaz kanıtıdır; exact release değildir ve DONE üretmez.
- RC-1368→1372 records/PDF/CSV export/restore/professional-client device coverage ve sonrasında bütün on capability için exact-release production E2E evidence açık.
- `pubspec.lock`, yeni Flutter SDK integration dependency'sinin Flutter 3.44.7 generated çözümü ile normalize edilip clean-checkout dependency gate'te tekrar doğrulanmalı.
- Daily Message strict editorial ve APK packaging yeşil olsa da gerçek airplane-mode Android catalog open/serve proof ve final approved UI binding açık kalır.
- RC-1439 project-owner physical reference evidence açık.
- Exact AKİLES provenance/independent authoritative values açık.
- Encrypted persistence/key management/migrations, rendered TR/EN UI/PDF, accessibility/performance, real entitlement/ad/rewarded verifier ve remaining Vedic/Panchanga/Dasha/Varga/Gochara/BaZi proof zincirleri açık.
- RC-1442 exact clean-checkout artifact + tested commit SHA + artifact SHA eşleşmesi bütün 1.442 RC DONE/unblocked olmadan kapanamaz.
- Legacy `cancelled` calculation/Vedic workflow'ları SUCCESS sayılmaz.

## Sonraki devam noktası

1. Yeni exact-head RC-1362→1374 workflow run'ını fiziksel doğrula; `flutter analyze`, Android integration build/test veya emulator aşaması kırmızıysa gerçek root cause'u düzelt. Green olsa bile calculation harness'i yalnız partial device evidence say.
2. Aynı fail-closed modelle RC-1368 records, RC-1369 PDF, RC-1370 CSV export, RC-1371 CSV restore ve RC-1372 professional-client management akışlarını Android integration harness kapsamına ekle; gerçek production repository/service katmanlarını kullan.
3. On capability device harness'i yeşil olduktan sonra exact release APK üzerinde production UI/application yollarını otomatik egzersiz eden instrumentation kur; exact release artifact SHA + device + network state + per-capability result olmadan RC-1362→1374 VERIFIED/DONE verme.
4. Daily Message final Today/UI binding ve airplane-mode release APK catalog open/serve proof zincirini aynı cihaz kanıt modeline bağla.
5. Astronomy accuracy manifestte henüz independent/boundary proof taşımayan applicable sınıfları tek tek kapat; global `proven=true` yalnız bütün zorunlu sınıflar gerçekten kanıtlandığında verilir.
6. RC-1439 physical references dış blocker'ını açık tutarken encrypted persistence/key-management/migrations, accessibility/performance ve packaged dataset/license zincirlerini bağımsız ilerlet.
7. Yalnız requirement-specific evidence + physical CI SUCCESS varsa matrix state yükselt; global blocker varken DONE verme.
8. RC-0001→RC-1442 tamamı DONE, bütün release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**
