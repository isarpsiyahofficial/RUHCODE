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
- RC-1105→1130 dependency/offline governance mevcut; `pubspec.lock` exact clean-checkout öncesi Flutter 3.44.7 ile yeniden normalize/doğrulanmalıdır.
- Stacked PR zinciri #1→#16 mevcut. Aktif branch `agent/rc1421-rc1442-release-closure`, PR #16.
- Fiziksel SUCCESS ile doğrulanan kritik gate'ler arasında RC-1304→1344 Golden Lifecycle, RC-1345→1361 Release Cleanliness, RC-1375→1404 Final Traceability, RC-1405→1420 Local Core Cost Architecture ve RC-1437 Runtime Assets vardır; global DONE değildir.

## RC-1436 independent astronomy accuracy

Canonical toleranslar `requirements/reference_manifests/astronomy_accuracy_budgets.json` içinden okunur ve test geçirmek için gevşetilmez. Global manifest halen `proven=false`.

Fiziksel SUCCESS ile doğrulanan alt-kanıtlar arasında ASC/MC independent Swiss `0.05°`, Placidus 12 cusp `0.05°`, sunrise/sunset `60 s`, planetary hours `60 s`, Nakshatra/Pada `0.02° / 0.02°`, Lahiri `0.02°`, mean/true lunar node `0.02°` ve DE440s Sun `0.01°`, Moon/planet `0.02°` bulunur. Flutter Quality run `34586952087` exact `3c9c87339d05c9298ee3b9c654441c5a522a27cf` üzerinde SUCCESS verdi. Global RC-1436 yine DONE değildir.

## Daily Message

- TR `4018` + EN `4018` = `8036` reviewed exact-date kayıt korunuyor; runtime AI generation/random fallback yasakları korunuyor.
- Editorial Contract + APK Packaging fiziksel SUCCESS ile strict catalog/loader ve packaging zincirini doğruladı.
- `evidence/content/daily_messages_editorial_progress.json` `EDITORIAL_RELEASE_AUDIT_VERIFIED_DEVICE_PROOF_PENDING`, `done=false` kalır.
- Kalan: final Today/Daily Message UI binding, gerçek Android airplane-mode release APK open/serve kanıtı ve rolling future-stock maintenance.

## RC-1362→1374 airplane-mode lifecycle

Bağlayıcı contract RC-1362 device/emulator airplane mode egzersizi ile RC-1363→1372 Western/Vedic/Numerology/BaZi/planetary-hours/records/PDF/CSV/professional-client gerçek offline akışlarını ve RC-1374 E2E evidence'ı ayrı ayrı ister. Startup smoke, partial integration harness veya host-only test exact-release E2E yerine geçmez.

- Startup manifest `evidenceScope=startup-smoke`, `exercisedCapabilities=[]`, `endToEndCapabilitiesComplete=false`, `verifiableAsDone=false` taşır.
- Android production capability harness şu anda Western/Vedic/Numerology/BaZi/PlanetaryHours/records/csvExport/csvRestore/professionalClientManagement = **9 capability** kapsar; `remainingCapabilities=[pdfExport]`, `releaseArtifact=false`, `endToEndCapabilitiesComplete=false`, `verifiableAsDone=false` korunur.
- Exact `7752a3c1906b0c731bb770e7a1032bbd1424d271` dalgasındaki airplane workflow run `34631134664` için `contract-and-unit` job fiziksel SUCCESS verdi; emulator/release-launch zinciri tamamlanmadan tüm airplane hattı VERIFIED değildir.

## RC-1369 PDF font/render blocker

Approved packaged Unicode font binary + exact SHA-256 zinciri olmadan PDF byte rendering fail-closed kalır. Placeholder, system-font fallback veya hash bypass yoktur.

- `dac7363d6cb3b242de9404a649b3c06afabca885`: canonical Noto Sans/OFL-1.1 font release manifesti.
- `37b0c482682f22c51562b2398e974f2427c06d0c`: unverified font state'in release-ready olamayacağını kilitleyen regression testi.
- `dea6e3806def235ec5bb1f2a14d37fc2c5fe32b5`: `createProductionCombinedPdfService(...)`; manifest READY değilse unavailable, READY ise gerçek `PdfAssetFontBundleProvider + PdfCombinedReportService`.
- `7a935911f9e0704146c7d342764c746bae14023d`: `RuhCodeRuntime.create()` canonical factory + `rootBundle` yoluna bağlandı.
- `24af1da2e44bc00e85ab6fcc54e8adfcc6fa694b`: production composition fail-closed regression testi.
- Exact approved font binary'leri halen repository asset'i değildir; `regularSha256`/`boldSha256` boş, `binariesPackaged=false`; RC-1369 TESTED/VERIFIED/DONE değildir.

