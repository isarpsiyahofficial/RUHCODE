# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** SOURCE_LEVEL_IMPLEMENTED / IMPLEMENTED, DONE değildir. DONE yalnız gerekli test, golden, cihaz ve release kanıtlarıyla verilir.

## Requirement durumu

- Exact kapsam: `RC-0001 → RC-1442` / **1.442 requirement**.
- `requirements/requirement_state.csv` sparse explicit-override ledger'dır; bu checkpointte değiştirilmedi.
- Kanıtsız DONE/status override eklenmedi.

## Doğrulanmış ana ilerleme

- Calculation, timezone/date, astronomy provider, Western, numerology, BaZi ve Çin astrolojisi çekirdeklerinde source/test altyapısı mevcut.
- Free/PRO guard ve offline entitlement state mevcut.
- 15 tablolu backup/restore, transaction/rollback ve platform file-store katmanları mevcut.
- Professional/combined PDF planning, preview/build parity ve structural validation mevcut.
- UI action/accessibility contracts mevcut; catastrophic restore rollback persistent accessible integrity alarmıdır.
- Daily Message runtime packaged loader ve production Today wiring mevcut.
- TR/EN localization delegates production app'te explicit bağlı.

## Günün Mesajı doğrulanmış kanıtı

- `2026-01-01 → 2036-12-31`.
- TR **4018/4018**, EN **4018/4018**, toplam **8036/8036**; missing/duplicate exact date-locale kaydı 0.
- Earlier exact APK packaging proof (`5283cc2381fbf850f86c85cb458f96a6b8250f45`) yaklaşık 53.2 MB release APK; APK SHA-256 `2720059bf969681f67e119cd7cf1185e41914224613f74dffcd75fc328d63948`.
- RC-1433 rolling-horizon release gate kaynak seviyesinde mevcut; final release tarihine göre strict pass gerekir.

## RC-1436 / RC-1437 astronomy evidence

- GeoNames city catalog physically bundled / `BUNDLED_VERIFIED`: 235,640 records, source/generated SHA evidence, attribution ve Flutter asset binding.
- IERS `finals2000A.all` physically bundled, checksum/version evidence mevcut; runtime loader published UT1-UTC satırlarını parse ediyor ve coverage dışına fail-closed davranıyor.
- JPL/NASA NAIF DE440s SPK physically bundled; exact SHA/byte evidence ve runtime integrity loader mevcut.
- DAF/SPK parser; Type-2 record/ Chebyshev position+velocity evaluator; target/center body graph chaining ve ilgili fail-closed contract testleri mevcut.
- Real packaged DE440s J2000 Type-2 ve Earth(399)→EMB(3)→SSB(0) graph testleri mevcut.
- Raw SPK state tolerance contract: position max `0.001 km` / axis, velocity max `1e-9 km/s` / axis. Bu yalnız raw ephemeris state alt-kapısıdır; RC-1436 kapsamındaki diğer motor toleranslarının yerine geçmez.

### Official independent JPL golden

- `evidence/rc1436/jpl_horizons_earth_ssb_j2000.json` artık fiziksel canonical evidence olarak repository'de.
- Materializer exact NASA/JPL Horizons API query kullanıyor: Earth `399`, SSB `@0`, JD `2451545.0`, TDB, ICRF/FRAME, geometric `VEC_CORR=NONE`, KM-S, VEC_TABLE=2.
- Evidence API signature, request URL, captured time, raw response SHA-256 ve x/y/z/vx/vy/vz state taşıyor.
- Exact `6589c814e179c906f28ea5994c13c70f3dd86958` materializer job logunda official capture, provenance validation ve packaged DE440s comparator PASS doğrulandı.
- İlk workflow commit adımında yeni/untracked evidence dosyasını `git diff --quiet` ile yanlışlıkla unchanged sayan root-cause bulundu.
- `dc0fa9be9019bc16903976f9d1545b0dfb443f38` commit mantığını fail-closed düzeltti.
- `a37b79423d91a964e483b70d569af34e644bdaf4` canonical JPL evidence'ı fiziksel olarak `main`e commit etti.
- `c33a29adefbc04cd129a42eb2f194720a0d4233b` dedicated `RC-1437 Runtime Assets` workflow'una hem packaged IERS provenance/fail-closed testi hem canonical JPL Horizons accuracy testi ekledi. Böylece official golden karşılaştırması artık yalnız materializer'a özgü tek seferlik kontrol değil, kalıcı RC-1437 CI kapısıdır.

