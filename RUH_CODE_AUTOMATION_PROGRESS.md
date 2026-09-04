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

## RC-0005 / RC-0006 — AKİLES referansı ve yeni modüler çekirdek

- RC-0005 blocker contract repository'de ve matrix'te fiziksel olarak kayıtlıdır; exact AKİLES provenance bulunmadan latest-reference iddiası yapılmaz.
- RC-0006 için `requirements/contracts/rc0006_modular_core_contract.json`, `tools/requirements/validate_rc0006_modular_core.py` ve `.github/workflows/rc0006-modular-core.yml` eklendi.
- Gate `lib/src/calculation_core/` domain modüllerini, `CalculationEngine` abstraction'ını, interpretation sınırını ve doğrudan AKİLES package/dependency marker'ı bulunmamasını doğrular.
- Implementation commit: `1081e5924be05f544cbf68629d1069cc6ce8baa3`.
- Physical CI promotion commit: `faa13b47260a012a0181f9f0d02170e9133f8833` (`requirements(rc0006): record modular core TESTED`).
- RC-0006 full requirement proven değildir; RC-0005 exact source/version/hash + method-level transfer/comparison provenance required.

## Doğrulanmış ana teknik altyapı

- Calculation/timezone/date, astronomy provider, Western, numerology, BaZi ve Çin astrolojisi source/test katmanları mevcut.
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
- RC-0006: RC-0005 provenance + method-level comparison/transfer evidence.
- RC-1436/1437 geniş independent astronomy golden/tolerance coverage.
- RC-1439 physical UI references.
- Signed reproducible artifact ve real-device release kanıtları.

## Son checkpoint

`automation_runs/2026-09-04_0654_rc0005_rc0006_progress.md`

## Sıradaki çalışma

1. RC-0003 workflow/promotion zincirini fiziksel sonuçla yeniden doğrula; kırmızıysa kök nedeni düzelt.
2. RC-0005 exact AKİLES provenance ara; yoksa blocker'ı koru.
3. Blocker dışındaki RC-0007+ maddeleri dependency sırasıyla gerçekten uygula/test et.
4. RC-1436/1437, RC-1439, signed clean-checkout ve real-device kapılarını bağımsız ilerlet.
5. 1.442 RC tamamı DONE ve final release artifact exact doğrulanmadan FINAL deme.

**FINAL: NO.**
