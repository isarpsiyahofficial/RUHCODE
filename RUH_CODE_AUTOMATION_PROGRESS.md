# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** `IMPLEMENTED`, `DONE` değildir. `DONE` yalnız requirement-specific kanıt ile; calculation/interpretation/UI/TR-EN/offline/Free-PRO/backup/PDF/security/accessibility/performance/clean-checkout/lifecycle/device ve exact-release kapıları gereken kapsamda yeşil olduğunda verilir. Canonical lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; exact kapsam `RC-0001→RC-1442`, toplam **1.442 requirement**.

## Canonical durum özeti

- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0950 implementation/matrix zincirleri mevcut; global golden/device/PDF/backup blocker'ları nedeniyle DONE değil.
- RC-0951→0964 = IMPLEMENTED + blocked=YES (`5f08942462a0b3784725b9fd7e65de0cc22eb50e`).
- RC-0965→0994 traceability release-mode fail-closed; 1.442 requirement doğrudan evidence ile kapanmış değil.
- RC-0995→1003 authoritative golden contract mevcut; exact AKİLES provenance/independent values eksik.
- RC-1004→1039 = IMPLEMENTED + blocked=YES (`fb71d1b9703f35a4dec499e7d7de33151d57a75e`).
- RC-1040→1058 = IMPLEMENTED + blocked=YES (`d96a3b5c1821d81739b491757795cfced5ba040a`).
- RC-1059→1084 = IMPLEMENTED + blocked=YES (`ed87a5c385425a0c3e7f59f7f884c8dc55cab8f6`).
- RC-1085→1104 = IMPLEMENTED + blocked=YES (`a9c4b832269328935dbf6d4753f603d17fa5b1f7`).
- RC-1105→1130 dependency/offline governance mevcut; `pubspec.lock` fiziksel.
- Stacked PR zinciri #1→#15 mevcut; son doğrulamada RC-1304→1344 ve RC-1375→1404 dedicated gate'leri SUCCESS verdi.
- RC-1405→1420 dedicated gate exact contract'ı geçti fakat local evidence contract'ındaki üç yanlış path yüzünden kırmızıydı. Gerçek production path'leri `lib/src/data/`, `lib/src/data/professional_search.dart`, `lib/src/application/engagement_policy.dart` olarak düzeltildi (`84beece28885e804f1f84b0e62724f24280a66de`). Yeni CI sonucu bekleniyor.

## RC-1421→1442 — bağlayıcı son ek / final release closure

