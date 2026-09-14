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
- Verified PDF font/runtime zinciri branch'te korunur; exact-release production Android rendering kanıtı ayrıca gereklidir.
- Exact-release 10-capability physical E2E hâlâ açık blocker'dır.

## Vedic / Western / early-core evidence özeti

- RC-0006, RC-0014/0015/0016, RC-0019/0020/0021, RC-0022→0030, RC-0031→0079 ve Vedic RC-0080→0123 hattındaki correct-semantic evidence workflow'larının önemli bölümü legacy global writer cancellation kuyruğundan dependency sırasıyla ayrıldı; yalnız `main` promotion writer global lock'ta kalır.
- Shifted-semantic RC-0036 House Cusp Degrees, RC-0041→0049 generic-aspect ve RC-0050 Applying/Separating stale promotion zincirleri canlandırılmadı; yanlış requirement promotion riski fail-closed temizlendi.
- RC-0036 gerçek House Rulers calculation katmanı ve regressions eklendi. RC-0052/0053 canonical degree-table sonuçları `WesternNatalChart` içine bağlandı.
- UI Profile validator canonical `today/tools/records/profile` ve TR/EN `Bugün/Today · Araçlar/Tools · Kayıtlar/Records · Profil/Profile` mimarisine hizalandı; legacy `discover/calculate` primary destination geri dönüşü reddedilir.
- Kod/CI varlığı tek başına DONE değildir; independent golden/UI/device/release blocker'ları korunur.

## RC-1439 physical references

`requirements/reference_manifests/rc1439_reference_images.json` gerçek project-owner/user-supplied fiziksel PNG/JPG referansları ister. Generated/placeholder/synthetic referans kabul edilmez. Kaynak olmadığı için external blocker açık kalır; diğer işler devam eder.

## Security/persistence açık durumu

Production persistence hâlâ standart `sqflite/openDatabase` kullanır. Android Keystore-backed gerçek key lifecycle, encrypted DB adapter, plaintext→encrypted migration ve release-binary persistence proof tamamlanmadan security DONE verilmez. `EncryptedJsonDocumentStore`/policy abstraction'larının varlığı primary SQLite DB'nin encrypted olduğunu kanıtlamaz.

## Planetary hours / Chinese continuation özeti

- RC-0127→0134 Planetary Hour Structure, RC-0135 Guidance, RC-0136 Weekday Guidance ve RC-0137→0141 Chinese Zodiac evidence workflow'ları doğru semantik doğrulamasından sonra workflow+ref izolasyonuna taşındı.
- Bu izolasyonlar validators/calculation/tests/blocker kapsamını gevşetmedi. Fiziksel SUCCESS görülmeyen queued/pending koşullar lifecycle promotion için kullanılmaz.

## 2026-09-14 RC-0158→RC-0171 calculation-boundary checkpoint

- Requirement matrix yeniden okundu: RC-0142→0157 BaZi/Four Pillars hattı TESTED+blocked iken RC-0158 ve devamındaki Zi Wei/Numerology sınırları NOT_STARTED+blocked durumundaydı. Kod/CI varlığı otomatik lifecycle promotion değildir.
- Binding spec semantiği yeniden doğrulandı: RC-0158 BaZi future-compatibility extension altyapısı; RC-0159 Zi Wei Dou Shu'nun gelecekte ayrı engine olabilmesi; RC-0160 Zi Wei'nin BaZi alt özelliği sayılamaması; RC-0161 numerolojinin tek sistem olmaması; RC-0162 Pythagorean, RC-0163 Chaldean, RC-0164 Lo Shu ayrı modüller; RC-0165 aktif numeroloji sisteminin görünür olması; RC-0166→0171 Life Path, Expression/Destiny, Soul Urge, Personality, Birthday ve Maturity hesaplarıdır.
- `94311d27dfa71b346b44c9e20829bed7de0437ba` bağımsız `ZiWeiDouShuEngine<I,O>` namespace/contract'ını ve fail-closed provenance envelope'ını ekledi; BaZi importu/mode-output reuse yoktur.
- `6b516289ee2a82bb09040ca27340b065f6cf5e4a` Zi Wei boundary regressionını ekledi.
- `e85c1f21919eafed190ce1d7c411cfe931e71a92` mevcut `BaziCompatibilityEngine` rule/version/source extension point'ini RC-0158 regressionına bağladı; duplicate rule identity ve invalid score fail-closed davranışı kilitlendi.
- `5c01ed7c25c11670c4e9395d09d30184a382b7c1` Pythagorean/Chaldean/Lo Shu ayrı registered systems, active system identity/provenance görünürlüğü ve duplicate/missing-provenance fail-closed regressionsını ekledi.
- `8292756fa3f706d13b5a7e6744d905acbe1be1ed` var olan Pythagorean calculation motorunu RC-0166→0171'e doğrudan bağlayan requirement regressionını ekledi. Elle doğrulanabilir `2000-01-01 + AB` fixture'ında Life Path=4, Expression=3, Soul Urge=1, Personality=2, Birthday=1, Maturity=7 ve altı ayrı provenance trace'i kilitlenir; Türkçe karakter normalizationının sessiz silme yapmadığı ayrıca kontrol edilir.
- Exact `5c01ed7c25c11670c4e9395d09d30184a382b7c1` Actions taramasında FAILURE=0 ve CANCELLED=0 fakat 88 workflow queued idi. Exact `8292756fa3f706d13b5a7e6744d905acbe1be1ed` üzerinde sorgu anında FAILURE=0 ve 82 workflow queued. Queued SUCCESS değildir; RC-0158→0171 VERIFIED/DONE yapılmadı ve matrix elle yükseltilmedi.
- Sıradaki dependency işi: exact-head physical CI/test sonuçlarını yeniden oku; gerçek failure çıkarsa kök nedeni düzelt. Ardından RC-0172→0185 Balance/Karmic Lessons/Karmic Debt/Hidden Passion/Personal cycles/Pinnacles/Challenges/compatibility/TR-EN normalization/Chaldean table/Lo Shu requirementsını mevcut canonical modüllerle tek tek eşleştir; eksik olanı uygula, mevcut olanı requirement-specific regression/evidence ile kilitle.

