# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical requirement durumu

- **RC-0002 = DONE**.
- **RC-0003 = NOT_STARTED** — independent editorial evidence açık.
- **RC-0004 = TESTED + blocked=YES** — independent bilingual editorial review açık.
- **RC-0005 = NOT_STARTED + blocked=YES**, **RC-0006 = TESTED + blocked=YES**, **RC-0007 = NOT_STARTED** — exact AKİLES provenance/comparison blocker'ı açık.
- **RC-0008→RC-0019** — ilgili requirement matrix satırlarında TESTED; independent astronomy/location/release kanıtları açık olanlar blocked=YES.
- **RC-0020 = NOT_STARTED** — real solar-events implementation/contract/CI mevcut; corrected gate'in physical TESTED promotion'ı hâlâ bulunmadı.
- **RC-0021→RC-0024 = TESTED + blocked=YES**.
- **RC-0025 = TESTED + blocked=YES** — physical bot promotion `5d9b1c6cc7c302e8836045fde895e828bd375847`; Chinese engine compiled testteki canonical `CalculationValidity.error` düzeltmesiyle gate başarıyla promotion yaptı.
- **RC-0026 = TESTED + blocked=YES** — physical promotion `5b4083585337774d709f783bfb309bd6d5ed11a2`.
- **RC-0027 = TESTED + blocked=YES** — physical promotion `78e0956aab0989327121eacac33297200d6b7da0`; numerology calculation root'u astroloji engine'lerinden bağımsızlık gate'inden geçti.
- **RC-0028 = NOT_STARTED / corrected rerun pending** — önceki failure Chinese representative regression'daki `CalculationValidity.invalid` kullanımından kaynaklandı ve `3b753102d473d61b3ce016f66378ae4b147b896e` ile düzeltildi. Workflow test path'lerini izlemediği için corrected test commit'i gate'i yeniden tetiklememişti; `9c8c33f1b907aba7ebcec0f4e7b07886174275cb` ile representative test yolları trigger kapsamına eklendi ve exact rerun `33943328752` başlatıldı. SUCCESS + bot promotion olmadan TESTED denmeyecek.
- **RC-0029 = NOT_STARTED / gate running** — bağlayıcı contract `b6d53d9577dda30d3ec28a547a59a11a61345266`; fail-closed validator `2f48d9889c020e7fc4184596d4d578e4031d97da`; dedicated compiled Flutter + matrix-promotion workflow `4fc77a4c70a8b107c2866676d92ae9251363c921`. Gate explicit `TropicalZodiacSign`, 0° Aries/30° Taurus/359.999999° Pisces sınır regresyonları ve Western default calculation path'inde sidereal/ayanamsha offset bulunmamasını zorunlu tutuyor. Physical bot promotion görülmeden TESTED yazılmayacak.

## Bu turdaki gerçek değişiklikler

### RC-0025 / RC-0027 physical promotion doğrulaması

- RC-0025 physical `record Chinese engine TESTED` commit'i `5d9b1c6cc7c302e8836045fde895e828bd375847` doğrulandı.
- RC-0027 physical `record numerology independence TESTED` commit'i `78e0956aab0989327121eacac33297200d6b7da0` doğrulandı.

### RC-0028 rerun zinciri düzeltmesi

- Önceki RC-0028 run `33931388559` failure'dı; representative Chinese test eski invalid enum nedeniyle compile kırıyordu.
- `3b753102d473d61b3ce016f66378ae4b147b896e` canonical `.error` state düzeltmesini içeriyor.
- Workflow yalnız production root'larını izlediği için bu test düzeltmesi RC-0028'i yeniden tetiklememişti.
- `9c8c33f1b907aba7ebcec0f4e7b07886174275cb` ile Western/Vedic/Chinese/BaZi/Numerology representative test path'leri trigger kapsamına eklendi; corrected run `33943328752` physical olarak başladı.

### RC-0029 — Western Tropical default

- Binding requirement: `Batı astrolojisinin varsayılan zodyağı Tropical olacak.`
- Mevcut production `WesternNatalPlacements` explicit `TropicalZodiacSign` kullanıyor ve longitude'u 30° segmentlerle deterministik map ediyor.
- `requirements/contracts/rc0029_western_tropical_default_contract.json`
- `tools/requirements/validate_rc0029_western_tropical_default.py`
- `.github/workflows/rc0029-western-tropical-default.yml`
- Compiled regression `test/calculation_core/western/natal_placements_test.dart` 0°, 30° ve 359.999999° tropical sınırlarını doğruluyor.

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. `requirements/requirement_state.csv`, bu dosya ve `automation_runs/LATEST.md` yeniden okunacak.
2. RC-0028 run `33943328752` sonucu ve physical bot promotion doğrulanacak; failure varsa exact failing step düzeltilip yeniden çalıştırılacak.
3. RC-0029 dedicated gate sonucu ve `requirements(rc0029): record Western Tropical default TESTED` physical commit'i doğrulanacak.
4. RC-0020 corrected solar-events promotion eksikliği tekrar ele alınacak.
5. Ardından dependency sırası RC-0030 (Western Sun/Moon/Ascendant) ve devamı şeklinde ilerletilecek.
6. Yalnız kanıtlanan state yazılacak; 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

Latest detailed checkpoint: `automation_runs/2026-09-05_0700_rc0025_rc0029_progress.md`.

**FINAL: NO.**
