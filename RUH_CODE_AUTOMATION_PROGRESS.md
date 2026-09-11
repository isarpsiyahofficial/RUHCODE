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
- RC-1105→1130 dependency/offline governance mevcut; `pubspec.lock` fiziksel.
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
- DE440s geocentric longitude — run `34544790040` fiziksel SUCCESS; Sun `0.01°`, Moon `0.02°`, gezegenler `0.02°`. LSK/DELTET provenance fix zinciri `685b2bff...`, `68bd838e...`, `b2fbf088...` ile korunur.

### True lunar node — current work

Eski `LunarNodeCalculator.trueAscendingNodeDegrees` yalnız leading periodic terms kullanıyordu ve independent Swiss TRUE_NODE ile bazı epochlarda canonical `0.02°` bütçeyi aşıyordu. Tolerans büyütülmedi.

Bu çalıştırmada:

- `5686d7820311426a0a6f615fd2a08f03633f3d6a`: production/high-accuracy `trueAscendingNodeFromEphemerisDegrees` eklendi. Moon'un fiziksel ephemeris konumları mean ecliptic/equinox-of-date frame'ine taşınıp central-difference velocity ile `h = r × v` osculating orbital plane çıkarılır; ascending node `atan2(h.x, -h.y)` ile hesaplanır. Legacy analytical API compatibility için korunur fakat RC-1436 high-accuracy path değildir.
- `d7a2e85b5cdc5dad74810f4516edefa532e0d9a2`: pinned Swiss TRUE_NODE independent materializer.
- `4be463482bbab72c1250039e66b5f3205963e73c`: 1900/2000/2026/2050/2100 physical oracle evidence.
- `7b8b4e00f6e55dc3b85cd0718ee3ace9e0379025` + `c6a7597ad70c998d343a84a883f30b2b9df25ffd`: packaged DE440s production regression; canonical `nodeLongitudeMaxAbsErrorDegrees=0.02` budgetunu manifestten okur.
- `f6bbf354817575261379e76aa8c98cf0a69ffb2f`: dedicated `RC1436 True Lunar Node Independent Oracle` workflow.
- Exact `f6bbf354...` üzerinde dedicated run `34553042823` fiziksel olarak oluşturuldu; checkpoint anında `queued`. SUCCESS gelmeden true-node VERIFIED değildir.

## Flutter Quality

Önceki missing-evidence failures için mean-node evidence fiziksel eklendi ve DE440s longitude dedicated gate artık SUCCESS verdi. Yeni exact `f6bbf354...` Flutter Quality run `34553041562` checkpoint anında queued; fiziksel sonuç gelmeden global quality green kabul edilmez.

## Açık blocker'lar

- True-node dedicated gate fiziksel SUCCESS bekliyor; astronomy manifest bundan ve diğer applicable accuracy sınıflarından önce `proven=true` olamaz.
- Daily-message strict editorial release audit kapanmadan RC-1425/1426/1433/1434 release-DONE değildir.
- `requirements/reference_manifests/rc1439_reference_images.json` halen physical reference evidence gerektirir.
- Exact AKİLES provenance/independent authoritative values açık.
- Encrypted persistence/key management/migrations, full airplane-mode production instrumentation/device evidence, rendered TR/EN UI/PDF, accessibility/performance, real entitlement/ad/rewarded verifier ve remaining Vedic/Panchanga/Dasha/Varga/Gochara/BaZi proof zincirleri açık.
- RC-1442 exact clean-checkout artifact + tested commit SHA + artifact SHA eşleşmesi bütün 1.442 RC DONE/unblocked olmadan kapanamaz.
- Legacy `cancelled` calculation/Vedic workflow'ları SUCCESS sayılmaz.

## Sonraki devam noktası

1. Exact HEAD'de `RC1436 True Lunar Node Independent Oracle` run `34553042823` sonucunu fiziksel doğrula. Kırmızıysa `0.02°` bütçeyi değiştirmeden root-cause düzelt; yeşilse true-node alt-kanıtını VERIFIED kabul et.
2. Exact HEAD Flutter Quality run sonucunu doğrula ve kalan test failure varsa aynı çalıştırmada kök nedenini gider.
3. Astronomy accuracy manifestte henüz independent proof taşımayan applicable sınıfları tek tek kapat; hiçbirini birleştirip kaybetme.
4. RC-1362→1374 airplane-mode gate'ini gerçek production capability/device instrumentation'a genişlet.
5. Daily-message strict audit, RC-1439 physical references, encrypted persistence/accessibility/performance ve packaged dataset/license zincirlerini bağımsız ilerlet.
6. Yalnız requirement-specific evidence + exact-head SUCCESS varsa matrix state yükselt; global blocker varken DONE verme.
7. RC-0001→RC-1442 tamamı DONE, bütün release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**
