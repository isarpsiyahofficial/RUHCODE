# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** SOURCE_LEVEL_IMPLEMENTED / IMPLEMENTED, DONE değildir. DONE yalnız gerekli test, golden, cihaz ve release kanıtlarıyla verilir.

## Requirement durumu

- Exact kapsam: `RC-0001 → RC-1442`.
- Repository-wide evidence integrity, semantic ownership ve matrix provenance kapıları aktif.
- Calculation, UI, backup, PDF, entitlement ve content kanıtları eksik final doğrulamalarını atlayarak DONE üretemez.
- `requirements/requirement_state.csv` sparse explicit-override ledger'dır; full 1.442 satırlık matrix CI'da üretilir. Kanıtsız DONE/status override eklenmedi.

## Source-level ilerlemiş ana bloklar

- Gregorian calendar, leap-year, exact-date identity, timezone/UTC-TT-UT1 sınırları.
- Astronomi provider sözleşmeleri, solar events, Gezegen Saatleri, DailySnapshot faktörleri.
- Western temel motorları ve persisted natal snapshot/manifest.
- Numeroloji, BaZi primitives ve basic Çin Astrolojisi çekirdekleri.
- Entitlement Free/PRO guard ve offline state.
- 15 tablolu backup/restore, `.ruhcode.zip`, transaction/rollback ve native save/pick/share.
- Professional/combined PDF planning, persisted Western/Numerology projection, preview/build parity ve structural validation.
- UI action/accessibility kontratları.
- Daily-message deterministic shard + editorial ledger + strict release QA hattı.
- Daily-message legacy source adapter: geçmiş shardlar canonical 6-sütun in-memory şemaya normalize edilir; yeni editorial batchler canonical yazılır.
- Daily-message packaged runtime loader: TR/EN shard dizinleri Flutter asset olarak paketlenir, `AssetManifest` üzerinden offline yüklenir ve `RuhCodeRuntime` bootstrap sırasında fail-closed parse edilir.
- Daily-message packaged loader repository'deki iki explicit şemayı destekler: canonical `date,locale,title,teaser,full_text,theme_tag` ve legacy `date,title,teaser,message,theme`; legacy locale yalnız asset path'ten türetilir, unknown schema fail-closed kalır.
- Daily-message Today UI: exact device-local civil date + locale lookup, fail-closed missing-date state, deterministic widget tests ve production runtime→app→navigation wiring.
- Production Today navigation assertion: injected exact local-date EN record is rendered through `MainNavigationShell` and missing-state is absent.
- Production `RuhCodeApp`: TR/EN için Material/Widgets/Cupertino localization delegates explicit bağlı.
- Daily-message APK packaging evidence gate: clean checkout'ta Android host yoksa Flutter 3.44.7 ile deterministic host materialize eder, release APK üretir, APK ZIP içindeki gerçek packaged assetleri exact date+locale seviyesinde denetler ve APK SHA-256 evidence üretir.
- Professional PDF preview/create/share Semantics wrappers child semantics'i dışlayarak tek canonical screen-reader action node üretir.
- Numerology metric rows visible label/value içeriğini korurken tek explicit screen-reader semantics container (`Yaşam Yolu: 7` / localized equivalent) üretir.
- PDF structural inspector classic-xref trailer içindeki nested dictionary sonrası `/Root` indirect reference'ını `startxref` sınırına kadar arar; `/Root → Catalog → Pages` zinciri korunur ve missing Root fail-closed kalır.
- PDF 1.5 xref-stream inspection dictionary key serialization order'ına bağlı değildir: bounded xref object içinde indirect object, `/Type /XRef` ve strict `/Root n g R` ayrı ayrı kanıtlanır; Root→Catalog→Pages zinciri yine zorunludur.

## Günün Mesajı — doğrulanmış ledger ve strict audit

Başlangıç hedefi: **4.018 tarih × 2 bağımsız dil = 8.036 kayıt**.

