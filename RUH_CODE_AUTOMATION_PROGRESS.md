# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** `IMPLEMENTED`, `DONE` değildir. `DONE` yalnız requirement-specific kanıt ile; calculation/interpretation/UI/TR-EN/offline/Free-PRO/backup/PDF/security/accessibility/performance/clean-checkout/lifecycle/device ve exact-release kapıları gereken kapsamda yeşil olduğunda verilir. Canonical lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; exact kapsam `RC-0001→RC-1442`, toplam **1.442 requirement**. `cancelled`, `action_required`, queued veya pending hiçbir zaman SUCCESS sayılmaz.

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

Fiziksel SUCCESS ile doğrulanan alt-kanıtlar arasında ASC/MC independent Swiss `0.05°`, Placidus 12 cusp `0.05°`, sunrise/sunset `60 s`, planetary hours `60 s`, Nakshatra/Pada `0.02° / 0.02°`, Lahiri `0.02°`, mean/true lunar node `0.02°` ve DE440s Sun `0.01°`, Moon/planet `0.02°` bulunur. Global RC-1436 yine DONE değildir.

## Daily Message

- TR `4018` + EN `4018` = `8036` reviewed exact-date kayıt korunuyor; runtime AI generation/random fallback yasakları korunuyor.
- Editorial Contract + APK Packaging fiziksel SUCCESS ile strict catalog/loader ve packaging zincirini doğruladı.
- `evidence/content/daily_messages_editorial_progress.json` `EDITORIAL_RELEASE_AUDIT_VERIFIED_DEVICE_PROOF_PENDING`, `done=false` kalır.
- Kalan: final Today/Daily Message UI binding, gerçek Android airplane-mode release APK open/serve kanıtı ve rolling future-stock maintenance.

## RC-1362→1374 airplane-mode lifecycle

Bağlayıcı contract RC-1362 device/emulator airplane mode egzersizi ile RC-1363→1372 Western/Vedic/Numerology/BaZi/planetary-hours/records/PDF/CSV/professional-client gerçek offline akışlarını ve RC-1374 E2E evidence'ı ayrı ayrı ister. Startup smoke veya test-artifact integration harness exact-release E2E yerine geçmez.

- Android production capability harness artık Western/Vedic/Numerology/BaZi/PlanetaryHours/records/pdfExport/csvExport/csvRestore/professionalClientManagement = **10 capability** kapsayacak şekilde kodlandı; bu coverage exact-release APK kanıtı yerine geçmez.
- `c592db67139449b3cf091985b484e387f7c71e60` verified Noto Sans Regular/Bold TTF'lerini, `font_release_provenance.json` ve `binariesPackaged=true` durumunu branch'e fiziksel yazdı.
- `cbfcbd7c8f109664e05d171c6d81005252c64c8d` production PDF service regressionını gerçek `PdfCombinedReportService` composition/byte rendering'e taşıdı.
- `c1bd88f043ac9ca9e8bcd6b2bc0bb80ed2265daa` production factory + packaged fonts + local renderer kullanan `offline_pdf_export_capability_test.dart` testini ekledi.
- `9e5fc8296db8e48194e5de7dec58055f7a41053f` airplane evidence validatorını exact 10 capability setine sabitledi; test-artifact için `releaseArtifact=false` ve `verifiableAsDone=false` zorunluluğu korunur.
- `f4511eadec72ae43d5e1ecca7ea7c8764368ada8` airplane workflow'unu iki integration target + radio-disabled emulator + 10/10 manifest üretimine taşıdı.
- `ae1976d174c89bd3ecaa2d9a2a72f1045a7a235e` binding contract evidence listesini verified PDF assets/runtime/testlerle güncelledi; exact-release instrumentation zorunluluğu korunur.
- Airplane run `34703946487` redundant import nedeniyle analyzer'da kırıldı; `d2ef609d39e2a68b0422ee8e6031c80a7d231cbd` ve `cf2034b205f5cc02d4fd388cedd3599b11d88693` iki analyzer failure'ını kaldırdı. Exact-release 10-capability physical E2E hâlâ açık blocker'dır.

## RC-1369 PDF font/render durumu

- Immutable Noto provenance: upstream `66c4b351c58f99ace5a6265d329080d74b057909`, Regular blob `f27f4ff59562d58480f1cb94194393484b8da9e9`, Bold blob `aae7546dc1905b228aff70cde8c818b82f3a2bc4`, OFL blob `9651ea7d51c39a7778cc327a423fb200350aa948`.
- Fiziksel SHA-256: Regular `478c558ea716033cd60c03438f628dfa75694dcf6b5f6d505a2f05fd2b4f3823`; Bold `1df075a380fc7cb898acf64c1f7b3b4dd780de3caa860178bf929de35817a913`.
- `PDF Structural Contract` run `34682276041` materialization + offline re-check + Flutter manifest regression zincirini fiziksel SUCCESS doğruladı.
- `20b0c851b717e918aff9316009680afac2ab0d0e` formatter line-wrap parser uyumsuzluğunu düzeltti; `c592db...` gerçek binary/provenance commit'ini üretti; `47e969a1eb8e3f6ee69ecac2b948d69655ce41eb` materializerı idempotent hale getirdi.
- Font packaging blocker'ı kapalıdır; production Android rendering + exact-release E2E kanıtı açıktır.

