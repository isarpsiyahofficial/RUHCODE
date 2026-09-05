# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- **RC-0002 = DONE**.
- **RC-0003 = NOT_STARTED**; **RC-0004 = TESTED + blocked=YES**; **RC-0005 = NOT_STARTED + blocked=YES**; **RC-0006 = TESTED + blocked=YES**; **RC-0007 = NOT_STARTED**. Independent editorial / exact AKİLES provenance blocker'ları açık.
- RC-0008→RC-0030 physical matrix gerçeğine göre korunur; global astronomy/location/UI/release blocker'ları açık kalır.
- Semantic reconciliation: **RC-0036→0041, RC-0043, RC-0045, RC-0047, RC-0050 = TESTED + blocked=YES**; **RC-0042/0044/0046/0048/0049 = NOT_STARTED**.
- **RC-0031→0035 = TESTED + blocked=YES** (`a164a622a8d5db68dada9799b6270aba2cbce300`).
- **RC-0052→0053 = TESTED + blocked=YES** (`c49e07ca6970e626e03abd15861ad6b569f936ab`).
- **RC-0054→0056 = TESTED + blocked=YES** (`a5deba73bff246c64d93e7d089194c2dc0bdd2ba`).
- **RC-0057→0060 = TESTED + blocked=YES** (`b2c6a512dfc0cb5c95c8fa1ff09203c02b8e1aca`).
- **RC-0061 = IMPLEMENTED + blocked=YES**; active house-system name için gerçek product-screen/widget-device evidence açık.
- **RC-0062 = NOT_STARTED**; natal-chart dedicated contract/test/CI mevcut fakat physical promotion unresolved.
- **RC-0063→0067 = TESTED + blocked=YES** (`fcf83a4361757fb110dbc688be02cd7342273b66`).
- **RC-0068 = TESTED + blocked=YES** (`b1a6a9aeaf0eba788a9b4dc8061d3796bcb2e97d`).
- **RC-0069→0070 = TESTED + blocked=YES** (`c02f9c5ee4860a222aa01f98e0cc7080b83e92c2`).
- **RC-0071 = TESTED + blocked=YES**; physical bot promotion: `cbd4b158e363199c7ca3f36ae44b08aa8fbcbb7c`.
- **RC-0072 = IMPLEMENTED + blocked=YES**; Davison deterministic astronomical core + compiled tests + exact contract + fail-closed validator + dedicated CI/matrix gate main üzerinde. Physical TESTED promotion henüz görülmedi.

## Bu turdaki gerçek geliştirme

### RC-0071 — physical TESTED doğrulandı

`requirements/requirement_state.csv` RC-0071 satırı artık fiziksel olarak TESTED. Promotion commit: `cbd4b158e363199c7ca3f36ae44b08aa8fbcbb7c`.

### RC-0072 — Davison chart

- `fbb9284f42cba66a2d1ad9dfdef3389250d674a6` — production `davison_chart.dart`.
- `ab19336ea17d248a92a5f833bf868df9f7682c75` — compiled regressions.
- `971750b17e67baa98a855621f2d187f7ce0084c1` — exact RC-0072 binding contract.
- `ec0402aeebf836293a236da0c29333c32be9fe02` — fail-closed validator.
- `bfee3f8cc78117354dd7e10bf20eaff5f8a51921` — dedicated Flutter CI + matrix promotion gate.

Davison implementation iki explicit TT doğum anının gerçek orta zamanını alır, iki koordinatın dateline-safe spherical midpoint'ini hesaplar ve istenen her gezegeni supplied versioned `EphemerisProvider` üzerinden bu midpoint TT anında yeniden hesaplar. Natal planetary longitude'lar ortalanmaz. Invalid coordinate, duplicate body, coverage dışı midpoint, ephemeris instant/provenance mismatch ve antipodal location fail-closed. Verified UT/sidereal-time house pipeline olmadan houses/angles uydurulmaz.

## Açık product-facing Western maddeleri

RC-0042 minor-aspect settings; RC-0044 user-editable orb settings/persistence/entitlement/UI; RC-0046 element yoğunluk UI; RC-0048 retrograde UI; RC-0049 rulership UI; RC-0061 active house-system UI; RC-0068 transit timeline UI; RC-0069/0070 synastry UI; RC-0071 composite UI/verified house-angle policy; RC-0072 Davison UI/verified midpoint-location house-angle pipeline.

## Açık global blocker / release kapıları

Independent editorial evidence; exact AKİLES provenance/comparison; RC-1436/1437 broader official astronomy golden/tolerance coverage; RC-1439 physical UI reference evidence; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates.

## Sonraki devam noktası

1. RC-0072 exact workflow sonucu + physical matrix promotion okunacak; kırmızıysa exact job/log kök nedeni aynı turda düzeltilecek.
2. RC-0062 natal-chart unresolved physical promotion tekrar incelenecek.
3. Dependency sırasıyla **RC-0073 Solar Return → RC-0074 Lunar Return → RC-0075 Planetary Return** uygulanacak; approximate astronomy shortcut kullanılmayacak.
4. RC-0061/0068/0069/0070/0071/0072 product-screen/widget evidence ve RC-0042/0044/0046/0048/0049 bağımsız oldukça paralel ilerletilecek.
5. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Checkpoint: `automation_runs/2026-09-05_2254_rc0071_rc0072_progress.md`.

**FINAL: NO.**