- TR ledger: `2026-01-01 → 2036-12-31` = **4018 / 4018**
- EN ledger: `2026-01-01 → 2036-12-31` = **4018 / 4018**
- Ledger toplamı: **8036 / 8036**
- Eksik exact tarih/locale kaydı: **0**
- Editorial source coverage: **COMPLETE**
- Strict release catalog audit: **SUCCESS** on exact source HEAD `4d68d5ad007657aafecad79173469ca6e60ffb1f`
- Strict workflow run/job: `33445620611 / 99663941491`
- Audit artifact: `9777939183`, digest `sha256:4aefada627afeda0257a24395b52a5e18b5484fc64c8b6c7b2fda454528a86b5`
- Compiled catalog SHA-256: `6ad0fc34b3ee8146bad0f8f86126de9491cd806e779b2530988ea307685373bf`
- Audit report: `allow_incomplete=false`, `complete=true`, `ok=true`, `record_count=8036`, `missing=0`, near-duplicate=0, repetitive-opening=0, unsafe-certainty=0.

## Flutter Quality progression

### 28-failure baseline

Exact HEAD `f18493949d0229a41e47d2dc05338e2167f599ac`, run/job `33541602606 / 99968946166`, artifact `9814027794`: Analyze SUCCESS, Test FAILURE, exact summary **`+559 -28`**.

Bu baseline sonrasında BaZi Hidden Stems stale expectation, Pacific/Apia skipped-day policy, sentetik PDF fixture'ları, persisted Western tamper/aspect fixture'ları, TR/EN localization widget harness'ları ve duplicate PDF semantics root-cause'ları işlendi.

### 17-failure baseline

Exact HEAD `bf9b954f454f8c8685469010e4519c22073b7773`, run/job `33554498838 / 100011879752`, artifact `9819339077`: Analyze SUCCESS, Test FAILURE, exact summary **`+573 -17`**.

17 failure exact artifact'te şu kümelerdi:

- 4 Professional PDF builder lazy action visibility failure,
- 3 backup lazy restore/accessibility/Semantics lifecycle failure,
- 1 2.0x text-scale lazy Tools target failure,
- 2 main-navigation route/Semantics lifecycle failure,
- 2 critical semantics failure,
- 1 Combined PDF EN lazy-label failure,
- 4 production-generated PDF structural-inspection failure.

Bu 17 failure için `bf9b954... → a2152f4...` lineage'ında 11 source/test repair commit'i uygulandı. Quality threshold, fail-closed guards veya test contract'ları gevşetilmedi.

Ek olarak commit `454f4bd849c6683b86b913bd8494e80cfe90bbc1` ile `test/pdf/pdf_output_inspector_generated_pdf_test.dart` eklendi. Bu regression gate:

1. gerçek `package:pdf` üretimini doğrudan `PdfOutputInspector.requireUsable` sınırından geçirir,
2. nested trailer dictionary sonrasında `/Root → Catalog → Pages` çözümünü doğrular,
3. `/Root` gerçekten yoksa fail-closed davranışı doğrular.

### 11-failure baseline ve current repair

Exact completed HEAD `b726b3196d9dfa0a15c740bc79a8c41f32379aff`, run/job `33564911120 / 100045753949`: Analyze **SUCCESS**, Test **FAILURE**, exact summary **`+582 -11`**.

Bu 11 failure iki kök neden ailesine indirildi:

- 5 production-generated PDF failure: `pdf 3.13.0` PDF 1.5 xref-stream dictionary'sinde `/Root`, `/Type /XRef`'ten önce serialize edilebildiği halde inspector ters anahtar sırasını zorunlu tutuyordu.
- 6 UI/accessibility failure: lazy/off-screen actionlara stale finder ile erişim ve numerology metric semantics grouping eksikliği.

Repair lineage:

- `715d348bb48b1368d93bdc16daa0385ab828ccba` — xref-stream Root extraction dictionary key order'dan bağımsızlaştırıldı; bounded xref object, `/Type /XRef`, strict indirect Root ve Root→Catalog→Pages hâlâ fail-closed doğrulanır.
- `8ee645fa5d33b20b83290d2f60bdd961b1b28f61` — Professional PDF share flow viewport-aware hale getirildi.
- `cb5243fec9bfad26c122f41b8d235d625678b365` — backup merge/replace semantics/48dp/focus-order her kontrol görünürken doğrulanır.
- `7cbab2c0e2c8f602467bef032ad1f6f1c0470ce7` — backup route ve failed-replace rollback canonical action IDs + visible action ile sürülür.
- `07eca6e98b01ad975c8f78f83ca329270c17c290` — 2.0x text-scale test ambiguous `IndexedStack` text finder yerine canonical nav/action IDs kullanır ve actual Records list'i scroll eder.
- `78dbb9056d3881d0ebc9fe1d8c9482dd27e8a7bd` — production numerology metric semantics tek localized row node haline getirildi.

