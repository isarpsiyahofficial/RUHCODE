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
- RC-0158→0165 = IMPLEMENTED + blocked=YES; RC-0166→0184 = IMPLEMENTED + blocked=YES.
- RC-0185→0186 = TESTED + blocked=YES (`d6413c46c5d7dcf5cd4197f1dbd8a30335db2391`).
- RC-0187→0211 = TESTED + blocked=YES (`ef1dba9efb73d9ce0c5bc852548f704e5dd26aa4`).
- RC-0212→0223, RC-0224→0229, RC-0230→0247, RC-0248→0270 = IMPLEMENTED + blocked=YES; physical TESTED promotion commit'leri henüz kanıtlanmadı.
- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0341 = IMPLEMENTED + blocked=YES; physical matrix evidence `2155cfc613f0f5773f277999e8dd21d9f74ee66f`; production-scale golden corpus TESTED/VERIFIED/DONE'u bloklar.
- RC-0342→0359 ve RC-0360→0371 = implementation chain present; physical matrix promotion henüz kanıtlanmadı.
- RC-0372→0381 = IMPLEMENTED + blocked=YES; physical matrix evidence `8b4bb76d9a0b6e22fdddc2e51060ab7501757ae5`.
- RC-0382→0393 = IMPLEMENTED + blocked=YES; physical matrix evidence `40bf4d144ece622dacc2a40d929068b198e263d9`.
- RC-0394→0420 = IMPLEMENTED + blocked=YES; physical matrix evidence `ed0bd0672af52a073eb841c474494e06d9f31e74`.
- RC-0421→0460 = IMPLEMENTED + blocked=YES; physical matrix evidence `62603b7c49fb3bcb20c2346e263ec6bfdddc2e29`.
- RC-0461→0480 = IMPLEMENTED + blocked=YES; physical matrix evidence `ab7014a9880e3e8b3d221f36843e16a56920715c`.
- RC-0481→0492 = IMPLEMENTED + blocked=YES; physical matrix evidence `c63a3ce30315157b7f99beec7017af4a8966e15b`.
- RC-0493→0510 = production + regression + exact contract + fail-closed validator + dedicated CI gate present; physical matrix promotion not yet proven.
- RC-0511→0526 = production + regression + exact contract + fail-closed validator + dedicated CI gate present; physical matrix promotion not yet proven.
- RC-0527→0535 = IMPLEMENTED + blocked=YES; production + regression + exact contract + fail-closed validator + dedicated CI gate present.
- RC-0536→0545 = IMPLEMENTED + blocked=YES; production + regression + exact contract + fail-closed validator + dedicated CI gate present.
- **RC-0546→0584 = IMPLEMENTED + blocked=YES; personal Today/calendar production + regression + exact contract + fail-closed validator + dedicated CI gate present.**
- **RC-0585→0612 = IMPLEMENTED + blocked=YES; learning/teaching/share-card production + regression + exact contract + fail-closed validator + dedicated CI gate present.**

## Bu çalıştırmadaki gerçek geliştirme

### RC-0546→0584 — Bugün / değişen kişisel veri / takvim / reminder

`lib/src/daily/personal_today_calendar.dart` statik genel yorum yerine source/version provenance taşıyan kişisel sinyal modelini kurar. Ay konumu, gezegen saati, Personal Day, transit, Vedik dönem, Ay fazı ve günlük kayıt türleri ayrı tutulur. `importantEffects` önem sırasını korur; Free ilk etkilerle sınırlandırılabilir, PRO tümünü görür. Week/month range desteklenir, year view explicit PRO policy ile fail-closed.

Tarihli `PersonalCalendar` geçmiş güne dönüldüğünde o güne ait journal kayıtlarını geri verir. Favori tarih ve transit exact / Personal Month / full moon / planetary-hour reminder türleri ayrı yönetilebilir. `HistoricalCorrelationPolicy` TR/EN açık disclaimer ile geçmiş notlarının nedensellik kanıtı olmadığını zorunlu biçimde belirtir.

Regression, exact RC-0546→0584 contract, fail-closed validator ve dedicated Flutter CI gate eklendi. Authoritative runtime providers, gerçek scheduler, rendered TR/EN UI/device, offline persistence ve global release evidence eksik olduğu için status ceiling IMPLEMENTED tutulur.

### RC-0585→0612 — Öğrenme Modu / Öğretim görünümü / Paylaşım Kartı

`lib/src/learning/learning_and_share.dart` gezegen, burç, ev, aspect ve kullanıcı haritasındaki kombinasyon öğrenme içeriklerini source/version provenance ile taşır. `TeachingView` evler/gezegenler/aspectler katmanlarını bağımsız görünür yapabilir; calculation result referansı korunur.

Paylaşım kartı verisi `ShareDataPoint.calculationResultRef` olmadan oluşturulamaz. Gökyüzü, Personal Day, Universal Day ve spiritüel kart türleri ayrıdır. Profesyonelin kendi metni calculation-backed veriden ayrı alanda tutulur; `DailyContentAssistant` doğrulanmış calculation verisi yoksa içerik icat etmez ve fail-closed davranır.

Regression, exact RC-0585→0612 contract, fail-closed validator ve dedicated Flutter CI gate eklendi. Gerçek renderer/export, reference asset, TR/EN interactive UI/accessibility ve exact release evidence eksik olduğu için status ceiling IMPLEMENTED tutulur.

## Açık blocker'lar

Independent production golden/reference corpora; exact AKİLES provenance; Panchanga/Vedic promotion açıkları; authoritative Dasha/Varga/Gochara, BaZi relation/strength ve Today runtime providers; rendered TR/EN UI/PDF/share cards; real PDF pagination/font/embed/export; production Calculation Manifest persistence; interpretation/editorial QA; encrypted persistence/key management; tenant/device isolation; real ad/rewarded/PRO verifier; gerçek notification scheduler; offline/airplane-mode; backup round-trip; security/accessibility/performance; clean-checkout/lifecycle ve exact release artifact kapıları açık. RC-0062/0082/0083/0086/0087 açıkları korunuyor.

## Sonraki devam noktası

1. RC-0493→0510, RC-0511→0526, RC-0527→0535, RC-0536→0545, RC-0546→0584 ve RC-0585→0612 dedicated CI sonuçları fiziksel olarak okunacak; kırmızıysa root cause aynı blokta düzeltilecek.
2. Binding sıra **RC-0613+ Hızlı Hesaplama / geçici chart / hızlı numeroloji / son şehir-ayar-preset** hattında ilerleyecek.
3. RC-0342→0371 ve RC-0212→0270, RC-0158→0184, RC-0127→0134, RC-0119→0122/Panchanga promotion açıkları tekrar kontrol edilecek.
4. RC-0124→0126 exact AKİLES provenance bulunmadan AKİLES claim yapılmayacak.
5. RC-0001→1442 tamamı DONE ve bütün release gate'leri green olmadan FINAL denmeyecek.

**FINAL: NO.**