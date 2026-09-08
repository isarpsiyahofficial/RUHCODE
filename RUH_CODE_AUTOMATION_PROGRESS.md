# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte independent/golden, TR/EN, offline, Free/PRO, backup/PDF, security, accessibility, performance, clean-checkout/lifecycle/device ve exact-release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum — doğrulanmış özet

- RC-0061 = IMPLEMENTED + blocked=YES; RC-0062 unresolved promotion.
- RC-0082→0083 = NOT_STARTED/blocked; RC-0086→0087 = IMPLEMENTED + blocked=YES.
- RC-0099→0101 = TESTED + blocked=YES (`f3facba3e0be477fc88d4f7e3af959573a13121b`).
- RC-0102→0104 = TESTED + blocked=YES (`7e6a91721ddd00ab6aeef8443a7fec5eb87dee84`).
- RC-0105→0110 = TESTED + blocked=YES (`4bcd3593b39c7aa1b673178c3755b66ad02065af`).
- RC-0112, RC-0114 = TESTED + blocked=YES (`5c6266c5af635e81c963c3c7255c6973875103fe`).
- RC-0118 = TESTED + blocked=YES (`28c73506c796bb9ab3d045e4ba36ca16ee6b6737`).
- RC-0111/0113/0115/0116/0117 = IMPLEMENTED + blocked=YES; RC-0119→0122 = IMPLEMENTED + blocked=YES.
- RC-0123 = TESTED + blocked=YES (`c29fbb359fee9dd0bf501d8cb7fd195c94a15638`).
- RC-0124→0126 = NOT_STARTED/blocked; exact AKİLES provenance yok.
- RC-0127→0134 = IMPLEMENTED + blocked=YES; RC-0135 = TESTED + blocked=YES (`919afe87d349b4dd61b531830d3927ed43d08aa5`); RC-0136 = TESTED + blocked=YES (`cec58ff86d9631ffce36190581e633f5b35f61a4`).
- RC-0137→0141 = TESTED + blocked=YES (`6d639ca3deceeb1b88892e3ca02b02b6cb5fbbfc`).
- RC-0142→0148 = TESTED + blocked=YES (`e076b1d4698aee48f3a07f49448a27ebee04afde`).
- RC-0149→0153 = TESTED + blocked=YES (`85edfde6f2064991a47cfef2ee10a6c13d923d7e`).
- RC-0154→0157 = TESTED + blocked=YES (`d4c6b14bf6c09ea2ae6830d445148850bc8b0048`).
- RC-0158→0184 = IMPLEMENTED + blocked=YES.
- RC-0185→0186 = TESTED + blocked=YES (`d6413c46c5d7dcf5cd4197f1dbd8a30335db2391`).
- RC-0187→0211 = TESTED + blocked=YES (`ef1dba9efb73d9ce0c5bc852548f704e5dd26aa4`).
- RC-0212→0270 = IMPLEMENTED + blocked=YES; physical TESTED promotion eksikleri korunuyor.
- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0341 = IMPLEMENTED + blocked=YES; matrix evidence `2155cfc613f0f5773f277999e8dd21d9f74ee66f`; production-scale golden corpus açık.
- RC-0342→0371 = implementation chain present; physical promotion eksikleri korunuyor.
- RC-0372→0381 = IMPLEMENTED + blocked=YES; matrix evidence `8b4bb76d9a0b6e22fdddc2e51060ab7501757ae5`.
- RC-0382→0393 = IMPLEMENTED + blocked=YES; matrix evidence `40bf4d144ece622dacc2a40d929068b198e263d9`.
- RC-0394→0420 = IMPLEMENTED + blocked=YES; matrix evidence `ed0bd0672af52a073eb841c474494e06d9f31e74`.
- RC-0421→0460 = IMPLEMENTED + blocked=YES; matrix evidence `62603b7c49fb3bcb20c2346e263ec6bfdddc2e29`.
- RC-0461→0480 = IMPLEMENTED + blocked=YES; matrix evidence `ab7014a9880e3e8b3d221f36843e16a56920715c`.
- RC-0481→0492 = IMPLEMENTED + blocked=YES; matrix evidence `c63a3ce30315157b7f99beec7017af4a8966e15b`.
- RC-0493→0526 = production + regression + exact contract + fail-closed validator + dedicated CI gates present; physical promotion yeniden doğrulanmalı.
- RC-0527→0545 = IMPLEMENTED + blocked=YES; dedicated CI gates present.
- RC-0546→0584 = IMPLEMENTED + blocked=YES; personal Today/calendar chain present.
- RC-0585→0612 = IMPLEMENTED + blocked=YES; learning/teaching/share-card chain present.
- RC-0613→0632 = IMPLEMENTED + blocked=YES; quick-calculation chain present.
- RC-0633→0673 = IMPLEMENTED + blocked=YES; local-first runtime chain present; bot promotion commit henüz kanıtlanmadı.
- RC-0674→0694 = IMPLEMENTED + blocked=YES; deterministic calculation/interpretation chain present; bot promotion commit henüz kanıtlanmadı.
- RC-0695→0754 = IMPLEMENTED + blocked=YES; central/versioned data model chain present; matrix satırları physical promotion olmadan yükseltilmeyecek.
- **RC-0755→0773 = IMPLEMENTED + blocked=YES; transactional persistence/data-safety production + regression + exact contract + fail-closed validator + matrix-writing CI gate present; physical green/promotion henüz kanıtlanmadı.**
- **RC-0774→0848 = IMPLEMENTED + blocked=YES; portable relational CSV backup/import + manifest/checksum/schema/FK validation + merge/replace + safety snapshot + new post-import rollback boundary present; exact clean-install round-trip RC-0848 açık, physical green/promotion henüz kanıtlanmadı.**
- **RC-0849→0858 = IMPLEMENTED + blocked=YES; 4.500+ record Unicode/long-note/emoji/newline/same-name/unknown-time stress corpus + legacy schema regression chain present; physical green/promotion henüz kanıtlanmadı.**

