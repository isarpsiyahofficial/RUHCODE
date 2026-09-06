# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- Önceki physical matrix durumları korunur; RC-0002 DONE, RC-0031→0035/0052→0060 ve RC-0063→0079 arasındaki daha önce TESTED olarak kanıtlanmış hatlar geriye düşürülmez.
- **RC-0061 = IMPLEMENTED + blocked=YES**; active house-system name için gerçek product-screen/widget-device evidence açık.
- **RC-0062 = NOT_STARTED**; natal-chart dedicated contract/test/CI mevcut fakat physical promotion unresolved ve atlanmış sayılmıyor.
- **RC-0080→0081 = TESTED + blocked=YES** (`de9260ea79934c4f9cee912d451e746512d96943`). Independent Vedic engine physical matrix promotion doğrulandı.
- **RC-0082→0083 = IMPLEMENTED + blocked=YES** (`9588f2dbd9b240721cbb9dffd7fc34306f25c8af`). Production seçim mimarisi, compiled regression, binding contract, fail-closed validator ve dedicated CI gate main üzerinde; physical workflow/promotion henüz görünmediği için TESTED denmiyor.

## Bu turdaki gerçek geliştirme

### RC-0080 → RC-0081 — physical TESTED doğrulandı

`requirements(rc0080-rc0081): record independent Vedic engine TESTED` bot promotion commit'i fiziksel olarak doğrulandı: `de9260ea79934c4f9cee912d451e746512d96943`. Western calculation katmanından bağımsız Vedic engine artık matrix'te TESTED; numerical astronomy goldens, downstream Vedic modules, UI/device/release kapıları nedeniyle VERIFIED/DONE değil.

### RC-0082 → RC-0083 — ayanamsha default/seçim mimarisi

Bağlayıcı maddeler:
- RC-0082 — `Vedik varsayılan ayanamsha Lahiri/Chitrapaksha olacak.`
- RC-0083 — `Gerekirse ileride farklı ayanamsha seçenekleri profesyonel ayarlara eklenebilecek.`

Commit `9588f2dbd9b240721cbb9dffd7fc34306f25c8af` ile:
- `VedicAyanamshaCatalog` eklendi; canonical default id `lahiri-chitrapaksha`.
- Catalog Lahiri/Chitrapaksha provider bulunmadan kurulamaz; null/blank seçim default'a gider; unknown id, duplicate id ve eksik provenance fail-closed.
- Ek versioned ayanamsha provider'ları engine değiştirilmeden explicit seçilebilir.
- `ConfiguredVedicCalculation` seçimi catalog üzerinden bağımsız `VedicCalculationEngine`e yönlendirir; Western calculation import/dependency yoktur.
- Compiled regressions default seçim, alternatif seçim, missing-default, duplicate/unknown-id durumlarını kapsar.
- Exact requirement contract, fail-closed validator ve dedicated Flutter CI/matrix promotion workflow eklendi.

Bu çalışma **Lahiri'nin numerik astronomik değerlerini doğrulanmış saymaz**. Independent Lahiri/Chitrapaksha numerical provider/golden/tolerance evidence, professional settings UI/entitlement evidence, downstream Lagna/Graha modülleri ve release/device gates açık blocker olarak korunur.

Son kontrolde commit `9588f2db…` için workflow-run görünürlüğü henüz oluşmamış ve `requirements(rc0082-rc0083): record Vedic ayanamsha selection TESTED` promotion commit'i bulunmamıştı. Bu nedenle RC-0082/0083 TESTED'e yükseltilmedi.

## Açık product-facing / global blocker'lar

RC-0042/0044/0046/0048/0049 product-facing açıkları; RC-0061 active house-system UI; RC-0068+ ilgili rendered product UI/interpretation/entitlement kanıtları; independent editorial/astronomy golden evidence; exact AKİLES provenance; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. RC-0082/0083 dedicated CI ve physical matrix promotion okunacak; kırmızıysa exact job/log kök nedeni düzeltilecek.
2. **RC-0062** unresolved natal-chart promotion tekrar incelenecek; atlanmayacak.
3. Dependency sırasıyla **RC-0084 Vedik Lagna → RC-0085+** ilerletilecek; astronomik hesap uydurulmayacak.
4. Lahiri/Chitrapaksha numerical doğruluğu için bağımsız provider/golden/tolerance kanıtı ayrı kapı olarak kurulacak.
5. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Checkpoint: `automation_runs/2026-09-06_0653_rc0080_rc0083_progress.md`.

**FINAL: NO.**
