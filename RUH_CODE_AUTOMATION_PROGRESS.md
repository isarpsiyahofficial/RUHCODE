# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** SOURCE_LEVEL_IMPLEMENTED / IMPLEMENTED, DONE değildir. DONE yalnız gerekli test, golden, cihaz ve release kanıtlarıyla verilir.

## Requirement durumu

- Exact kapsam: `RC-0001 → RC-1442` / **1.442 requirement**.
- `requirements/requirement_state.csv` sparse explicit-override ledger'dır; bu checkpointte değiştirilmedi.
- Kanıtsız DONE/status override eklenmedi.

## Doğrulanmış ana ilerleme

- Calculation, timezone/date, astronomy provider, Western, numerology, BaZi ve Çin astrolojisi çekirdeklerinde source/test altyapısı mevcut.
- Free/PRO guard ve offline entitlement state mevcut.
- 15 tablolu backup/restore, transaction/rollback ve platform file-store katmanları mevcut.
- Professional/combined PDF planning, preview/build parity ve structural validation mevcut.
- UI action/accessibility contracts mevcut; catastrophic restore rollback persistent accessible integrity alarmıdır.
- Daily Message runtime packaged loader ve production Today wiring mevcut.
- TR/EN localization delegates production app'te explicit bağlı.

## Günün Mesajı doğrulanmış kanıtı

- `2026-01-01 → 2036-12-31`.
- TR **4018/4018**, EN **4018/4018**, toplam **8036/8036**.
- missing exact date/locale: **0**.
- Earlier exact APK packaging proof (`5283cc2381fbf850f86c85cb458f96a6b8250f45`): yaklaşık 53.2 MB release APK, packaged TR 4018, EN 4018, missing 0, duplicate 0.
- APK SHA-256: `2720059bf969681f67e119cd7cf1185e41914224613f74dffcd75fc328d63948`.
- RC-1433 rolling-horizon release gate kaynak seviyesinde mevcut; final release tarihine göre strict pass gerekir.

## Flutter / CI durumu

Historical decoded baselines:
- `f18493949d0229a41e47d2dc05338e2167f599ac`: Analyze SUCCESS, Test `+559 -28`.
- `bf9b954f454f8c8685469010e4519c22073b7773`: Analyze SUCCESS, Test `+573 -17`.
- `b726b3196d9dfa0a15c740bc79a8c41f32379aff`: Analyze SUCCESS, Test `+582 -11`.
- `5283cc2381fbf850f86c85cb458f96a6b8250f45`: Analyze SUCCESS, Test `+590 -3`.
- `30b29b5b552b497a573acb7b370e3ab4c7bca78f`: Analyze SUCCESS, Test `+592 -1`.
- `4d3462a8dc35731473b89370840b78e840962d92`: Analyze SUCCESS, Test `+592 -1`.
- `3b8d60c37cccba856ceb641630adc62fef865f7b`: **24 workflow completed SUCCESS** tracked-host baseline.
- `889bb06a2b0a52d7ec04ea0c04a1809ddda4566a`: **25 workflow indexed**, dedicated `RC-1437 Runtime Assets` SUCCESS; no failure/in-progress conclusion bulunduğu baseline.

