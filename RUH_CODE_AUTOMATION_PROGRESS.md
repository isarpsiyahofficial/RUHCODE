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
- **RC-0062 = NOT_STARTED**; natal-chart dedicated contract/test/CI mevcut fakat physical promotion unresolved ve atlanmış sayılmıyor.
- **RC-0063→0067 = TESTED + blocked=YES** (`fcf83a4361757fb110dbc688be02cd7342273b66`).
- **RC-0068 = TESTED + blocked=YES** (`b1a6a9aeaf0eba788a9b4dc8061d3796bcb2e97d`).
- **RC-0069→0070 = TESTED + blocked=YES** (`c02f9c5ee4860a222aa01f98e0cc7080b83e92c2`).
- **RC-0071 = TESTED + blocked=YES** (`cbd4b158e363199c7ca3f36ae44b08aa8fbcbb7c`).
- **RC-0072 = TESTED + blocked=YES** (`5fcb1d816a72ad2a3b2d90218a6efb8f66afbc16`).
- **RC-0073→0075 = TESTED + blocked=YES**; physical promotion `59ac91550ecd1e4ebf14367c9c4a2c549f6b96b8`.
- **RC-0076→0078 = IMPLEMENTED + blocked=YES**; production + compiled tests + binding contract + validator + dedicated CI/matrix gate main üzerinde. Dedicated run `33999963235` son kontrolde `pending`; physical SUCCESS/promotion olmadan TESTED denmeyecek.
- **RC-0079 = IMPLEMENTED + blocked=YES**; provenance-safe neutral eclipse overlay core + compiled tests + exact contract + validator + dedicated CI/matrix gate main üzerinde. Physical SUCCESS/promotion henüz kanıtlanmadı.

## Bu turdaki gerçek geliştirme

### RC-0073 → RC-0075 — physical TESTED doğrulandı

`requirements/requirement_state.csv` Solar Return, Lunar Return ve Planetary Return satırları dedicated machine gate sonrası fiziksel olarak TESTED'e yükseldi. Promotion commit: `59ac91550ecd1e4ebf14367c9c4a2c549f6b96b8`.

Rendered return-chart UI, verified house/angle integration, independent astronomy golden/tolerance ve release/device kapıları VERIFIED/DONE öncesinde açık.

### RC-0076 → RC-0078 — predictive techniques

Bağlayıcı şartname:

- RC-0076 — `Secondary Progressions hesaplanacak.`
- RC-0077 — `Solar Arc desteklenilecek.`
- RC-0078 — `Annual Profections desteklenilecek.`

Commit zinciri:

- `db214a0334cc45650b7c00b5dcb71cfa26ae7b92` — production `predictive_techniques.dart`.
- `e14a27d8399471a9c83a1517dbcf665a83cc38e0` — compiled regressions.
- `e8bee0b4660d596650b693aacaf95e1a7ba52f80` — exact binding contract.
- `49db080acc7867e28e7df130ca8b4d5748556bb0` — fail-closed validator.
- `fdaf8cc21d08cbdf72ab0df1824c5d7829c20806` — dedicated Flutter CI + matrix promotion gate.

Secondary Progressions explicit caller age ile conventional day-for-year mapping uygular: `progressedJdTt = natalJdTt + ageYears`. Versioned ephemeris coverage ve returned body/TT/source/version doğrulanır; duplicate body veya coverage dışı request fail-closed.

Solar Arc sabit ortalama derece çarpanı kullanmaz. Natal Sun ile actual secondary-progressed Sun arasındaki normalized arc hesaplanır ve aynı arc bütün natal placement'lara uygulanır. Natal/ephemeris provenance uyuşmazlığı fail-closed.

Annual Profections age 0'da natal ASC sign / house 1 ile başlar; her integer yaşta bir house/sign ilerler ve modulo 12 döner. Invalid ASC/age fail-closed. Üç teknikte de device current time/network fallback yok.

Dedicated run `33999963235` son kontrolde `pending`, conclusion `null`; physical bot promotion görülmeden TESTED statüsü verilmeyecek. Product UI, method review/goldens, house-angle integration where applicable ve release/device gates VERIFIED/DONE öncesinde açık.

### RC-0079 — Eclipse overlay capability

Bağlayıcı madde: `Eclipse overlay ve tutulma etkileri ilerleyen profesyonel modüllerde kullanılabilecek.`

Commit zinciri:

- `6f19cecf82fd743de2d765927f59ec86266684e3` — production provenance-safe neutral eclipse overlay.
- `4f516d3fb3709d8144cbefc1c50660780e9eeb61` — compiled regressions.
- `63d5fde9cfeff846d78a22446c5a2106c0d2a900` — exact binding contract.
- `9d8c87dbde7b03b680a1a4cf3267d6ead008f8b7` — fail-closed validator.
- `4979cf4b0149d5462016abb9df20a98651ea5686` — dedicated Flutter CI + matrix promotion gate.

Bu katman tutulma tarihi, konumu veya spiritüel/astrolojik etki yorumu uydurmaz. Caller-supplied provenance-tagged verified eclipse event'i, aynı source/dataVersion provenance'a sahip natal placement setiyle explicit orb altında eşler ve conjunction/opposition contact verisi üretir. Invalid longitude/orb veya provenance mismatch fail-closed; orb dışında contact fabricate edilmez. Böylece ilerideki profesyonel tutulma modülleri için hesaplama/veri altyapısı vardır fakat bağımsız verified eclipse-event catalog/goldens ve product interpretation/UI henüz kanıtlanmış değildir.

Physical CI + bot matrix promotion görülmeden RC-0079 TESTED sayılmayacak.

## Açık product-facing Western maddeleri

RC-0042 minor-aspect settings; RC-0044 user-editable orb settings/persistence/entitlement/UI; RC-0046 element yoğunluk UI; RC-0048 retrograde UI; RC-0049 rulership UI; RC-0061 active house-system UI; RC-0068 transit timeline UI; RC-0069/0070 synastry UI; RC-0071 composite UI/verified house-angle policy; RC-0072 Davison UI/verified midpoint-location house-angle pipeline; RC-0073/0074/0075 return-chart UI/house-angle integration; RC-0076/0077/0078 predictive-technique UI; RC-0079 professional eclipse overlay UI/interpretation/entitlement.

## Açık global blocker / release kapıları

Independent editorial evidence; exact AKİLES provenance/comparison; RC-1436/1437 broader official astronomy golden/tolerance coverage; RC-1439 physical UI reference evidence; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates.

## Sonraki devam noktası

1. RC-0076→0078 dedicated run `33999963235` ve physical matrix promotion okunacak; kırmızıysa exact job/log kök nedeni aynı turda düzeltilecek.
2. RC-0079 dedicated CI + physical promotion sonucu okunacak; kırmızıysa exact root cause düzeltilecek.
3. **RC-0062** natal-chart unresolved physical promotion tekrar incelenecek; hiçbir requirement kaybedilmeyecek veya atlanmış sayılmayacak.
4. Dependency sırasıyla **RC-0080 Batı'nın basit sidereal kopyası olmayan Vedik yapı → RC-0081 ayrı Vedik hesaplama motoru** ilerletilecek. Western motor üzerine yalnız offset ekleyip requirement zayıflatılmayacak.
5. Product-screen/widget evidence ve RC-0042/0044/0046/0048/0049 bağımsız oldukça paralel ilerletilecek.
6. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Checkpoint: `automation_runs/2026-09-06_0253_rc0073_rc0079_progress.md`.

**FINAL: NO.**