## Bu çalıştırma — CI root-cause repair

Exact `c7f0c7204d7cfd0257bc61957e932b932e0e7dd8` üzerinde iki kritik fiziksel kırmızı doğrulandı:

1. `Requirements Contract` run `34660674237` FAILURE. Job içindeki ilk kırmızı adım `Validate visible combined PDF runtime/action/accessibility contract` idi. Kök neden requirement veya runtime bozulması değil, validator'ın eski hard-coded `UnavailablePdfService<PdfCombinedReportProjection>` token'ını beklemesiydi. Production runtime artık canonical fail-closed factory kullanıyor.
2. `RC-0099 RC-0101 Vedic D16 D20 D24` run `34660675650` FAILURE. Kök neden validator'ın eski `RC-0092-RC-0101 fail closed on invalid provenance` test adını beklemesi; regression testi daha güçlü biçimde RC-0104'e kadar genişlemiş durumda.

Uygulanan repair commit'leri:

- `635f7c4b0777ca39087e86b051c2af507bb16ec1` — combined PDF UI runtime validator'ı gerçek production composition'a hizalandı; `production_combined_pdf_service.dart` ve `createProductionCombinedPdfService(bundle: rootBundle)` artık binding evidence olarak aranıyor. Fail-closed font şartı kaldırılmadı.
- `052f78d4db85252455df551a41f634af51fc7d48` — RC-0099→0101 validator'ı mevcut ve daha geniş `RC-0092-RC-0104 fail closed on invalid provenance` regression adıyla hizalandı; D16/D20/D24 hesap kuralları/toleransları değiştirilmedi.

Repair exact head `052f78d4db85252455df551a41f634af51fc7d48` üzerinde yeni CI dalgası fiziksel olarak oluştu. `Requirements Contract` run `34666327804` queued idi. Legacy workflow'lardaki `cancelled` sonuçlar SUCCESS sayılmaz. Aynı exact head üzerindeki `RC-0099 RC-0101 Vedic D16 D20 D24` run `34666327631` concurrency/cancellation nedeniyle cancelled oldu; bu yüzden TESTED/VERIFIED yükseltmesi yapılmadı ve sonraki tetiklemede yeni fiziksel non-cancelled run aranmalıdır.

Bu progress checkpoint commit'i yalnız continuation state kaydıdır; test/evidence yerine sayılmaz ve CI sonucu yükseltmez.

## RC-1439 physical references

`requirements/reference_manifests/rc1439_reference_images.json` gerçek project-owner/user-supplied fiziksel PNG/JPG referansları ister. Generated/placeholder/synthetic referans kabul edilmez. Kaynak olmadığı için external blocker açık kalır; diğer işler devam eder.

## Security/persistence açık durumu

Production persistence hâlâ standart `sqflite/openDatabase` kullanır. Android Keystore-backed gerçek key lifecycle, encrypted DB adapter, plaintext→encrypted migration ve release-binary persistence proof tamamlanmadan security DONE verilmez.

## Açık blocker'lar / devam noktası

1. Son progress checkpoint sonrasındaki exact branch head üzerinde `Requirements Contract` ve Varga D16/D20/D24 workflow sonuçlarını fiziksel doğrula; kırmızıysa ilk gerçek failing step/log üzerinden root cause'u düzelt. `cancelled` sonucu kabul etme.
2. Approved/reproducible Noto Sans Regular/Bold binary'lerini truthful source/license provenance ile repository asset'i olarak ekle; exact SHA-256'ları manifestte pinle ve `pubspec.yaml` packaging zincirini doğrula. Placeholder/system fallback/hash gevşetmesi kullanma.
3. Manifest READY olduktan sonra production factory'nin gerçek renderer dalını unit/widget + Android üzerinde doğrula; RC-1369 `pdfExport`u airplane harness'e 10. capability olarak ekle. Integration evidence exact-release E2E yerine sayılmasın.
4. On capability partial device harness green olduktan sonra exact release APK production UI/application yollarını exact artifact SHA + device/network/per-capability evidence ile egzersiz et.
5. Daily Message final UI/device proof; encryption/key-management/migrations; accessibility/performance; AKİLES provenance; remaining calculation/Vedic/Panchanga/Dasha/Varga/Gochara/BaZi kanıtlarını bağımsız ilerlet.
6. RC-1439 external blocker'ı açık tut; synthetic görsel kullanma.
7. RC-0001→RC-1442 tamamı DONE, bütün zorunlu release gate'leri green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**
