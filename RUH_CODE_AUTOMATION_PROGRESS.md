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
- PR #1 RC-1131→1144; #2 RC-1145→1160; #3 RC-1161→1174; #4 RC-1175→1196; #5 RC-1197→1205; #6 RC-1206→1221; #7 RC-1222→1236; #8 RC-1237→1248; #9 RC-1249→1272; #10 RC-1273→1303; #11 RC-1304→1344; #12 RC-1345→1361; #13 RC-1362→1374 stacked durumda.
- RC-1206→1221 dedicated run SUCCESS; production SQLite/FTS/device/UI blocker'ları açık.
- RC-1222→1248 kendi contract/regression zincirleri mevcut; upstream deletion compile açığı `f3eb1a3d32dafe18ff330c844861cb7c6f9acecf` ile düzeltildi, physical promotion yeniden bekleniyor.
- RC-1249→1272 dedicated run exact contract + yeni PDF regression'larını geçti; upstream kırmızı yeniden çalışıyor.
- RC-1273→1285 production token/regression/contract/validator/CI mevcut; rendered/device adoption kapıları açık.
- RC-1286→1303 production matrix/regression/contract/validator/CI mevcut; `Iterable.single` yanlış kullanımı upstream testte `ad8497f694e789cd5312852629bf134b3ee251bd` ile `singleWhere` olarak düzeltildi.
- RC-1304→1344 Golden Lifecycle production gate/regression/contract/validator/CI mevcut; yeni stacked run `34349531737` queued. Golden test `void` assertion hatası upstream PR #11'de `00b35d8b61da449cf524e7745e20086ec3a11198` ile düzeltildi.
- RC-1345→1361 release cleanliness/network inventory audit mevcut; yeni stacked run `34349531669` queued.
- RC-1362→1374 offline-core contract + release APK airplane-mode emulator gate mevcut; dedicated run `34349531930` queued. Startup smoke tek başına DONE değildir; tüm core yeteneklerin production instrumentation ile uçak modunda gerçekten kullanılması gerekir.

## RC-1304→1344 — Golden Lifecycle release gate

`lib/src/lifecycle/golden_lifecycle.dart` sekiz ana modülü (Western Natal, Vedic, Numerology, BaZi, Planetary Hours, Professional Client, Backup, PDF) merkezi completion checklist'e bağlar. Her modül calculation/UI/interpretation/TR/EN/export/PDF/cache/tests kapılarının tamamını geçmeden complete olamaz; yalnız ekran açılması veya test dosyası bulunması yeterli değildir.

Golden Lifecycle adımları bağlayıcı sırada fail-closed tutulur: yeni müşteri → Natal → Vedik → Numeroloji → not → danışmanlık → PDF → CSV backup → data clear → restore → aynı müşteri → doğum verisi → hesaplama → not → profesyonel ayar → tekrar PDF → restore parity. Stable client identity ve birth/calculation/notes/professional-settings/PDF semantic digest değerleri restore öncesi/sonrası eşleşmelidir.

Required scenario matrix tam 16 kombinasyondur: TR/EN × Free/PRO × offline/online × clean-install/upgrade. Debug build, kırmızı critical test veya skip edilmiş critical test Golden Lifecycle validation'ını doğrudan kırar. Bu aşama production gate implementasyonudur; real release APK üzerinde production persistence/calculation/PDF/backup adapter'larıyla 16 fiziksel lifecycle koşusu tamamlanmadan VERIFIED/DONE değildir.

Production `add0a55c8a0e6ecf1febfff500fef94419375cd4`; regression `f61bd21db37e6cb7d2473ad241cbee936aa56bbd`; exact contract `9d777ebde206977a413fd6299b049d4346c5e299`; validator `0acaee0dcfdbf80eb4d75108a0e0c73b4b3ff7bd`; dedicated CI definition `c8fc6d8a31901c1fb1ae39c96fb91c387eb58e7f`; test compile fix upstream `00b35d8b61da449cf524e7745e20086ec3a11198`.

## RC-1345→1361 — release cleanliness / network inventory

`governance/network_call_inventory.json` doğrudan uygulama ağ çağrılarını explicit inventory olarak tutar. Mevcut direct application network call listesi boştur; Google Play Billing yalnız SDK-managed, user-initiated purchase/restore capability olarak ayrı belirtilir ve core requirement değildir.

`tools/release/audit_production_cleanliness.py` `lib/` kaynaklarını fail-closed tarar: Lorem ipsum, coming-soon, placeholder interpretation, fake/mock calculation, debug API/menu, production test/demo client marker'ları; ayrıca `package:http`, `package:dio`, `HttpClient`, `Socket`, `WebSocket` ve doğrudan HTTP URL literal'leri. Bulunan direct primitive inventory ile birebir uyuşmazsa gate kırılır. Calculation, PDF, CSV export/restore, profile-open ve local professional-client CRUD amaçlı ağ erişimi inventory'de olsa bile yasaktır.