RC-1437 runtime progression:
- `0302a2deb236be2450f7a63a146f328b77b351d8`: IERS packaged runtime loader.
- `bc3c735ae7c64152fc742410d52cae5293422721`: real packaged IERS runtime test.
- `1c5a9abf86f6a676721e8104d7c9899fb80ba083`: fatal analyzer import root-cause fix.
- `970094301fcb50d61e98f4d2f730bdf7efa58776`: City Catalog validator physical bundled evidence ile hizalandı.
- `82cb7c9ca9e2e7764c66912cfed511a39701c50d`: DE440s packaged runtime integrity loader.
- `7727857bac78d22dab96585782e72638794a2adf`: real packaged DE440s asset test.
- `2a35c8fb866289aa7818a998f10384eae6b87a53`: RC-1437 physical runtime asset validator.
- `d718bed68661ca42c8a5227764196f7d885df556`: dedicated RC-1437 Runtime Assets CI gate.
- `7f2f1e77662aa93784b18fcab99c79f5cdf8351d`: runtime validator exact-file veya containing-directory Flutter asset declaration kabul edecek şekilde düzeltildi.
- `4be777af7b32658f2cec74ab3f5823034e3b1c77`: DE440s DAF/SPK structural segment-index parser.
- `90fde158acce69ab15ed602cebacf55fb24ca5d6`: real packaged DE440s DAF index test.
- `40da4cad02cb1e4c5fe2c16f6cc94de3e6a07045`: parser test import repair.
- `dda4106a1ff861e19491bb522baefced1e4d9dd8`: gerçek SPK Type-2 numerical evaluator.
- `91d54d07f437757106954bb5eb12decd868b908b`: deterministic synthetic Type-2 Chebyshev position/velocity, endpoint ve fail-closed testleri.
- `89de69cf6aca929c1bca8a497ecde8d3052d0361`: real packaged DE440s üzerinde J2000 Type-2 numerical runtime evaluation testi.
- `d6dfcb3f31b7b7a965f5f544d3a3162e429a81a6`: dedicated RC-1437 Runtime Assets workflow physical validator + synthetic evaluator + real packaged DE440s numerical test çalıştırıyor.
- `d9ac37b0a043d82f781fbd1596a3ae326a480f35`: City Catalog validator directory-asset declaration semantiğiyle düzeltildi; physical SHA/size/record-count/unique-ID/timezone/attribution kontrolleri korunuyor.
- `25cceeec27d2386421b48badd4d45b88e165b781` + `15e6c583a3dae6a2ceaacb1c47b46fe1fece9e48`: fail-closed SPK body/center graph evaluator; SSB root, exact ET coverage, J2000 frame/type requirements, missing-center/cycle rejection.
- `faa24c92bd4b0c097d11e28f90d08a688f4984e7`: deterministic body graph contract tests; target/observer subtraction, reverse relation, missing-center/cycle/frame/type hata yolları.
- `f1bb924d8bd37c793a50c319aed22e082adc955a`: real packaged DE440s Earth(399)→EMB(3)→SSB(0) J2000 runtime graph test ve chaining identity.
- `dd2394de5097a008d49118de8445fc17fe4ae7f7`: dedicated RC-1437 Runtime Assets workflow body graph contract + real packaged graph testlerini de çalıştırıyor.

Current body-graph engineering CI bu checkpoint yazılırken exact latest docs HEAD için henüz tamamlanmış/green kabul edilmedi. Requirement DONE verilmedi.

## RC-1437 — offline/versioned calculation data

- Timezone manifesti offline IANA runtime sözleşmesine sahip.
- GeoNames city catalog physically bundled / `BUNDLED_VERIFIED`: 235,640 records, source/generated SHA evidence, attribution and Flutter asset binding.
- IERS `finals2000A.all` physically bundled with exact SHA/byte evidence; Flutter runtime loader parses published UT1-UTC rows and fails closed outside usable coverage.
- JPL/NASA NAIF DE440s SPK physically bundled with exact SHA/byte evidence and runtime integrity loader checking byte size, `DAF/SPK` header and SHA.
- DE440s structurally indexed as a real DAF/SPK: file record, binary endianness, ND/NI, linked summary records, target/center/frame/type/address descriptors and name records are parsed fail-closed.
- SPK Type 2 numerical evaluation exists: trailer directory (`INIT`, `INTLEN`, `RSIZE`, `N`), exact record selection, MID/RADIUS normalization, Chebyshev X/Y/Z evaluation and differentiated vx/vy/vz km/s are implemented fail-closed.
- Body/center graph chaining now exists: target and observer paths resolve independently to SSB and are differenced; missing center, cycles, unsupported frame and unsupported type fail closed.
- Deterministic synthetic contract tests verify numerical Chebyshev math, graph arithmetic and explicit failure paths.
- Real packaged DE440s runtime tests execute both a real Type-2 segment and Earth→EMB→SSB graph at J2000 and require finite non-default states.
- This runtime evidence **still does not prove astronomical accuracy**. Independent official JPL/NAIF golden vectors tied to RC-1436 tolerances remain open.
- Product date range 1890→2110 is wider than published IERS EOP coverage. Future/unpublished EOP must not be fabricated; range handling/versioned model evidence remains a release requirement.

