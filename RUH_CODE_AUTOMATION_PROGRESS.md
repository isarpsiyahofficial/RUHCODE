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
- RC-1131→1144 = PR #1 release governance; repository-level branch protection/ruleset, independent review, physical/device minified parity ve exact final artifact olmadan VERIFIED/DONE yok.
- RC-1145→1160 = PR #2 Android compatibility; API21/API37 + production UI viewport/font/chart/table/keyboard fiziksel kanıtları tamamlanmadan VERIFIED/DONE yok.
- RC-1161→1174 = PR #3 indexed city/birth-location input; production picker/form/permission wiring ve real-device performance olmadan VERIFIED/DONE yok.
- RC-1175→1196 = PR #4 security/privacy; real secure-storage/keystore/biometric/encrypted persistence/release-binary log kanıtları eksik.
- RC-1197→1205 = PR #5 deletion/restore. Eski dedicated run `34309365556` validator'da `RestoreDeletedRecordPolicy.keepDeleted` tokenını bulamadığı için kırmızıydı. Kök neden bu çalıştırmada semantiği açık fail-closed branch yapılarak `c249715419971c1b4ff4cf5ba38c9f38a9c86041` ile düzeltildi; yeni RC1222 gate aynı validator+regression'ı tekrar çalıştırıyor. Production transaction/UI confirmation/tombstone backup serialization hâlâ blocker.
- RC-1206→1221 = PR #6 professional local search/pagination. Dedicated run `34309365775` fiziksel olarak SUCCESS. Production SQLite/FTS, measured cold-start/device memory ve gerçek UI pagination olmadan VERIFIED/DONE yok. PR branch matrix'i main-push promotion olmadığı için NOT_STARTED kalıyor.
- RC-1222→1236 = PR #7 calculation-cache validity/isolation hattı oluşturuldu; production + regression + exact contract + fail-closed validator + dedicated CI mevcut. Checkpoint'te dedicated run queued; matrix NOT_STARTED.
- RC-1237→1248 = PR #8 portable backup assets/professional presets hattı oluşturuldu; production + regression + format documentation + exact contract + fail-closed validator + dedicated CI mevcut. Checkpoint'te dedicated run queued; matrix NOT_STARTED.

## Bu çalıştırmada yapılan gerçek geliştirme

### RC-1197→1205 root-cause düzeltmesi

`DeletionTombstoneLedger.filterRestore` artık `RestoreDeletedRecordPolicy.restoreExplicitly` ve `RestoreDeletedRecordPolicy.keepDeleted` seçeneklerini ayrı ve açık branch'lerle uygular. Default keep-deleted davranışı backup sonrası silinmiş kayıtları yeniden diriltmez; bilinmeyen policy fail-closed hata verir. Commit: `c249715419971c1b4ff4cf5ba38c9f38a9c86041`.

### RC-1222→1236 — calculation cache validity / isolation

`lib/src/calculation_core/calculation_cache_policy.dart` eklendi. Cache identity `subjectId + canonical inputFingerprint + engineVersion + CalculationCacheKind` üzerinden kurulur. Engine version veya input değişikliği cache kimliğini değiştirir; başka müşterinin cache'i eşleşmez. Cache yalnız derivative optimizasyondur; stale/missing cache `computeFromSource` ile authoritative calculation'dan yeniden üretilir.

`CalculationCacheContext` natal location, current transit location, Solar Return technique location, calculation timezone, local-day identity ve planetary-hour window identity alanlarını birbirinden ayırır. Natal cache seyahat/current timezone yüzünden değişmez. Daily cache local gün veya calculation timezone değişince, planetary-hour cache saat penceresi değişince, transit cache current location/timezone değişince stale olur. Solar Return açık technique location ister. Non-default kullanıcı ayarları `CalculationManifestOverrides` ile explicit taşınır.

Production `380059f579599b622ab29512e8ac24845f9773d9`; regression `ec7a7895ecc82695946b95dd67e87d0c21171eed`; exact contract `8c270af47330a71a5f3464748c63ac254af33eef`; validator `f86c90c5638af61230dd2aa92fba622d72da701c`; dedicated CI `fdc4e2d4eaea5a5299107ef92768698492977b6b`. PR #7 açık.

