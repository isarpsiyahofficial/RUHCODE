# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. DONE yalnız ilgili test, independent/golden, cihaz ve release kanıtları tamamlandığında verilir.

## Requirement matrix / FAZ 0

- Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.
- Lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır.
- Canonical materializer her RC'yi binding spec filename/number + normalized requirement SHA-256 ile bağlar.
- `TESTED / VERIFIED / DONE` evidence links olmadan matrix validator'dan geçemez; `DONE` blocked olamaz.
- **RC-0002 = DONE**: production runtime language scope yalnız TR/EN ve dedicated static+compiled gate ile doğrulanmış durumda.
- **RC-0003 = NOT_STARTED**: repository-level editorial-independence validator/workflow mevcut; fiziksel promotion olmadığı için statü yükseltilmiyor.
- **RC-0004 = TESTED + blocked=YES**: machine-checkable bilingual terminology/copy-quality gate geçti; independent bilingual editorial review olmadan VERIFIED/DONE yok.
- **RC-0005 = NOT_STARTED + blocked=YES**: exact AKİLES latest source/artifact, immutable version/commit, integrity hash, capture date ve reference scope bulunmadan referans requirement'ı ilerletilmiyor.
- **RC-0006 = TESTED + blocked=YES**: modular Ruh Code calculation core yapısı dedicated gate ile doğrulandı; AKİLES method-level provenance/comparison evidence olmadan VERIFIED/DONE yok.
- **RC-0007 = NOT_STARTED**: AKİLES'te doğrulanmış hesaplama mantıklarının korunması şartı, RC-0005/0006 exact provenance/comparison blocker'ına bağlı; kanıtsız promotion yok.
- **RC-0008 = TESTED + blocked=YES**: calculation-core time/date çözümleme explicit UTC/wall-clock + IANA zone girdileriyle deterministik; end-to-end location→astronomy propagation kanıtı açık.
- **RC-0009 = TESTED**: bundled IANA tzdb runtime sözleşmesi ve historical timezone regression gate'i geçti.
- **RC-0010 = TESTED**: DST fold/gap ve tarihsel discontinuity politikaları dedicated runtime testlerle doğrulandı.
- **RC-0011 = TESTED + blocked=YES**: city records coordinate ve IANA timezone'u ayrı doğrulanabilir alanlar olarak taşıyor; end-to-end doğum yeri seçimi propagasyonu açık.
- **RC-0012 = TESTED + blocked=YES**: same-name city stable identity + admin/country disambiguation compiled regression ile doğrulandı; end-to-end seçim kanıtı açık.
- **RC-0013 = TESTED + blocked=YES**: packaged DE440s ortak astronomi çekirdeği; physical loader + DAF parser + SPK Type-2 + body graph + compiled JPL accuracy regressions dedicated gate'te SUCCESS. RC-0014→0016 ve broader golden/tolerance coverage açık.
- **RC-0014 → RC-0016 = NOT_STARTED**: gerçek gökcismi konumu / lunar-node / motion-state requirements interface veya enum varlığına bakılarak kanıtsız yükseltilmedi.
- **RC-0017 = TESTED + blocked=YES**: merkezi Julian Day/MJD/J2000 dönüşüm çekirdeği USNO/J2000 reference regressions ile requirement-specific gate'te doğrulandı; daha geniş astronomical timescale/release evidence açık.

## RC-0003 — bağımsız TR/EN içerik

- `assets/content/daily_messages/tr/` ve `.../en/` ayrı fiziksel kataloglardır.
- `tools/requirements/validate_rc0003_editorial_independence.py` date coverage, paired-copy non-identity, physical digest separation ve known automatic TR→EN translation pipeline yasağını fail-closed doğrular.
- Legacy/current CSV şemaları ve monthly/annual shard reconciliation desteklenir; overlapping annual/monthly içerik uyuşmazsa gate kırılır.
- `.github/workflows/rc0003-editorial-independence.yml` shared `requirement-matrix-writers` concurrency group kullanır ve human editorial provenance blocker'ını kaydeder.
- Matrix promotion fiziksel görülmeden RC-0003 TESTED/VERIFIED/DONE sayılmaz.

## RC-0004 — doğal/profesyonel terminoloji

- `requirements/contracts/rc0004_terminology_contract.json` sürümlü canonical TR/EN terminology sözleşmesidir.
- `tools/requirements/validate_rc0004_content_quality.py` UTF-8/NFC/placeholder/mojibake/template-key copy hygiene kontrollerini fail-closed uygular.
- Physical promotion commit: `a9823f7a022f553359405d9e772222e9b8e27e50`.
- Independent bilingual review gerekir.

## RC-0005 / RC-0006 / RC-0007 — AKİLES referansı ve yeni modüler çekirdek