Static audit exact release-binary inspection değildir. RC-1345→1361 VERIFIED/DONE için release artifact içeriğinin ayrıca denetlenmesi ve RC-1362+ gerçek airplane-mode lifecycle kanıtı gerekir.

Network inventory `c3753ccd53c25038da00d8c49a5c2bc1ada3119e`; source audit `81549c7f4ea90e17ddf1034569530644bdaa6c49`; exact contract `05af62a078803d45a6b03ea3a444d3d14e1ab7bd`; validator `786a9adfd8c5384126b7a2f349640270fa987d5b`; CI `9cbea53ad0a0e94bf8104cfcea37a2f5f62e738b`.

## RC-1362→1374 — airplane-mode release gate

`lib/src/offline/offline_core_capabilities.dart` on çekirdek yeteneği uçak modunda zorunlu olarak tanımlar: Western chart, Vedic, Numerology, BaZi, Planetary Hours, records, PDF export, CSV export, CSV restore ve local professional client management. Internet yalnız advertising, store verification ve explicit external share için izin verilen opsiyonel exception olarak tutulur.

`AirplaneModeEvidence` fail-closed çalışır: airplane mode gerçekten açık değilse, artifact release değilse, tek bir core capability eksikse veya end-to-end core lifecycle tamamlanmadıysa release evidence kabul edilmez.

Dedicated `.github/workflows/rc1362-rc1374-airplane-mode.yml` Flutter 3.44.7 ile release APK üretir, SHA-256 kaydeder, Android API 35 emulator'a kurar, airplane mode + Wi-Fi/data kapatma uygular, production package'i açar ve PID/fatal-crash kontrolü yapar. Bu startup kanıtıdır; requirement'ların tamamını VERIFIED/DONE yapmak için production instrumentation her core capability'yi aynı uçak-modu koşusunda gerçekten çalıştırıp PDF/CSV/restore dahil sonuç kanıtı üretmelidir.

Production `e2c61f11bc87995d9592e4a23b8b92b004b9547d`; regression `c5913536d3683e7399a2b817066c7e22b26ad1ae`; exact contract `13d75f5d7f8d48cf2530612862ce3908bfac7ed7`; CI `066e64c67ed32e679a3c5704f4de1af14138a5b8`; dedicated run `34349531930` queued.

## Genel Flutter Quality açıkları

PR #11 merge HEAD'inde `flutter analyze --fatal-infos` 96 issue ile kırmızıydı. Bu turda doğrudan yeni/komşu üç kök neden kapatıldı: Golden Lifecycle void assertion, RC-1286 Iterable.single invocation ve nullable `BirthTimeValue.known` karşılaştırmaları (`dcee8495ff60dfdb8e17208935a864d007fc6089`). Logda ayrıca eski spiritual test package importları, Lo Shu API/test uyuşmazlıkları, aspect-grid phase parametresi, birkaç unnecessary import/cast ve diğer legacy compile açıkları bulunuyor; critical quality gate kırmızı olduğu sürece FINAL yok. PR #13 güncel Flutter Quality run `34349531801` yeniden queued durumda.

## Global blocker'lar

Exact AKİLES provenance; independent authoritative calculation goldens; Panchanga/Vedic ve Dasha/Varga/Gochara/BaZi providers; historical timezone/DST/polar goldens; rendered TR/EN UI/PDF; interpretation/editorial QA; EOP/DE440s/package license evidence; encrypted persistence/key management/migrations; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; full airplane-mode production instrumentation; security/accessibility/performance; branch/review governance; remaining Flutter analyzer/test failures; clean-checkout/lifecycle ve exact release artifact.

## Sonraki devam noktası

1. RC-1304→1344 run `34349531737`, RC-1345→1361 run `34349531669`, RC-1362→1374 run `34349531930` ve Flutter Quality run `34349531801` sonuçlarını fiziksel doğrula; kırmızıysa root-cause düzelt.
2. Binding sırada RC-1375→1404 Requirement Traceability Matrix / final-CI / exact-artifact zincirini mevcut 1.442-row matrix ile birleştirerek ilerlet; zorunlu evidence sütunlarını fail-closed yap.
3. Flutter Quality logundaki remaining compile/analyzer açıklarını dependency sırasıyla kapat; özellikle wrong-package spiritual test imports, Lo Shu API/test mismatch ve aspect-grid phase açığı.
4. RC-1222→1303 yeniden çalışan dedicated CI/promotion sonuçlarını doğrula.
5. RC-0995→1003 provenance/golden ve RC-0965→0994 traceability açıklarını paralel azalt.
6. RC-0001→RC-1442 tamamı DONE ve bütün release kapıları green olmadan FINAL deme.

**FINAL: NO.**
