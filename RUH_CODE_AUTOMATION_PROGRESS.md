# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte independent/golden, TR/EN, offline, Free/PRO, backup/PDF, security, accessibility, performance, clean-checkout/lifecycle/device ve exact-release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Canonical durum özeti

- Erken bloklardaki status/promotion zincirleri korunuyor; RC-0062/0082/0083/0086/0087, exact AKİLES provenance ve global release blocker'ları açık.
- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0950 = implementation/matrix zincirleri mevcut; production-scale golden, rendered UI/device, PDF/backup ve diğer global blocker'lar nedeniyle DONE değil.
- RC-0951→0964 = IMPLEMENTED + blocked=YES; physical matrix promotion `5f08942462a0b3784725b9fd7e65de0cc22eb50e`.
- RC-0965→0994 = requirement/test traceability CI mevcut; 1.442 RC doğrudan evidence ile kapanmadığı için release-mode fail-closed.
- RC-0995→1003 = authoritative golden corpus sözleşmesi var; exact AKİLES ve bağımsız production golden değerleri eksik olduğu için promotion yok.
- RC-1004→1039 = IMPLEMENTED + blocked=YES; promotion `fb71d1b9703f35a4dec499e7d7de33151d57a75e`.
- RC-1040→1058 = IMPLEMENTED + blocked=YES; promotion `d96a3b5c1821d81739b491757795cfced5ba040a`.
- RC-1059→1084 = IMPLEMENTED + blocked=YES; promotion `ed87a5c385425a0c3e7f59f7f884c8dc55cab8f6`.
- RC-1085→1104 = IMPLEMENTED + blocked=YES; promotion `a9c4b832269328935dbf6d4753f603d17fa5b1f7`.
- RC-1105→1130 = offline startup/dependency governance zinciri mevcut; `pubspec.lock` fiziksel olarak `09cf4da44c63c8031a149a7c555e37362ef194aa` ile oluştu. EOP/DE440s/package-license/device/exact-release blocker'ları açık.
- RC-1131→1144 = PR #1 release-governance hattında. Regression invocation düzeltmesi `8b71601faaa6cc2d82ef990b18ce0245588d2de8`; repository-level branch protection/ruleset, independent review, physical/device minified parity ve exact final artifact olmadan VERIFIED/DONE yok.
- RC-1145→1160 = PR #2 Android compatibility hattında. API21/API37 launch + production UI viewport/font/chart/table/keyboard fiziksel kanıtları tamamlanmadan VERIFIED/DONE yok.
- RC-1161→1174 = PR #3 indexed city/birth-location input hattında. Dedicated workflow yeni stacked head üzerinde daha önce fiziksel `success` sonucu verdi; production picker/form/permission wiring ve device performance olmadan VERIFIED/DONE yok.
- RC-1175→1196 = PR #4 security/privacy hattında. Dedicated workflow yeni head üzerinde yeniden queued; real secure-storage/keystore/biometric/encrypted persistence/release-binary log kanıtları eksik.
- RC-1197→1205 = PR #5 data deletion/restore hattında IMPLEMENTATION+regression+contract+CI oluşturuldu; dedicated run yeni stacked head üzerinde queued. Production transaction/UI confirmation/backup tombstone integration olmadan VERIFIED/DONE yok.
- RC-1206→1221 = PR #6 professional local search/pagination hattında IMPLEMENTATION+1k/10k regression+contract+CI oluşturuldu; dedicated run `34309365775` checkpoint anında queued. Production SQLite/FTS, device cold-start/memory ve gerçek UI pagination olmadan VERIFIED/DONE yok.

## Bu çalıştırmada yapılan gerçek geliştirme

### RC-1197→1205 — veri silme / cascade / archive / restore

Binding şartname bu blokta tüm veriyi tek işlemle silme, tek müşteriyi silme, bağlı kayıtları önceden gösterme, başka müşterileri etkilememe, açık cascade kuralları, not davranışı, profil silip rapor arşivleme, silme regression'ı ve restore sırasında silinmiş kayıtların kullanıcı seçimine göre ele alınmasını ister.

`lib/src/data/data_deletion_policy.dart` eklendi. `DeleteAllPlan` tüm uygulama verisini silmek için tek explicit destructive operation sınırı sağlar. `ClientDeletionPreview` hedef müşterinin bağlı kayıtlarını mutation öncesi sayılabilir şekilde listeler. `ClientDeletionPlan` stable `clientId` ile yalnız hedef müşterinin profile/consultation/calculation/note/journal/report kayıtlarını kapsar; ilişkisiz müşterilerin kayıtlarını plana alamaz.