- RC-0005 blocker contract repository'de ve matrix'te fiziksel olarak kayıtlıdır; exact AKİLES provenance bulunmadan latest-reference iddiası yapılmaz.
- RC-0006 için `requirements/contracts/rc0006_modular_core_contract.json`, `tools/requirements/validate_rc0006_modular_core.py` ve `.github/workflows/rc0006-modular-core.yml` eklendi.
- Gate `lib/src/calculation_core/` domain modüllerini, `CalculationEngine` abstraction'ını, interpretation sınırını ve doğrudan AKİLES package/dependency marker'ı bulunmamasını doğrular.
- Implementation commit: `1081e5924be05f544cbf68629d1069cc6ce8baa3`.
- Physical CI promotion commit: `faa13b47260a012a0181f9f0d02170e9133f8833` (`requirements(rc0006): record modular core TESTED`).
- RC-0006/0007 full requirement proven değildir; RC-0005 exact source/version/hash + method-level transfer/comparison provenance required.

## RC-0008 / RC-0009 / RC-0010 — deterministik zaman ve tarihsel timezone

- `requirements/contracts/rc0008_rc0010_time_determinism_contract.json` explicit time/IANA/DST contract'tır.
- `tools/requirements/validate_rc0008_rc0010_time_determinism.py` calculation-core time modülünde `DateTime.now()` kullanımını yasaklar; explicit UTC instant, IANA zone, cache partition, bundled tzdb ve DST/history marker'larını doğrular.
- `.github/workflows/rc0008-rc0010-time-determinism.yml` Flutter 3.44.7 ile `time_zone_runtime_test.dart` + `daily_date_context_test.dart` çalıştırır.
- Regression kapsamı New York DST fold/gap, Pacific/Apia 2011 skipped day, Kolkata/Kathmandu fractional offsets ve Kiritimati UTC+14 boundary içerir.
- Workflow commit: `069b427e4d793c851e95e1f13d7c6718d02e68f1`.
- Physical matrix promotion görüldü: RC-0008/0009/0010 = TESTED. RC-0008 yalnız end-to-end coordinate/location + timezone propagation nedeniyle blocked=YES.

## RC-0011 / RC-0012 — konum kimliği, koordinat/timezone ve disambiguation

- `CityRecord` stable id, country/admin identity, latitude, longitude ve IANA timezone'u ayrı alanlar olarak taşır.
- Regression suite aynı isimli Springfield kayıtlarını Illinois/Massachusetts olarak ayrı stable id + ayrı timezone ile korur; visible `disambiguationLabel` kullanılır.
- `requirements/contracts/rc0011_rc0012_location_identity_contract.json`, `tools/requirements/validate_rc0011_rc0012_location_identity.py`, `.github/workflows/rc0011-rc0012-location-identity.yml` eklendi.
- Gate physical city catalog validator + requirement validator + compiled Flutter city testini zincirler.
- Commits: `f38a5c96ec4272cf9d68a01ed9406e9439d1e4e0`, `6402aad9eb059e9d34b697c6ba9eac8cf7837969`, `2e69ecd906e16d4224350cfbe963837d3e872816`.
- Physical matrix promotion görüldü: RC-0011/0012 = TESTED + blocked=YES.
- End-to-end birth-place selection stable identity + coordinate + IANA timezone propagation kanıtı olmadan VERIFIED/DONE yok.

## RC-0013 — ortak astronomik hesaplama çekirdeği

- Binding requirement: `Uygulamanın ortak bir astronomik hesaplama çekirdeği olacak.`
- `requirements/contracts/rc0013_common_astronomy_core_contract.json` interface-only kanıtı yetersiz sayar; packaged/offline/versioned/fail-closed çekirdek zorunludur.
- `tools/requirements/validate_rc0013_common_astronomy_core.py` physical runtime bileşenlerini ve shared ephemeris contract'ı fail-closed doğrular.
- `.github/workflows/rc0013-common-astronomy-core.yml` Flutter 3.44.7 ile ephemeris contract, packaged DE440s loader/parser, SPK Type-2, body-graph ve JPL Horizons accuracy regression dosyalarını çalıştırır.
- Dedicated CI run `33851109923` tüm adımları SUCCESS tamamladı.
- Contract commit: `a7c8c06c5321262f9f9a59e7cbcbff54d297bb19`.
- CI gate commit: `92254e5552373a4fa7537c93fd0ce81c2235445d`.
- Physical promotion commit: `f219bf02c1c802df626e889876234f96c4296151` (`requirements(rc0013): record common astronomy core TESTED`).
- RC-0013 VERIFIED/DONE değildir; RC-0014→0016 real output coverage ve broader independent golden/tolerance evidence açık.

## RC-0017 — merkezi Julian Day / astronomik zaman temeli

