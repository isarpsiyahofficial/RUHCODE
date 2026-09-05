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
- **RC-0071 = TESTED + blocked=YES** (`cbd4b158e363199c7ca3f36ae44b08aa8fbcbb7c`).
- **RC-0072 = TESTED + blocked=YES**; physical bot promotion `5fcb1d816a72ad2a3b2d90218a6efb8f66afbc16`.
- **RC-0073→0075 = IMPLEMENTED + blocked=YES**; deterministic return core + compiled tests + exact contract + fail-closed validator + dedicated CI/matrix gate main üzerinde. Physical TESTED promotion henüz görülmedi.

## Bu turdaki gerçek geliştirme

### RC-0072 — physical TESTED doğrulandı

`requirements/requirement_state.csv` RC-0072 satırı artık fiziksel olarak TESTED. Promotion commit: `5fcb1d816a72ad2a3b2d90218a6efb8f66afbc16`.

### RC-0073 → RC-0075 — Solar/Lunar/Planetary Return

Bağlayıcı şartname:

- RC-0073 — `Solar Return hesaplanacak.`
- RC-0074 — `Lunar Return hesaplanacak.`
- RC-0075 — `Planetary Return sistemleri desteklenebilecek.`

Commit zinciri:

- `4f398f0224b1af4a079907fcebcb5c8421d365ee` — production explicit-TT planetary longitude-return solver.
- `ad0fee3b6ab4d329c84befdaf48e22981cf7d1b9` — compiled Solar/Lunar/non-luminary regressions ve fail-closed testleri.
- `abadbfcb0e4836b6e6d10dbc843faed47260015b` — exact binding contract.
- `3a1c3bfb0751ac8e6a84e8b945c6c556bed1494c` — fail-closed validator.
- `ea61b5e81470061f6eb79646a12309769e6fa545` — dedicated Flutter CI + matrix promotion gate.

Solver yalnız caller-supplied explicit TT window ve versioned `EphemerisProvider` kullanır. Coverage, body/instant/source/version provenance doğrulanır. Signed angular difference içindeki ±180° branch cut sahte return kökü olarak kabul edilmez. Supplied aralıkta return bulunmazsa fail-closed; device current time/network fallback yok. Solar ve Lunar Return aynı fiziksel root solver'ı explicit Sun/Moon seçimiyle kullanır; Planetary Return explicit body kabul eder.

Physical SUCCESS + bot matrix promotion görülmeden RC-0073→0075 TESTED sayılmayacak. Rendered return UI, verified house/angle integration, independent astronomy golden/tolerance review ve release/device kanıtları VERIFIED/DONE öncesinde açık.

## Açık product-facing Western maddeleri

RC-0042 minor-aspect settings; RC-0044 user-editable orb settings/persistence/entitlement/UI; RC-0046 element yoğunluk UI; RC-0048 retrograde UI; RC-0049 rulership UI; RC-0061 active house-system UI; RC-0068 transit timeline UI; RC-0069/0070 synastry UI; RC-0071 composite UI/verified house-angle policy; RC-0072 Davison UI/verified midpoint-location house-angle pipeline; RC-0073/0074/0075 return-chart UI/house-angle integration.

## Açık global blocker / release kapıları

Independent editorial evidence; exact AKİLES provenance/comparison; RC-1436/1437 broader official astronomy golden/tolerance coverage; RC-1439 physical UI reference evidence; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates.

## Sonraki devam noktası

1. RC-0073→0075 exact workflow sonucu + physical matrix promotion okunacak; kırmızıysa exact job/log kök nedeni aynı turda düzeltilecek.
2. RC-0062 natal-chart unresolved physical promotion tekrar incelenecek.
3. Dependency sırasıyla **RC-0076 Secondary Progressions → RC-0077 Solar Arc → RC-0078 Annual Profections** uygulanacak; şartname/entitlement bağımlılıkları korunacak ve approximate astronomy shortcut kullanılmayacak.
4. Product-screen/widget evidence ve RC-0042/0044/0046/0048/0049 bağımsız oldukça paralel ilerletilecek.
5. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Checkpoint: `automation_runs/2026-09-06_0055_rc0072_rc0075_progress.md`.

**FINAL: NO.**
