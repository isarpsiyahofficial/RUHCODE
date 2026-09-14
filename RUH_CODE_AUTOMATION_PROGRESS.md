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

- Vedic evidence/workflow izolasyonları, semantic validator düzeltmeleri ve fiziksel SUCCESS kayıtları git geçmişinde korunur. RC-0080→0123 calculation/contract kanıtlarının önemli bölümü yeşildir; independent golden/UI/device/release blocker'ları nedeniyle toplu VERIFIED/DONE değildir.
- RC-0092/0093 canonical D9/D2 validatorı ve regression zinciri fiziksel SUCCESS vermiştir; RC-0094/0095 validator locatorı stale provenance başlığından canonical genişletilmiş başlığa hizalanmıştır.
- RC-0090/0091 Rashi/Whole Sign evidence koşuları global writer lock'tan ayrılmıştır. Matrix lifecycle yalnız requirement-specific bütün kanıtlar tamamlanınca ilerletilir.

## RC-1439 physical references

`requirements/reference_manifests/rc1439_reference_images.json` gerçek project-owner/user-supplied fiziksel PNG/JPG referansları ister. Generated/placeholder/synthetic referans kabul edilmez. Kaynak olmadığı için external blocker açık kalır; diğer işler devam eder.

## Security/persistence açık durumu

Production persistence hâlâ standart `sqflite/openDatabase` kullanır. Android Keystore-backed gerçek key lifecycle, encrypted DB adapter, plaintext→encrypted migration ve release-binary persistence proof tamamlanmadan security DONE verilmez. `EncryptedJsonDocumentStore`/policy abstraction'larının varlığı primary SQLite DB'nin encrypted olduğunu kanıtlamaz.

## Western / early-core continuation özeti

- RC-0006, RC-0014/0015/0016, RC-0019/0020/0021, RC-0022→0030, RC-0031→0079 ve ilgili correct-semantic evidence workflow'larında legacy global writer cancellation zincirleri dependency sırasıyla izole edildi; yalnız `main` promotion writer global lock'ta kalır.
- Shifted-semantic RC-0036 House Cusp Degrees, RC-0041→0049 generic-aspect ve RC-0050 Applying/Separating stale promotion zincirleri canlandırılmadı; yanlış requirement promotion riski fail-closed temizlendi.
- RC-0036 gerçek House Rulers calculation katmanı ve regressions eklendi. RC-0052/0053 canonical degree-table sonuçları `WesternNatalChart` içine bağlandı.
- UI Profile validator canonical `today/tools/records/profile` ve TR/EN `Bugün/Today · Araçlar/Tools · Kayıtlar/Records · Profil/Profile` mimarisine hizalandı; legacy `discover/calculate` primary destination geri dönüşü reddedilir.
- Kod/CI varlığı tek başına DONE değildir; requirement matrix blocker'ları korunur.

## Planetary hours / Chinese continuation özeti

- RC-0127→0134 Planetary Hour Structure, RC-0135 Guidance, RC-0136 Weekday Guidance ve RC-0137→0141 Chinese Zodiac evidence workflow'ları doğru semantik doğrulamasından sonra workflow+ref izolasyonuna taşındı.
- Bu izolasyonlar validators/calculation/tests/blocker kapsamını gevşetmedi. Fiziksel SUCCESS görülmeyen queued/pending koşullar lifecycle promotion için kullanılmaz.

## 2026-09-14 RC-0158→RC-0165 calculation-boundary checkpoint

- Requirement matrix yeniden okundu: RC-0142→0157 BaZi/Four Pillars hattı TESTED+blocked iken RC-0158 ve devamındaki Zi Wei/Numerology sınırları NOT_STARTED+blocked durumundaydı. Kod/CI varlığı otomatik lifecycle promotion değildir.
- Binding spec semantiği yeniden doğrulandı: RC-0158 BaZi future-compatibility extension altyapısı; RC-0159 Zi Wei Dou Shu'nun gelecekte ayrı engine olabilmesi; RC-0160 Zi Wei'nin BaZi alt özelliği sayılamaması; RC-0161 numerolojinin tek sistem olmaması; RC-0162 Pythagorean, RC-0163 Chaldean, RC-0164 Lo Shu ayrı modüller; RC-0165 aktif numeroloji sisteminin kullanıcıya/sonuca görünür olması.
- `94311d27dfa71b346b44c9e20829bed7de0437ba` `lib/src/calculation_core/zi_wei/zi_wei_engine.dart` ile bağımsız `ZiWeiDouShuEngine<I,O>` namespace/contract'ını ve fail-closed `engineId/version/sourceId` provenance envelope'ını ekledi. BaZi importu veya BaZi mode/output reuse yoktur; RC-0159/0160 mimari ayrımı fiziksel kod sınırı haline getirildi.
- `6b516289ee2a82bb09040ca27340b065f6cf5e4a` Zi Wei boundary regressionını ekledi: bağımsız engine identity/calculate contract'ı ve boş provenance reddi test edilir.
- `e85c1f21919eafed190ce1d7c411cfe931e71a92` mevcut `BaziCompatibilityEngine` rule/version/source extension point'ini doğrudan RC-0158 regressionına bağladı; versioned kuralların core'u değiştirmeden eklenebilmesi, duplicate rule identity ve invalid score fail-closed davranışı kilitlendi.
- `5c01ed7c25c11670c4e9395d09d30184a382b7c1` mevcut numerology architecture'ını RC-0161→0165 regressions ile kilitledi: Pythagorean/Chaldean/Lo Shu ayrı registered systems kalır, calculator davranışları birbirine karışmaz, active `systemId/displayName/version/sourceId` sonuç envelope'ında görünür ve duplicate/missing-provenance fail-closed çalışır.
- Exact `5c01ed7c25c11670c4e9395d09d30184a382b7c1` Actions taramasında FAILURE=0 ve CANCELLED=0; ancak 88 workflow hâlâ `queued`. Queued SUCCESS değildir. Bu nedenle RC-0158→0165 VERIFIED/DONE yapılmadı ve requirement matrix elle yükseltilmedi.
- Sıradaki dependency işi: exact-head physical test/CI sonuçlarını yeniden oku; gerçek failure çıkarsa kök nedeni düzelt. Ardından RC-0166+ numerology calculation gereksinimlerini binding spec ile tek tek karşılaştır; mevcut algoritmaları varsa direct regression/evidence ile kilitle, eksik calculation varsa canonical ayrı-system sınırlarını bozmadan uygula.

## Açık release blocker'ları

- Exact-release 10-capability airplane APK E2E.
- Android Keystore-backed encrypted primary DB + plaintext→encrypted migration + release-binary persistence proof.
- Daily Message final real-device/UI proof.
- Accessibility/performance release gates.
- AKİLES provenance / remaining independent calculation golden-reference evidence.
- RC-1439 gerçek project-owner physical references.

RC-0001→RC-1442 tamamı DONE, bütün zorunlu release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**