**RC-1436 ve RC-1437 bütünüyle DONE değil.** Tek J2000 Earth→SSB vektörü bütün astronomik motorların, tüm tarih aralığının veya tüm bağlayıcı toleransların kanıtı değildir.

## RC-1435 / EOP date-range açığı

- Product hedef aralığı en az `1890 → 2110`.
- Published IERS EOP coverage bu aralığın tamamını kapsamaz.
- Future/unpublished veya historical missing EOP hiçbir şekilde fabricate edilmeyecek.
- Narrower EOP-dependent capability açıkça belirtilmeli ve coverage dışında fake UTC=UT1/substitution yapılmadan fail-closed davranmalıdır.
- 1890→2110 için versioned capability/range policy ve kullanıcıya açık limitation evidence hâlâ release requirement'tır.

## RC-1439 — physical UI reference images

- Reference manifest explicit `NOT_PROVEN`.
- Validator fiziksel dosya, unique screen ID/path, filename ve exact SHA-256 doğruluyor; generated placeholder evidence reddediliyor.

**RC-1439 DONE değil.**

## RC-1442 — clean-checkout release readiness

- Tracked Android host + canonical identity `com.ruhcode.ruh_code` mevcut.
- Gradle 9.1.0 / AGP 9.0.1 / Kotlin 2.3.20 host contract mevcut.
- Release debug keystore ile imzalanmıyor; production signing explicit secret-backed inputs gerektiriyor.
- Verified Gradle wrapper JAR tracked; wrapper SHA-256 `76805e32c009c0cf0dd5d206bddc9fb22ea42e84db904b764f3047de095493f3`.
- Signed clean-checkout workflow fail-closed build/apksigner/provenance hattına sahip.

Açık blockerlar: strict RC-1437 tam PASS değil; RC-1439 tam PASS değil; production-secret signed reproducible artifact actual execution yok; real-device verification eksik.

## Açık ana blocker'lar

- RC-1436 için daha geniş independent official ephemeris golden/tolerance coverage,
- 1890→2110 EOP/versioned capability policy,
- RC-1439 canonical physical reference screenshots/images + hashes,
- secret-backed signed reproducible clean-checkout APK actual execution,
- Daily Message real airplane-mode device lookup proof,
- production Unicode PDF font/license/hash/parser-render/device delivery proof,
- Play/rewarded real-device evidence,
- visual/accessibility real-device regression,
- final exact 1.442-RC lifecycle audit.

## Son checkpoint

`automation_runs/2026-09-03_1452_rc1436_jpl_golden_committed.md`

## Sıradaki çalışma

1. Exact current HEAD full CI completion'ı oku; yeni permanent RC-1437 JPL/EOP gate kırmızıysa aynı turda kök nedeni düzelt.
2. Official ephemeris golden coverage'ı tek J2000 Earth→SSB örneğinin ötesine genişlet ve RC-1436 explicit toleranslarına bağla.
3. 1890→2110 EOP/date-range policy'yi fabrication olmadan uygula ve doğrula.
4. Strict RC-1439 ve diğer bağımsız release blockerlarını ilerlet.
5. Strict prerequisites PASS olduktan sonra production-secret signed clean-checkout artifact'i üret/doğrula.
6. Real-device proof + final 1.442 RC lifecycle audit tamamlanmadan FINAL deme.

**FINAL: NO.**