## Vedic calculation CI evidence

- `4384addeace00598c7e81b8b3711c8dfed7b3216` D16/D20/D24 evidence koşularını global requirement-matrix writer kuyruğundan ayırdı; run `34687096050` fiziksel SUCCESS verdi. Global golden/UI/device/release blocker'ları nedeniyle RC-0099→0101 DONE değildir.
- `6488eee6b9eaf02ffdfd74ca5dfd2ff7bff173be` RC-0105→0110 Vimshottari workflow'unu izole etti; exact `d3235da...` run `34721530173` fiziksel SUCCESS verdi. Independent golden/UI/device/release blocker'ları korunur.
- `f9f710e773515e27b2338b311d7ef4bfa1ef0af4` RC-0111→0117 Gochara/Panchanga workflow'unu izole etti; exact `d3235da...` run `34721530902` fiziksel SUCCESS verdi.
- `e2240f63c137da818a6945aecd261bfdfc5fe97f` RC-0120 Shadbala, `d86fd7640c0ddd5b74711d770942ea95704e03e5` RC-0096→0098 D7/D10/D12 ve `95057799742af2e3ad1cc332045e11c94514ca26` RC-0092→0093 D9/D2 evidence koşularını global writer lock'tan ayırdı.
- RC-0092/0093 run `34721531101` cancellation'dan çıkıp gerçek FAILURE üretti. Kök neden calculation değil, production'da bulunmayan eski prose/comment locator tokenlarını ve eski test başlığını arayan stale validator idi.
- `e49bfe3e3a87e7b41f5421ea03e6d2094e74684b` RC-0092/0093 validatorını exact D9/D2 builder wiring, `_navamsaRashi` movable/fixed/dual mapping, `_horaRashi` odd/even Sun/Moon mapping, normalized-longitude/provenance fail-closed guards ve mevcut semantic boundary regressions'a sabitledi. Requirement/formül/tolerans gevşetilmedi.
- RC-0092/0093 run **`34726959476`**, job **`103642658919`** fiziksel SUCCESS verdi: validator ve `flutter test test/calculation_core/vedic/vedic_varga_test.dart` ikisi de yeşil; PR bağlamındaki matrix-promotion adımı beklendiği gibi skipped. Bu yalnız calculation/contract evidence'dır; independent Varga golden/reference, interpretation/editorial, UI ve device/release blocker'ları nedeniyle RC-0092/0093 VERIFIED/DONE değildir.
- `863fef4efd254a1d50a0fa67037972146a9b6031` RC-0080/0081 Independent Vedic Engine, `194b7c76cd1faf51e0c624ac42f98d6e29d24502` RC-0082/0083 Ayanamsha, `49ea0b30e1e2eaab794d1eab515546f82167a03b` RC-0088/0089 Nakshatra/Pada ve `4700ab9ceb7d023c4b16b51e7d2cae1c1f968cce` RC-0121 Planet Strength PR/dispatch evidence koşularını global `requirement-matrix-writers` kilidinden ayırdı.
- `5f2389b3a2516ba9ceae1ef364a25ffb3af8144b` RC-0086/0087 Rahu/Ketu, `34e9b4c43fa4b29d4571c0e6e776d84e174ca7c8` RC-0102→0104 D30/D60/Systematic Varga, `378a23a83f1b9af3811217c64796b99db5327637` RC-0118 Yoga ve `b3e1b149308e6a09be519f3511d1e447621637cb` RC-0119 Ashtakavarga evidence koşularını aynı fail-safe concurrency modeline taşıdı. Yalnız `main` promotion writer global lock'ta kalır; validators/tests/blockers değişmedi.
- `88b062eb2982afecaaade449f02c446b79d394a4` RC-0084/0085 Lagna/Grahas, `7e95ec8be59c421510c6bc5edf83c78768aef37a` RC-0094/0095 D3/D4, `5c4b61721d062e95db2ab5806637438508b42d79` RC-0112/0114 Panchanga Vara ve `a1f62f3eef75fc0fd15967222ba0dd6fbc572384` RC-0123 Muhurta PR/dispatch evidence koşularını global writer lock'tan ayırdı. Mevcut validators/tests/promotion blocker'ları aynen korundu.
- Exact `4178709f15b5245943c27bb663f3bcc90d93436d` fan-out'unda RC-0082/0083, RC-0086/0087, RC-0092/0093, RC-0096→0098, RC-0099→0101, RC-0105→0110, RC-0112/0114, RC-0119, RC-0120 ve RC-0123 fiziksel SUCCESS verdi. Bu sonuçlar yalnız ilgili workflow evidence kapsamını kanıtlar; independent golden/UI/device/release blocker'ları nedeniyle otomatik VERIFIED/DONE yükseltmesi yapılmaz.
- Exact `522367ce59d704ac8265145c8d8b23be96f442f1` üzerinde RC-0094/0095 run `34750773958` gerçek FAILURE verdi. Kök neden calculation değil; validator `RC-0092-RC-0098 fail closed on invalid provenance` eski test başlığını ararken canonical regression `RC-0092-RC-0104 fail closed on invalid provenance` olarak genişlemişti.
- `ba8743a94a3a8c70089a635360de0bcafef905f7` RC-0094/0095 validator locatorını mevcut genişletilmiş provenance regressionına hizaladı; D3/D4 formülü, toleransı, test kapsamı ve blocker'ları gevşetilmedi. Yeni physical SUCCESS henüz kanıtlanmadı.
- `ee67ec8931dbfd67e33cb174bc048909e562ab16` RC-0090/0091 Rashi/Whole Sign PR/dispatch evidence koşularını global writer lock'tan ayırdı. Matrixte RC-0090/0091 hâlâ TESTED + blocked=YES; independent Lagna/ayanamsha golden, UI ve device/release kanıtları açık.
- Matrix yeniden okundu: RC-0094/0095 hâlâ NOT_STARTED; validator düzeltmesi ve CI koşusu tek başına lifecycle yükseltmesi değildir.

