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
- **RC-0073→0075 = TESTED + blocked=YES** (`59ac91550ecd1e4ebf14367c9c4a2c549f6b96b8`).
- **RC-0076→0078 = TESTED + blocked=YES** (`a85f00ab8edc2a167cad1d99b657c2e97569ce71`).
- **RC-0079 = TESTED + blocked=YES** (`3889aec847461ed6c24dab0190ddf0582dfe2207`).
- **RC-0080→0081 = IMPLEMENTED + blocked=YES**; independent Vedic engine production/test/contract/validator/dedicated CI gate main üzerinde. Physical bot TESTED promotion henüz görülmedi.

## Bu turdaki gerçek geliştirme

### RC-0076 → RC-0079 — physical TESTED doğrulandı

Predictive-technique gate RC-0076 Secondary Progressions, RC-0077 Solar Arc ve RC-0078 Annual Profections satırlarını `a85f00ab8edc2a167cad1d99b657c2e97569ce71` ile TESTED'e yükseltti. Eclipse overlay RC-0079 da `3889aec847461ed6c24dab0190ddf0582dfe2207` ile TESTED'e yükseldi. Product UI, independent method/astronomy goldens ve release/device kapıları açık olduğundan VERIFIED/DONE verilmedi.

### RC-0080 → RC-0081 — independent Vedic engine boundary

Bağlayıcı maddeler:

- RC-0080 — `Vedik astroloji Batı astrolojisinin üzerine sidereal fark uygulanmış basit bir kopya olmayacak.`
- RC-0081 — `Vedik hesaplama motoru ayrı çalışacak.`

Commit zinciri:

- `7f035500af209a5bf3aa462ec13d823a81d60089` — production `lib/src/calculation_core/vedic/vedic_engine.dart`.
- `f5e9a7eaf96f1b9e67e02b2ba9385ea03f693298` — compiled regressions.
- `fdc20bfdc56323eb94ccd82b5bb59bd7f3e52034` — exact binding contract.
- `2bf853e1bd2a1d1414730d016182a5e04c0a4b61` — fail-closed validator.
- `05f2c45d3c387a9919e9cf0f026db1e3cd109318` — dedicated Flutter CI + matrix promotion gate.

Vedic runtime shared astronomical `EphemerisProvider`'ı doğrudan tüketir; `calculation_core/western` import etmez ve Western chart snapshot'ını post-process etmez. Kendi `VedicCalculationSnapshot` modelini ve versioned `VedicAyanamshaProvider` sınırını kullanır. Exact TT, ephemeris source/dataVersion ve ayanamsha id/dataVersion sonuçta korunur. Duplicate body, invalid ayanamsha provenance/value, coverage dışı instant ve returned body/TT/source/version mismatch fail-closed. Device current time/network fallback yoktur.

RC-0082'nin Lahiri/Chitrapaksha default'u bu maddelere gizlice gömülmedi; verified implementation ayrı requirement olarak açık tutuldu.

Physical `requirements(rc0080-rc0081): record independent Vedic engine TESTED` bot commit'i son kontrolde henüz yoktu; bu nedenle RC-0080/0081 TESTED ilan edilmedi.

## Açık product-facing / global blocker'lar

RC-0042 minor-aspect settings; RC-0044 user-editable orb settings/persistence/entitlement/UI; RC-0046 element yoğunluk UI; RC-0048 retrograde UI; RC-0049 rulership UI; RC-0061 active house-system UI; RC-0068 transit timeline UI; RC-0069/0070 synastry UI; RC-0071 composite UI/verified house-angle policy; RC-0072 Davison UI/verified midpoint-location house-angle pipeline; RC-0073→0079 ilgili rendered product UI/interpretation/entitlement kanıtları.

Independent editorial evidence; exact AKİLES provenance/comparison; RC-1436/1437 broader official astronomy golden/tolerance coverage; RC-1439 physical UI reference evidence; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. RC-0080/0081 dedicated CI ve physical matrix promotion okunacak; kırmızıysa exact job/log kök nedeni aynı turda düzeltilecek.
2. **RC-0062** natal-chart unresolved physical promotion tekrar incelenecek; atlanmayacak.
3. Dependency sırasıyla **RC-0082 Lahiri/Chitrapaksha → RC-0083 farklı ayanamsha seçenek mimarisi → RC-0084 Vedik Lagna** ilerletilecek.
4. Independent Vedic boundary korunacak; Western chart + offset shortcut kabul edilmeyecek.
5. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Checkpoint: `automation_runs/2026-09-06_0454_rc0076_rc0081_progress.md`.

**FINAL: NO.**