Branch: `agent/rc1421-rc1442-release-closure` (PR açılacak / PR #15 üzerine stacked).

### Gerçek production geliştirmesi

`lib/src/application/daily/today_temporal_contract.dart` eklendi (`51c0ab57bdbdd2a5c8880162b3315b2f1ea79d2f`).

- `TodayTemporalContext`: aktif local date/time + explicit IANA timezone + opsiyonel fakat eşleşmiş lat/lon ister; ambient/random zaman kaynağı kullanmaz.
- `GregorianCalendarPolicy`: weekday'i Gregorian motorundan hesaplar; artık yıl kuralı `400` / `100` / `4` ayrımını uygular ve geçersiz 29 Şubat'ı reddeder.
- `RuhSupportedDateRange`: merkezi hedef aralığı `1890→2110`; aralık dışında sahte sonuç yerine fail-closed hata.
- `StockDailyMessage` ve `PersonalTodayEffects` ayrı veri tipleridir; `TodayContentBundle` stok editoryal mesajı kişisel calculation çıktısıyla birleştirirken aynı date key'i zorunlu tutar. Runtime AI/random fallback yüzeyi yoktur.

Regression `test/application/today_temporal_contract_rc1421_rc1435_test.dart` (`eecc3d8b98dca47f3b902f50f5f10b2c18faf31c`) 2026-08-16 / 2027-08-16 weekday bağımsızlığını, 2028/2100/2000 leap-year sınırlarını, explicit timezone/location kuralını, stok/personal ayrımını, yanlış date-key fallback yasağını ve 1890–2110 fail-closed aralığını test eder.

### Exact requirement binding ve CI

`requirements/contracts/rc1421_rc1442_release_closure_contract.json` (`43c2434e291159b6fdb48526711a5913cb10035d`) RC-1421→1442'yi tek tek, exact sırada mevcut production/test/manifest/validator evidence path'lerine bağlar. Hiçbir RC birleştirilmez veya atlanmaz.

`tools/requirements/validate_rc1421_rc1442_release_closure.py` (`a722eb561d870e44edff6ce49edbead03921d9b3`) fail-closed olarak şunları denetler:

- exact ordered RC-1421→1442 evidence map;
- Today/Gregorian/leap/date-range/content-separation production tokenları;
- günlük mesaj `YYYY-MM-DD|locale`, TR/EN, 2026–2036, 4.018 gün / 8.036 kayıt, >=10 yıl rolling horizon, runtime-AI/random/machine-translation yasağı;
- measurable astronomy accuracy budget alanları;
- RC-1439 physical reference-image status;
- canonical `Bugün · Araçlar · Kayıtlar · Profil` ve action registry; `Hesapla` bottom-nav yasağı; Semantics + 48dp floor;
- mevcut daily-message / accuracy / reference-image / 1.442-row matrix specialist validator'larının gerçekten çalışması.

`.github/workflows/rc1421-rc1442-release-closure.yml` (`982c3387470d852407741a443ec1d28f70585348`) Flutter 3.44.7 ile production regression'ı, structural validator'ları ve 1.442-row matrix'i çalıştırır. Ayrıca mevcut blocker'lar varken `--release` modunun **başarısız olmasını** özellikle kanıtlar; main push'ta ancak structural + regression yeşilse RC-1421→1442'yi en fazla `IMPLEMENTED + blocked=YES` seviyesine promotion eder. TESTED/VERIFIED/DONE otomatik verilmez.

### Fiziksel blocker doğrulamaları

- Günlük mesaj manifesti 2026-01-01→2036-12-31, 4.018 gün / 8.036 TR+EN kayıt, rolling 10 yıl ve runtime AI/random fallback yasağını taşıyor; ancak lifecycle status hâlâ `EDITORIAL_CONTENT_COMPLETE_PENDING_RELEASE_AUDIT`. Bu nedenle RC-1425/1426/1433/1434 release-DONE değildir.
- `astronomy_accuracy_budgets.json` Sun/Moon/planet/ASC/MC/cusp/sunrise-sunset/planetary-hour/Nakshatra/Pada için ölçülebilir toleransları tanımlıyor ancak `proven=false`. RC-1436 DONE değildir.
- `requirements/reference_manifests/rc1439_reference_images.json` status `NOT_PROVEN`, `images=[]`. RC-1431/1439 ve reference-dependent final UI gate'leri açık.
- RC-1437 için materialize city/de440s/EOP workflow'ları mevcut fakat exact packaged/version/checksum/offline/legal release evidence bütünü kapanmış değil.
- RC-1442 exact clean-checkout artifact, tested commit SHA ve artifact SHA eşleşmesi tüm 1.442 RC DONE/unblocked olmadan kapanamaz.

## Açık kritik blocker'lar

Exact AKİLES provenance; independent authoritative calculation goldens; Panchanga/Vedic ve Dasha/Varga/Gochara/BaZi providers; historical timezone/DST/polar goldens; rendered TR/EN UI/PDF; günlük mesaj exact release audit; physical UI reference images; approved static visual-source inventory; EOP/DE440s/package license evidence; encrypted persistence/key management/migrations; real ad/rewarded/PRO verifier; full airplane-mode production instrumentation; security/accessibility/performance; branch/review governance; remaining Flutter analyzer/test failures; clean-checkout/lifecycle; exact final release artifact.

## Sonraki devam noktası

1. RC-1421→1442 PR/dedicated CI sonucunu fiziksel doğrula; structural/test kırmızısı varsa aynı hatta kök nedeni kapat.
2. RC-1405→1420 yeni downstream CI'nin üç evidence-path düzeltmesiyle yeşile döndüğünü doğrula.
3. Günlük mesaj release-audit, RC-1436 independent accuracy goldens, RC-1439 physical reference images ve RC-1437 packaged dataset/license zincirlerini bağımsız ilerlet; bunlar release closure'ın açık ana blocker'larıdır.
4. RC-1345→1361 ve RC-1362→1374 kırmızılarını tekrar açıp kalan gerçek kök nedenleri kapat.
5. RC-0001→RC-1442 tamamı DONE, bütün release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**