## RC-1439 physical references

`requirements/reference_manifests/rc1439_reference_images.json` gerçek project-owner/user-supplied fiziksel PNG/JPG referansları ister. Generated/placeholder/synthetic referans kabul edilmez. Kaynak olmadığı için external blocker açık kalır; diğer işler devam eder.

## Security/persistence açık durumu

Production persistence hâlâ standart `sqflite/openDatabase` kullanır. Android Keystore-backed gerçek key lifecycle, encrypted DB adapter, plaintext→encrypted migration ve release-binary persistence proof tamamlanmadan security DONE verilmez. `EncryptedJsonDocumentStore`/policy abstraction'larının varlığı primary SQLite DB'nin encrypted olduğunu kanıtlamaz.

## Son CI / devam noktası

- Aktif branch `agent/rc1421-rc1442-release-closure`, PR #16.
- Exact `522367ce59d704ac8265145c8d8b23be96f442f1` üzerinde RC-0011/0012, RC-0013 ve RC-0018 physical SUCCESS verdi; RC-0017/0019/0020/0021 gibi bazı erken-core workflow'lar yeni fan-outlarda hâlâ global writer/cancellation etkisi gösteriyordu.
- `73f6ed79f53680d7bfeabd35caf289b617cdbaf6` RC-0019 Real House Cusps PR/dispatch evidence koşularını workflow+ref bazında izole etti.
- `4a56ddf0f0851e21aba0e0a1ee1b4cc0bc061ac7` RC-0020 Real Solar Events PR/dispatch evidence koşularını aynı fail-safe modele taşıdı.
- `dbed6c52e32a6e222014faef84283693026ea01e` RC-0021 Real Moon Phase PR/dispatch evidence koşularını aynı fail-safe modele taşıdı.
- `ee67ec8931dbfd67e33cb174bc048909e562ab16` RC-0090/0091 Rashi/Whole Sign evidence koşularını izole etti.
- Exact `ee67ec8931dbfd67e33cb174bc048909e562ab16` ilk fan-out kontrolünde RC-0019 `pending`, RC-0020 eski koşu `cancelled`; RC-0020 isolation bundan sonra `4a56dd...` ile commit edildi. Queued/pending SUCCESS değildir; sonraki tetiklemede exact latest-head sonuçları fiziksel olarak okunmalıdır.
- Aynı fan-out legacy cancellation sorununu başka workflow'larda da gösteriyor (ör. RC-0023, RC-0052/0053, RC-0054/0056, RC-0062/0063→0067, RC-0069/0070, RC-0071/0072). Bunlar dependency sırasıyla, writer semantiği tek tek doğrulanarak ele alınmalıdır; blind toplu patch yapılmamalıdır.
- Requirement matrixte RC-0017/0018/0019/0020/0021 = TESTED + blocked=YES; RC-0090/0091 = TESTED + blocked=YES; RC-0094/0095 = NOT_STARTED. Kod/CI varlığı DONE değildir.
- 10-capability Android harness SUCCESS verirse RC-1369 test-artifact airplane proof'u güçlenir; RC-1362→1374 VERIFIED/DONE için exact release APK üzerinde tüm 10 production akışının ayrı instrumentation evidence'ı şarttır.
- Sonraki büyük blocker zinciri: Android Keystore + encrypted primary database + plaintext→encrypted migration + release-binary persistence proof; Daily Message final UI/device proof; accessibility/performance; AKİLES provenance; remaining independent calculation/golden evidence.
- RC-1439 external blocker'ını açık tut; synthetic görsel kullanma.
- RC-0001→RC-1442 tamamı DONE, bütün zorunlu release gate'leri green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**