## Bu çalıştırmadaki gerçek geliştirme

### RC-0755→0773 — transactional persistence / veri güvenliği

`lib/src/data/local/data_safety_coordinator.dart` eklendi. App update, dil, tema ve Free↔PRO geçişleri kullanıcı verisini değiştiren bir mutation yüzeyi almıyor. Related writes tek `LocalDatabase.transaction` içinde atomik uygulanıyor; batch'in sonraki adımı kırılırsa önceki yazılar commit edilmiyor. Startup integrity kontrolü local recovery snapshot kimliklerini döndürüyor. Snapshot oluşturma transactionally consistent; restore öncesi zorunlu safety snapshot alınıyor, restore sonrası integrity tekrar doğrulanıyor ve bozuk sonuçta safety snapshot geri yükleniyor.

Regression: `test/data/data_safety_coordinator_rc0755_rc0773_test.dart`. Exact contract: `requirements/contracts/rc0755_rc0773_transactional_data_safety_contract.json`. Validator: `tools/requirements/validate_rc0755_rc0773_transactional_data_safety.py`. CI gate başarılı olduğunda yalnız `NOT_STARTED→IMPLEMENTED`, `blocked=YES` promotion yapacak şekilde fail-closed matrix writer'a çevrildi; TESTED/VERIFIED/DONE yükseltmiyor.

Ana commitler: `3cce176688d8479cd22db4efbad61ec5c729476f`, `c58fb490da3631ed8ec22169be41f1d957aa7c62`, `f6651fe075bdf308822575679f5335e0525056df`, `18afe974e2c95467e9c1c649ac2949ace7f6b064`, CI promotion düzeltmesi `ec912cd1d00c04ab0ecc802c18e8979a7a952b3b`.

### RC-0774→0848 — portable CSV backup / verified restore

Mevcut relational CSV backup yapısı yeniden doğrulandı: profiles/clients/consultations/notes/calculations/calculation_manifests/journal/goals/habits/tarot/favorites/settings ayrı CSV'ler, UTF-8 codec, null sentinel, CSV escaping, locale-independent machine values, manifest/count/checksum, schema/FK/required-id/date/manifest validation, preview, merge/replace ve rollback altyapısı mevcut.