## 2026-09-14 RC-0172→RC-0185 numerology verification checkpoint

- Exact `8dbd2f449e5e169f151df70fe66414082c746533` fiziksel Actions taramasında requirement-specific `RC-0166 through RC-0184 Numerology Core` ve `RC-0185 through RC-0186 Lo Shu and Kabbalistic Boundary` SUCCESS verdi. Buna rağmen matrixte RC-0166→0184 NOT_STARTED kaldığı için otomatik promotion yapılmadı; exact current-head kanıtı tekrar gereklidir.
- Aynı exact committe genel `Numerology Core Contract` FAILURE verdi. Job logundaki gerçek kök neden `tools/numerology/validate_pythagorean_profile.py` validator'ının numeroloji QA requirementı RC-0329 yerine ilgisiz RC-0362 secure-personal-data maddesini istemesiydi. `ed2530f7411830bb91fc7fa5d2af500283714359` ile validator RC-0329 bindingine düzeltildi; evidence manifest zaten RC-0329 taşıyordu. Validation kapsamı gevşetilmedi.
- RC-0172 auditinde gerçek calculation bug bulundu: `PythagoreanNumerologyCore.nameNumbers()` Balance Number'ı tüm isim bileşenlerinin baş harflerinden hesaplamak yerine yalnız normalized adın ilk harfini kullanıyordu. `5bbed46693fe74c99345540610082d2ced8b0bf2` ile Balance Number whitespace/hyphen ile ayrılmış her isim bileşeninin normalized initial değerlerinin toplamından hesaplanıp canonical reduction policy ile indirgenecek şekilde düzeltildi.
- `8cb240f9ffb978a8f99d6e4f7a06e1e3b1674e94` RC-0166→0184 regressionını requirement başına explicit test case ve exact fixture'larla güçlendirdi. RC-0172 için `Ada Lovelace => A(1)+L(3)=4` ve `İpek Şen => I(9)+S(1)=10=>1`; RC-0173 exact missing set `{3,4,6,8}`; RC-0175 hidden passion `{5}`; RC-0176/0177/0178 exact Personal Year/Month/Day `9/9/7`; RC-0179 Pinnacles `[8,2,1,8]`; RC-0180 Challenges `[6,0,6,6]`; RC-0184 Pythagorean F=6 / Chaldean F=8 ayrımı kilitlendi.
- Eski RC-0166→0184 validator yakındaki başka bir RC marker'ını eksik requirement'ın kanıtı olarak kabul edebiliyordu. `2e62b1029f1fcad9f1df80e8dbb615e868c9fbc2` ile bu gevşeklik kaldırıldı; RC-0166→RC-0184'ün her biri test dosyasında exact marker ile bulunmak zorunda ve kritik exact fixture'lar validator tarafından ayrıca aranıyor.
- Requirement matrix bu checkpointte bilinçli olarak yükseltilmedi. Yeni calculation/test/validator HEAD'i için physical SUCCESS görülmeden RC-0166→0184 TESTED/VERIFIED/DONE yapılamaz. RC-0185 zaten TESTED+blocked olup independent Lo Shu golden/rendered UI/global release blocker'larını korur.
- Sıradaki dependency işi: latest exact HEAD Actions fan-outunu oku. `Numerology Core Contract` ve `RC-0166 through RC-0184 Numerology Core` SUCCESS verirse RC-0166→0184 evidence/matrix satırlarını yalnız TESTED+blocked seviyesine taşı; failure varsa aynı çalıştırmada kök nedeni düzelt. Ardından sonraki NOT_STARTED requirement grubuna geç.

## Açık release blocker'ları

- Exact-release 10-capability airplane APK E2E.
- Android Keystore-backed encrypted primary DB + plaintext→encrypted migration + release-binary persistence proof.
- Daily Message final real-device/UI proof.
- Accessibility/performance release gates.
- AKİLES provenance / remaining independent calculation golden-reference evidence.
- RC-1439 gerçek project-owner physical references.

RC-0001→RC-1442 tamamı DONE, bütün zorunlu release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**