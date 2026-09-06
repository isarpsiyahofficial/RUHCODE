# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- Önceki physical matrix durumları korunur; RC-0002 DONE ve daha önce physical TESTED promotion ile kanıtlanan hatlar geriye düşürülmez.
- **RC-0061 = IMPLEMENTED + blocked=YES**; active house-system name için gerçek product-screen/widget-device evidence açık.
- **RC-0062 = NOT_STARTED/unresolved promotion**; natal-chart dedicated contract/test/CI mevcut fakat physical promotion hâlâ çözülmemiştir ve atlanmış sayılmaz.
- **RC-0080→0081 = TESTED + blocked=YES** (`de9260ea79934c4f9cee912d451e746512d96943`).
- **RC-0082→0083 = NOT_STARTED/blocked**; exact `9588f2dbd9b240721cbb9dffd7fc34306f25c8af` için daha önce görülen Flutter Analyze + requirement-validation failure nedeniyle physical TESTED promotion hâlâ yok.
- **RC-0084→0085 = TESTED + blocked=YES**; physical promotion `b9ef26398e5a7d572680d5e8630a2b4a06add8b2` ile doğrulandı.
- **RC-0086→0087** ve **RC-0088→0089** için production/test/validator/CI zincirleri main üzerinde, fakat bu checkpoint anında physical `record ... TESTED` promotion commit'i bulunamadı; TESTED denmiyor.
- **RC-0090→0091 = IMPLEMENTED + blocked=YES**; production/test/contract/validator/dedicated CI gate `0c5eac7feace1bc8c65b399bc15ee6178abf8a97` ile main'e işlendi. Physical TESTED promotion henüz oluşmadığı için statü yükseltilmedi.

## Bu turdaki gerçek geliştirme

### RC-0090 — Rashi chart

Bağlayıcı madde: `90. Rashi chart oluşturulacak.`

`lib/src/calculation_core/vedic/vedic_rashi_chart.dart` ile independent `VedicCalculationSnapshot` içindeki normalized sidereal Graha longitudes 12 Rashi'ye deterministic olarak eşleniyor. Her placement için `rashiIndex` ve sign içi derece korunuyor; duplicate body, invalid longitude, eksik provenance ve ayanamsha uyuşmazlığı fail-closed. Western calculation katmanına import/delegation yok.

### RC-0091 — Vedik Whole Sign

Bağlayıcı madde: `91. Vedik Whole Sign sistemi uygulanacak.`

Vedik Lagna'nın sidereal Rashi'si 1. ev kabul ediliyor ve her Graha için house assignment exact on-two-sign cycle ile `((rashiIndex - lagnaRashiIndex + 12) % 12) + 1` formülüyle üretiliyor. Aries wrap regression testi dahil edildi. Snapshot ile Lagna'nın ayanamsha id/dataVersion eşleşmesi zorunlu.

### RC-0090→0091 kanıt zinciri

Atomic commit: `0c5eac7feace1bc8c65b399bc15ee6178abf8a97` — `feat(rc0090-rc0091): add Rashi Whole Sign core and gate`

Eklenen kanıtlar:
- production: `lib/src/calculation_core/vedic/vedic_rashi_chart.dart`
- compiled regressions: `test/calculation_core/vedic/vedic_rashi_chart_test.dart`
- binding contract: `requirements/contracts/rc0090_rc0091_rashi_whole_sign_contract.json`
- fail-closed validator: `tools/requirements/validate_rc0090_rc0091_rashi_whole_sign.py`
- dedicated promotion workflow: `.github/workflows/rc0090-rc0091-rashi-whole-sign.yml`

Gate yalnız Python binding/production doğrulaması ve compiled Flutter regressions fiziksel olarak green olduktan sonra RC-0090/0091'i TESTED'e promote edecek. Bu checkpoint'te promotion commit'i henüz oluşmadığı için TESTED ilan edilmedi.

Bu çalışma Varga divisional chartları, yorum/editoryal içerik, rendered UI, entitlement, bağımsız Lagna/Lahiri astronomy golden tolerances, real-device veya release readiness kanıtlamaz; bunlar açık blocker olarak korunur.

## Açık product-facing / global blocker'lar

RC-0042/0044/0046/0048/0049 product-facing açıkları; RC-0061 active house-system UI; RC-0068+ ilgili rendered product UI/interpretation/entitlement kanıtları; independent editorial/astronomy golden evidence; exact AKİLES provenance; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. RC-0090/0091 dedicated CI sonucu okunacak; kırmızıysa exact job/log kök nedeni aynı hat üzerinde düzeltilecek, green ise physical matrix promotion doğrulanacak.
2. RC-0082/0083 kırmızı Flutter Analyze + requirement-validation diagnostic'i çözülüp gate yeniden yeşile getirilecek.
3. RC-0086/0087 ve RC-0088/0089 mevcut gate/promotion durumları fiziksel olarak doğrulanacak; yalnız gerçek bot promotion varsa TESTED kabul edilecek.
4. **RC-0062** unresolved natal-chart promotion tekrar incelenecek; atlanmayacak.
5. Dependency sırasındaki **RC-0092+ Varga** maddeleri bağlayıcı spec ve doğrulanabilir matematikle ilerletilecek; formül veya astronomik sonuç uydurulmayacak.
6. Lahiri/Chitrapaksha numerical doğruluğu için bağımsız provider/golden/tolerance kanıtı ayrı kapı olarak kurulacak.
7. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**