Yeni `lib/src/backup/verified_backup_restore.dart` merge ve replace'in üstüne ortak post-import integrity sınırı ekledi. Invalid preview hiçbir mutation/snapshot başlatmıyor. Valid import öncesi safety snapshot alınıyor; import commit olsa bile post-import bütünlük doğrulaması kırılırsa pre-import snapshot geri yükleniyor. Rollback da kırılırsa ikinci hata yutulmuyor.

Regression: `test/backup/verified_backup_restore_rc0774_rc0848_test.dart`. Exact contract/validator/CI: `requirements/contracts/rc0774_rc0848_portable_backup_contract.json`, `tools/requirements/validate_rc0774_rc0848_portable_backup.py`, `.github/workflows/rc0774-rc0848-portable-backup.yml`. Matrix writer yalnız IMPLEMENTED ceiling ile çalışıyor.

Ana commitler: `ad44244c07aa671bdf39dac4ec12e3e853312ebb`, test fix dahil `60bc24d997b15193355855e6b98084672a5db6d6`, `2f7647a599c85a1fdacb9e1f092283235528630a`, `c42b1007fe7088b0620f245a2d87b2c764a679fa`, CI promotion düzeltmesi `0353b789a2479e0a238472cab2ee5805fa5b5439`.

### RC-0849→0858 — backup stress corpus

`test/backup/backup_stress_rc0849_rc0858_test.dart` 1.500 profil + 1.500 müşteri + 1.500 uzun not ile 4.500+ kayıtlık stress corpus kurdu. Türkçe özel karakterler, English text, emoji, embedded newline, virgül/tırnak içeren uzun notlar, aynı görünen adlar, unknown birth time + null time birlikte round-trip preview'da doğrulanıyor. Eski schema requirement'ı mevcut `legacy_backup_v0_migrator_test.dart` ile contract'a bağlandı.

İlk fixture'daki geçersiz Dart string repetition aynı çalıştırmada fark edilip `3b90341f504727ffa550580a32c15aa2be71a932` ile düzeltildi. Exact contract `e3b7d8f6a4616f706895abb7f6e0575bbd233180`, validator `9b36c9eb83abd410566b7c242fe67fc5ff239bd8`, matrix-writing CI gate son hali `61c16a70b9458e6b35b1f4c58b43a7949f13e1f6`.

## Açık blocker'lar

Yeni üç blok için GitHub Actions çalışmaları son kontrolde queued; bu nedenle matrix bot commit'i ve TESTED statüsü henüz iddia edilmiyor. RC-0755→0773 için gerçek cihaz process-kill/update-survival, encrypted snapshot storage ve recovery UI; RC-0774→0848 için exact release artifact üzerinde export → clean install → import → veri/calculation equality; RC-0849→0858 için CI physical green ve device-scale evidence açık.

Global blocker'lar da korunuyor: independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion; authoritative Dasha/Varga/Gochara ve BaZi providers; rendered TR/EN UI/PDF/share cards; true text/vector PDF pagination/font embedding; encrypted persistence/key management; production migration corpus; interpretation/editorial QA; tenant/device isolation; real ad/rewarded/PRO verifier; gerçek notification scheduler; offline/airplane-mode; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact. RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-0755→0773, RC-0774→0848 ve RC-0849→0858 dedicated CI/matrix sonuçları fiziksel olarak yeniden okunacak; kırmızıysa root cause aynı çalıştırmada düzeltilecek, yeşil matrix bot commit'i varsa yalnız kanıtlanan lifecycle seviyesi kaydedilecek.
2. Binding sıra **RC-0859+ PDF REQUIREMENTS** hattından devam edecek: gerçek text/vector PDF, TR/EN karakter/font embedding, vector chart/symbol, layout/overflow/page-break ve uygulamanın aynı verified calculation result'larını tüketen non-recomputing PDF pipeline.
3. Eski physical promotion açıkları ayrıca korunacak ve bağımsız fırsatta yeniden kontrol edilecek.
4. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapılmayacak.
5. RC-0001→1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL denmeyecek.

**FINAL: NO.**