`ClientDeletionMode.archiveReports` ile müşteri/profile ilişkili kayıtları silinirken danışmanlık raporları archive set'ine ayrılabilir. Delete ve archive set'leri kesişirse plan fail-closed hata verir. `DeletionTombstoneLedger` backup'tan restore sırasında daha sonra silinmiş kayıtları varsayılan olarak geri getirmez; `RestoreDeletedRecordPolicy.restoreExplicitly` seçilirse kullanıcı açık tercihiyle geri alınabilir.

Regression: `test/data/data_deletion_rc1197_rc1205_test.dart`. Exact contract: `requirements/contracts/rc1197_rc1205_data_deletion_contract.json`. Fail-closed validator: `tools/requirements/validate_rc1197_rc1205_data_deletion.py`. Dedicated matrix gate: `.github/workflows/rc1197-rc1205-data-deletion.yml`. PR #5 açıldı.

### RC-1206→1221 — profesyonel yerel arama / pagination / scale

Binding şartname müşteri adına, etikete, tarihe ve numeroloji sonucuna göre arama; Saturn-return benzeri profesyonel etiketler; sunucusuz local index; binlerce kayıt performansı; 1.000 müşteri ve mümkün olduğunca 10.000 profil stress; tüm müşterileri başlangıçta RAM'e yüklememe ve pagination/lazy loading ister.

`lib/src/data/professional_search.dart` eklendi. `ClientSearchDocument` name/tag/date/numerology alanlarını ayrı taşır; TR karakter normalizasyonu arama anahtarına uygulanır. `LocalSearchPageSource` açıkça local paging contract'ıdır; `ProfessionalSearchCoordinator` `requiresServer=true` kaynakları reddeder ve tek isteği 200 kaydın üstüne çıkaramaz.

`InMemoryIndexedSearchSource` deterministic local fixture/adapter olarak normalized 3-char name-prefix bucket index kullanır. Production SQLite/FTS adapter aynı `LocalSearchPageSource` contract'ını uygulayabilir. Search sonuçları offset+limit+hasMore ile sayfalanır; coordinator startup'ta `loadAll` benzeri bir çağrı sunmaz.

Regression `test/data/professional_search_rc1206_rc1221_test.dart` name/tag/date/numerology aramasını, server-required source reddini, 1.000 kayıt bounded-page senaryosunu ve 10.000 kayıt stress fixture'ını kapsar. Exact contract `requirements/contracts/rc1206_rc1221_professional_search_contract.json`; validator `tools/requirements/validate_rc1206_rc1221_professional_search.py`; dedicated CI `.github/workflows/rc1206-rc1221-professional-search.yml`. İlk compile-safety düzeltmesi bounded `int.clamp` sonucuna explicit int cast ekledi (`e7a5c668135e1421031e56677ddd50a41d440b8a`). PR #6 açıldı.

## CI / doğrulama durumu

- Yeni stacked head `84ff6758c07463c6298859094379a8ccd5b67c17` üzerinde `RC1197-RC1205 Data Deletion` run `34309365556` queued.
- Aynı head üzerinde `RC1206-RC1221 Professional Search` run `34309365775` queued.
- `RC1175-RC1196 Security Privacy` run `34309365672` queued.
- Repository genelinde eski kırmızı workflow'lar hâlâ mevcut; kritik kırmızı kapılar kapanmadan FINAL verilemez.
- Yeni RC blokları CI green/matrix promotion olmadan elle IMPLEMENTED/TESTED/VERIFIED/DONE yapılmadı.

## Açık blocker'lar

Authoritative independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; historical timezone/DST/polar goldens; production localization catalog + rendered TR/EN UI/PDF/share cards; interpretation/editorial QA; EOP/DE440s redistribution/license evidence; dependency license approvals; encrypted persistence/key management adapter; production migration corpus; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode physical device proof; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact açık.

RC-1132/1135/1136 repository-level branch-protection/ruleset enforcement; RC-1143/1144 minified behavior parity; RC-1148→1160 production UI device evidence; RC-1161→1174 real picker/form/permission wiring; RC-1175→1196 real secure-storage/encryption/biometric/platform-storage; RC-1197→1205 persistence transaction + UI preview + tombstone backup serialization; RC-1206→1221 SQLite/FTS + measured startup/memory + real UI paging ayrıca blocker.

## Sonraki devam noktası

1. Runs `34309365556`, `34309365775` ve `34309365672` sonuçlarını fiziksel doğrula; kırmızıysa aynı stacked branch'te root-cause düzelt.
2. Binding sırada RC-1222+ cache anahtarı / engineVersion invalidation / wrong-client cache isolation / cache-rebuild / daily-data expiry hattını gerçek production+regression olarak ilerlet.
3. PR #1/#2 governance ve Android compatibility kırmızı/pending kapılarını ayrıca azalt; branch-protection admin erişimi yoksa blocker'ı koru.
4. RC-0995→1003 exact AKİLES provenance/independent goldens ve RC-0965→0994 traceability açıklarını paralel azalt.
5. RC-0001→RC-1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL deme.

**FINAL: NO.**