`b726... → 78dbb905...` compare sonucu **6 commits ahead / 0 behind**. Yeni source SHA için Actions runları queued/indexing durumunda olduğundan bu repair **henüz CI-green sayılmaz**.

## APK packaging doğrulaması

Exact SHA `5fb94606b7c4c9445f2675fb3ebf42b36b142ba6`, run/job `33552722873 / 100005891069` üzerinde:

- Android host materialization: **SUCCESS**
- release APK build: **SUCCESS**
- APK size: **53.2 MB**
- packaged Daily Message validator: **FAILURE**

Bu failure, `2030-07` sonrası historical Daily Message shardlarının legacy 5-column schema kullanması ve production loader'ın yalnız canonical 6-column schema kabul etmesi kaynaklı gerçek runtime uyumsuzluğunu açığa çıkardı.

Aynı repair lineage'ında:

- production loader explicit canonical+legacy normalization ile düzeltildi,
- legacy locale yalnız asset path'ten alınır; language/date/random fallback yok,
- unknown schema, empty required content, canonical path/row locale mismatch ve exact duplicate key fail-closed kalır,
- APK ZIP validator aynı açık schema sözleşmesine getirildi ve locale başına exact **4.018**, missing=0, duplicate=0 ve non-empty content şartını korur.

Yeni exact-SHA APK Packaging run tamamlanmadan SUCCESS/DONE iddiası yapılmaz.

## Açık ana blocker'lar

- newest exact HEAD üzerinde bütün zorunlu GitHub Actions kapılarının tamamlanmış SUCCESS olması,
- newest Flutter Quality artifact'inde repair sonrası kalan failure varsa exact root-cause ile kapatılması,
- yeni canonical+legacy Daily Message APK Packaging validator'ın exact SHA üzerinde SUCCESS kanıtı,
- Daily Message için gerçek offline/airplane-mode device asset-open kanıtı,
- RC-1433 için her actual release tarihinde rolling horizon CI kanıtı ve sürekli stok ileri taşıma,
- tracked/signable Android release host ve final clean-checkout release configuration,
- versioned fiziksel IERS EOP + checksum/provenance,
- yeniden dağıtıma uygun offline ephemeris + independent golden accuracy,
- production Lahiri/Chitrapaksha ve GeoNames artifact kanıtı,
- APPROVED UI reference/hash seti ve real-device accessibility/visual regression,
- production Unicode PDF font + license/hash, full parser/open, rendered 5/25/50+ ve device delivery proof,
- Play/rewarded gerçek cihaz kanıtı,
- `pubspec.lock` gerçek dependency resolution sonrası,
- clean-checkout/reproducible signed release APK,
- airplane-mode + Golden Lifecycle + final 1.442 RC audit.

## Son checkpoint

`automation_runs/2026-09-02_0312_flutter_11_failure_root_cause_repair.md`

## Sıradaki çalışma

1. En yeni exact SHA Flutter Quality runını completed durumda oku; queued/indexing durumunu SUCCESS sayma.
2. Flutter Quality kırmızıysa diagnostic artifact üzerinden yalnız gerçekten kalan failure'ları exact root-cause ile kapat; kalite eşiğini gevşetme.
3. Flutter Quality yeşilse exact run/job/artifact evidence'ı kaydet ve canonical+legacy Daily Message APK Packaging sonucuna geç.
4. APK Packaging yeşilse JSON evidence + APK digest'i kaydet; kırmızıysa exact packaged-data/runtime uyumsuzluğunu düzelt.
5. Sonra real offline/airplane-mode Daily Message proof ve fiziksel artifact/font/UI/device/clean-checkout/release blockerlarına dependency sırasıyla devam et.
6. Clean-checkout exact release artifact ve final 1.442-RC lifecycle audit tamamlanmadan FINAL deme.

**FINAL: NO.**