- Existing `lib/src/calculation_core/time/julian_day.dart` merkezi `JulianDay` çekirdeği fromUtc/fromCivilDate/MJD/J2000 centuries dönüşümlerini içerir ve non-UTC DateTime girdisini reddeder.
- Existing `requirements/reference_sources/julian_day.json` U.S. Naval Observatory reference değerlerini ve J2000 epoch'u kayıt altında tutar.
- Added `requirements/contracts/rc0017_julian_time_core_contract.json`, `tools/requirements/validate_rc0017_julian_time_core.py`, `.github/workflows/rc0017-julian-time-core.yml`.
- Dedicated gate existing USNO validator + compiled `test/calculation_core/julian_day_test.dart` regressions çalıştırır.
- Workflow commit: `d4251b26efcfc7fdce499554d0b0d3d517aac9b9`.
- Physical promotion commit: `4da48b2530b4c83de2645dc8dfee78a0c801f8bf` (`requirements(rc0017): record Julian time core TESTED`).
- RC-0017 = TESTED + blocked=YES; daha geniş astronomical timescale accuracy/release evidence olmadan VERIFIED/DONE yok.

## Doğrulanmış ana teknik altyapı

- Calculation/timezone/date, astronomy provider contract, Western, numerology, BaZi ve Çin astrolojisi source/test katmanları mevcut.
- Free/PRO guard ve offline entitlement state mevcut.
- 15 tablolu backup/restore, transaction/rollback ve platform file-store katmanları mevcut.
- Professional/combined PDF planning, preview/build parity ve structural validation mevcut.
- UI action/accessibility contracts mevcut; catastrophic restore rollback persistent accessible integrity alarmıdır.
- Daily Message packaged loader/Today wiring ve TR/EN localization delegates production app'te bağlı.

## RC-1436 / RC-1437 astronomy evidence

- GeoNames physical catalog ve IERS `finals2000A.all` physical asset/provenance katmanları mevcut.
- Product date capability `1890-01-01` inclusive → `2111-01-01` exclusive; published EOP coverage dışı UT1-dependent hesaplar fail-closed.
- DE440s SPK bundled; DAF/SPK Type-2 evaluator, body/center graph chaining ve physical packaged-kernel testleri mevcut.
- Raw state tolerance alt-kapısı position `0.001 km/axis`, velocity `1e-9 km/s/axis`.
- Canonical official JPL Earth→SSB J2000 evidence repository'de mevcut.
- Multi-vector Horizons ve diğer astronomy-engine tolerance kanıtları tamamlanmadan RC-1436/1437 DONE değil.

## RC-1439 / release açık kapıları

- RC-1439 physical canonical UI reference images/hashes henüz tam kanıtlanmış değil.
- Secret-backed signed reproducible clean-checkout release artifact exact execution açık.
- Daily Message airplane-mode real-device proof, production Unicode PDF font/render/device proof, Play/rewarded real-device proof ve visual/accessibility device regression açık.
- Final exact 1.442-RC lifecycle audit açık.

## Açık blocker'lar

- RC-0003: independent editorial provenance/review + fiziksel TESTED promotion.
- RC-0004: independent bilingual editorial review.
- RC-0005: AKİLES exact latest source/version/hash provenance.
- RC-0006/0007: RC-0005 provenance + method-level comparison/transfer evidence.
- RC-0008: end-to-end astronomical calculation input propagation (validated location coordinates + explicit date/timezone).
- RC-0011/0012: end-to-end birth-place selection/runtime propagation evidence.
- RC-0013: RC-0014→0016 real output coverage + broader astronomy golden/tolerance evidence.
- RC-0017: broader astronomical timescale accuracy/release evidence.
- RC-1436/1437 geniş independent astronomy golden/tolerance coverage.
- RC-1439 physical UI references.
- Signed reproducible artifact ve real-device release kanıtları.

## Son checkpoint

`automation_runs/2026-09-04_1100_rc0013_common_astronomy_core.md`

## Sıradaki çalışma

1. RC-0014 packaged DE440s body mapping + production provider/output katmanını compiled + independent golden evidence ile ilerlet.
2. RC-0015 lunar-node ve RC-0016 motion/retrograde hesaplarını ayrı executable/golden gates olarak ilerlet; enum/interface-only evidence kabul etme.
3. RC-0007 AKİLES provenance blocker'ını korurken bağımsız requirement'ları dependency sırasıyla ilerlet.
4. RC-0003 promotion zincirini ve independent editorial blocker'ı tekrar ele al.
5. RC-1436/1437, RC-1439, signed clean-checkout ve real-device kapılarını bağımsız ilerlet.
6. 1.442 RC tamamı DONE ve final release artifact exact doğrulanmadan FINAL deme.

**FINAL: NO.**
