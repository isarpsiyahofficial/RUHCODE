# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific evidence ile birlikte independent/golden, TR/EN, offline, Free/PRO, backup/PDF, security, accessibility, performance, clean-checkout/lifecycle/device ve exact-release kapıları kapandığında verilir. Canonical lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; exact kapsam `RC-0001→RC-1442`, toplam 1.442 requirement.

## Canonical durum

- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0950 implementation/matrix zincirleri mevcut; global goldens/device/PDF/backup blocker'ları nedeniyle DONE değil.
- RC-0951→0964 = IMPLEMENTED + blocked=YES (`5f08942462a0b3784725b9fd7e65de0cc22eb50e`).
- RC-0965→0994 traceability release-mode fail-closed; 1.442 requirement doğrudan evidence ile kapanmış değil.
- RC-0995→1003 authoritative golden contract mevcut; exact AKİLES provenance/independent values eksik.
- RC-1004→1039 = IMPLEMENTED + blocked=YES (`fb71d1b9703f35a4dec499e7d7de33151d57a75e`).
- RC-1040→1058 = IMPLEMENTED + blocked=YES (`d96a3b5c1821d81739b491757795cfced5ba040a`).
- RC-1059→1084 = IMPLEMENTED + blocked=YES (`ed87a5c385425a0c3e7f59f7f884c8dc55cab8f6`).
- RC-1085→1104 = IMPLEMENTED + blocked=YES (`a9c4b832269328935dbf6d4753f603d17fa5b1f7`).
- RC-1105→1130 dependency/offline governance mevcut; `pubspec.lock` `09cf4da44c63c8031a149a7c555e37362ef194aa` ile fiziksel.
- PR #1 RC-1131→1144; #2 RC-1145→1160; #3 RC-1161→1174; #4 RC-1175→1196; #5 RC-1197→1205; #6 RC-1206→1221; #7 RC-1222→1236; #8 RC-1237→1248; #9 RC-1249→1272; PR #10 RC-1273→1303 stacked durumda.
- RC-1206→1221 dedicated run SUCCESS; production SQLite/FTS/device/UI blocker'ları açık.
- RC-1222→1248 kendi contract/regression zincirleri mevcut; eski upstream deletion compile kırmızısı nedeniyle physical promotion açık.
- RC-1249→1272 dedicated run kendi exact contract + üç PDF regression testini geçti; upstream RC1197 deletion compile hatasında kırıldı. Hata bu çalıştırmada düzeltildi (`f3eb1a3d32dafe18ff330c844861cb7c6f9acecf`).
- RC-1273→1285 production token/regression/contract/validator/CI mevcut; rendered/device adoption kapıları açık.
- RC-1286→1303 production matrix/regression/contract/validator/CI mevcut; lifecycle promotion CI geçmeden yapılmayacak.

## RC-1249→1272 — PDF export governance

Free demo ile gerçek müşteri export'u fail-closed ayrılır. Free sample demo data + watermark ister; gerçek müşteri PDF'si PRO + stable client ID ister ve demo data kabul etmez. Cancellation/exception partial PDF'yi success yapamaz; output scoped/atomic publish edilir. Aynı müşteri işleri serialize edilir, global concurrency sınırlıdır, deterministic filename collision/content order vardır. Dedicated CI'da exact contract ve bütün yeni PDF regression'ları yeşil oldu; tek kırmızı upstream deletion compile idi.

## RC-1197→1205 compile root-cause düzeltmesi

`ClientDeletionPlan` constructor'ında `deleteIds` ve `archiveIds` parametreleri `Iterable<String>` tipindeyken `.intersection()` çağrılıyordu. CI gerçek Dart derlemesinde bunu reddetti. Overlap doğrulaması normalize edilmiş `Set<String>` field'ları (`this.deleteIds.intersection(this.archiveIds)`) üzerinden çalışacak şekilde düzeltildi: `f3eb1a3d32dafe18ff330c844861cb7c6f9acecf`.

## RC-1273→1285 — typography / spacing / contrast design system

Merkezi semantic `title / section / body / caption` sınıfları, font floors, line-height, paragraph/section/card/screen/PDF/chart spacing tokenları, explicit dark palette ve WCAG-AA light/dark contrast regression'ları mevcut. Production screen/chart/PDF token adoption audit, rendered TR/EN goldens, text-scale/device accessibility ve exact release artifact açık.

## RC-1286→1303 — Feature-ID lifecycle matrix + offline transfer

`lib/src/entitlements/entitlement_scenario_matrix.dart` merkezi `RuhFeatureIds.all` kataloğundaki her feature için yedi ayrı scenario üretir: Free, PRO, rewarded temporary, offline PRO, purchase restore, reinstall restore ve device-change restore. Matrix exact cardinality/uniqueness kontrolüyle fail-closed doğrulanır; rewarded access yalnız catalog tarafından izin verilen PRO feature'ları açabilir.

`OfflineFirstAccountPolicy` core kullanım için Ruh Code account/email-password/account backend zorunluluğunu reddeder. CSV backup cihazlar arası taşımayı destekleyen kaynak kabul edilir; eski cihaz export/yeni cihaz import akışı Ruh Code server'ı gerektirmez. Google Drive/iCloud/USB/e-posta yalnız kullanıcı seçtiği dış transport olarak modellenir; Ruh Code bu servisleri core dependency olarak yönetmez ve automatic cloud backup core requirement değildir.

Production `05e9e8610af367fe07f4d934bd40dc3629eabc81`; regression `e05e8bdc1555afdae794bf06653f2c277921b506`; exact contract `1b85e2d8443af35615b500fd613dbc91e1bb8f76`; validator `2153510f2640966741745f1ca06060461350a754`; dedicated CI `b6fe21ec572a7eadf00292464b2cf3c42e2814f8`.

RC-1286→1303 VERIFIED/DONE değildir: real Play restore across reinstall/device change, physical offline-PRO verification, production CSV export/import device-transfer flow ve exact release artifact gerekir.

## Global blocker'lar

Exact AKİLES provenance; independent authoritative calculation goldens; Panchanga/Vedic ve Dasha/Varga/Gochara/BaZi providers; historical timezone/DST/polar goldens; rendered TR/EN UI/PDF; interpretation/editorial QA; EOP/DE440s/package license evidence; encrypted persistence/key management/migrations; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode physical proof; security/accessibility/performance; branch/review governance; clean-checkout/lifecycle ve exact release artifact.

## Sonraki devam noktası

1. PR #10 güncel head üzerindeki RC-1197 recheck, RC-1249→1272 PDF, RC-1273→1285 design-system ve RC-1286→1303 dedicated CI sonuçlarını fiziksel doğrula; kırmızıysa root-cause düzelt.
2. Binding sırada RC-1304+ module completion checklist / release-user-flow bloğunu exact sırayla ilerlet.
3. RC-1222→1248 upstream compile kırmızısı yeni fix ile kapanmadan promotion verme.
4. RC-0995→1003 provenance/golden ve RC-0965→0994 traceability açıklarını paralel azalt.
5. RC-0001→RC-1442 tamamı DONE ve bütün release kapıları green olmadan FINAL deme.

**FINAL: NO.**