### RC-1237→1248 — portable backup / assets / professional presets

`lib/src/backup/backup_portability_policy.dart` eklendi. `ProfessionalPresetBackup` stable preset ID, orb settings ve kullanıcı interpretation template'lerini structured JSON olarak taşır. Logo veya başka binary asset CSV içine base64/data URI olarak gömülemez; `asset:<id>` referansı kullanılır ve payload `assets/` altında ayrı tutulur.

Restore reference validation'da eksik optional logo `warning`, eksik referenced client ID `critical` olarak ayrılır. `ruh-code-portable-backup-v1` package formatı `records/` + `assets/` düzeniyle `docs/backup/portable-backup-format-v1.md` içinde dokümante edildi; makine-okunur CSV/JSON kopya ve gelecekte uygulama yeniden yazılsa dahi okunabilirlik hedefi açıkça korunur. Opaque proprietary binary tek backup seçeneği olamaz.

Production `4a339ad79081e20e62cd8ac61f3af6d9e2c29447`; regression `97840c6c95c386e8643d2e9b7909dc070b286c07`; format docs `a3933dc73c957d0346837d0e3ff1862f80dadc35`; exact contract `23a5218de96588a4c6cb12c36d53efe38878c3a5`; validator `9977ed1f9071006205c3d07b2fcefa47475118cd`; dedicated CI `7658e102b91074745030883f96dabf6942365508`. PR #8 açık.

## CI / doğrulama durumu

- RC-1206→1221 previous dedicated run `34309365775` = SUCCESS.
- RC-1197→1205 previous run `34309365556` = FAILURE at exact validator token check; root cause fixed in `c249715...` and revalidation is intentionally embedded into the new cache/backup gates.
- PR #7 RC1222-RC1236 dedicated run `34317258421` checkpoint anında queued.
- PR #8 RC1237-RC1248 dedicated run `34317258841` checkpoint anında queued.
- Requirement matrix on the stacked top branch physically shows RC-1217→RC-1249 as NOT_STARTED; PR CI does not self-promote. Main-push-only matrix writers may move only NOT_STARTED→IMPLEMENTED + blocked=YES after validate/test succeeds; they never self-promote TESTED/VERIFIED/DONE.
- Repository genelinde başka kırmızı/pending workflow'lar mevcut; kritik kırmızı kapılar kapanmadan FINAL verilemez.

## Açık blocker'lar

Authoritative independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; historical timezone/DST/polar goldens; production localization catalog + rendered TR/EN UI/PDF/share cards; interpretation/editorial QA; EOP/DE440s redistribution/license evidence; dependency license approvals; encrypted persistence/key management adapter; production migration corpus; tenant/device isolation; real ad/rewarded/PRO verifier; notification scheduler; offline/airplane-mode physical device proof; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact açık.

Ayrıca RC-1222→1236 için production persistent SQLite cache adapter + real timezone/DST integration + calculation-service wiring; RC-1237→1248 için production archive writer/reader asset placement + preset UI persistence + real clean-install asset round-trip gereklidir.

## Sonraki devam noktası

1. Runs `34317258421` ve `34317258841` sonuçlarını fiziksel olarak yeniden oku; kırmızıysa aynı stacked hattın kök nedenini düzelt. RC1197 validator regression'ının yeni gate içinde yeşil olduğunu ayrıca kanıtla.
2. Binding sırada RC-1249+ PDF demo/watermark/Free-PRO sample isolation ve ardından PDF/UI design-system typography/spacing/legend/contrast hattını exact requirement sırasıyla ilerlet.
3. PR #1/#2 governance ve Android compatibility blocker'larını azalt; branch protection admin enforcement kanıtı yoksa blocker'ı koru.
4. RC-0995→1003 exact AKİLES provenance/independent goldens ve RC-0965→0994 traceability açıklarını paralel azalt.
5. RC-0001→RC-1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL deme.

**FINAL: NO.**