**RC-1437 DONE değil.**

## RC-1439 — physical UI reference images

- Reference manifest explicit `NOT_PROVEN`.
- Validator fiziksel dosya, unique screen ID/path, filename ve exact SHA-256 doğruluyor.
- Generated placeholder reference evidence reddediliyor.

**RC-1439 DONE değil.**

## RC-1442 — clean-checkout release source readiness

- Tracked Android host ve canonical identity `com.ruhcode.ruh_code` mevcut.
- Gradle 9.1.0 / AGP 9.0.1 / Kotlin 2.3.20 host sözleşmesi mevcut.
- Production release debug keystore ile imzalanmıyor; signing yalnız `RUH_RELEASE_STORE_FILE`, `RUH_RELEASE_STORE_PASSWORD`, `RUH_RELEASE_KEY_ALIAS`, `RUH_RELEASE_KEY_PASSWORD` değerleriyle etkinleşiyor.
- Physical verified Gradle 9.1.0 wrapper JAR tracked; wrapper checksum ve JSON provenance da tracked.
- Wrapper SHA-256: `76805e32c009c0cf0dd5d206bddc9fb22ea42e84db904b764f3047de095493f3`.
- Gradle 9.1.0 distribution SHA-256: `a17ddd85a26b6a7f5ddb71ff8b05fc5104c0202c6e64782429790c933686c806`.
- Signed clean-checkout workflow fail-closed: strict RC-1442 readiness → real secrets → ephemeral keystore → locked dependency resolution → release APK → apksigner → Daily Message APK validation → SHA/provenance artifact.

Açık kalan RC-1442 blocker:
- strict RC-1437 ve strict RC-1439 henüz tam PASS değil,
- production signing secrets ile signed workflow successful execution kanıtı yok,
- exact signed reproducible clean-checkout APK verification yok,
- real-device verification eksik.

**RC-1442 DONE değil.**

## Açık ana blocker'lar

- RC-1437 independent official JPL/NAIF golden accuracy + RC-1436 tolerance + date-range/EOP policy evidence,
- RC-1439 canonical physical reference screenshots/images + screen IDs + SHA-256 seti,
- secret-backed signed reproducible clean-checkout APK actual execution,
- Daily Message real airplane-mode device lookup proof,
- production Unicode PDF font + license/hash + parser/render/device delivery proof,
- Play/rewarded real-device evidence,
- visual/accessibility real-device regression,
- final exact 1.442-RC lifecycle audit.

## Son checkpoint

`automation_runs/2026-09-03_0854_rc1437_body_graph_progress.md`

## Sıradaki çalışma

1. Exact current HEAD full CI completion'ı oku; body-graph/runtime/analyzer kırmızısı varsa aynı turda düzelt.
2. Official JPL Horizons/NAIF geometric J2000 KM-S golden vectors'i exact source/query provenance ile materialize et.
3. Packaged DE440s graph outputunu RC-1436 explicit toleranslarına karşı bağımsız golden'larla doğrula; bu geçmeden `planetaryEphemeris.proven` veya RC-1437 DONE yapma.
4. 1890→2110 EOP/versioned range politikasını fabrication olmadan kanıtla.
5. Strict RC-1439 ve diğer bağımsız release blockerlarını ilerlet.
6. Strict prerequisites PASS olduktan sonra signed clean-checkout workflow'u production secrets ile çalıştır ve exact artifact evidence'i bağla.
7. Real-device proof + final 1.442 RC lifecycle audit tamamlanmadan FINAL deme.

**FINAL: NO.**
