# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. DONE yalnız gerekli test, independent/golden, cihaz ve release kanıtlarıyla verilir.

## Requirement durumu / FAZ 0

- Exact kapsam: `RC-0001 → RC-1442` / **1.442 requirement**.
- Bağlayıcı lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE` olarak enforce ediliyor.
- Blocker lifecycle statüsünden ayrıdır: `blocked=YES/NO` ve açıklama ayrı alanlarda tutulur.
- Canonical materializer her RC'yi binding specification filename/number + normalized requirement text SHA-256 ile bağlar; şartname drift'i stale matrix'i fail-closed kırar.
- Her RC en az bir `TASK-*` ID, impact tag ve zorunlu `evidence_type` taşır.
- `TESTED`, `VERIFIED` veya `DONE` evidence link olmadan CI'dan geçemez; `DONE` blocked olamaz.
- Canonical matrix fiziksel olarak 1.442 RC satırını tutuyor.
- **RC-0002 fiziksel matrix üzerinde DONE**: production runtime language scope yalnız `tr/en`, Flutter localization delegate wiring ve packaged language scope dedicated static+compiled CI ile doğrulandı.
- **RC-0003 çalışma altında**: TR/EN içeriklerin bağımsız hazırlanması / otomatik TR→EN çeviri pipeline yasağı için dedicated fail-closed validator + CI eklendi. Bu kapı editoryal provenance olmadan VERIFIED/DONE vermez; otomatik olarak en fazla TESTED seviyesine çıkar.

## RC-0003 — editorial independence kanıt hattı

- Physical Daily Message katalogları ayrı `assets/content/daily_messages/tr/` ve `.../en/` ağaçlarında tutuluyor.
- Validator paired TR/EN title/teaser/body değerlerinin normalize edilmiş biçimde aynı olmamasını, physical catalog digestlerinin farklı olmasını, known machine-translation dependency/API bulunmamasını ve explicit TR-source→EN-destination translation automation bulunmamasını zorunlu tutuyor.
- Production katalogda iki tarihsel CSV şeması bulunuyor ve validator bunları tek canonical modele normalize ediyor:
  - legacy: `date,title,teaser,message,theme`
  - current: `date,locale,title,teaser,full_text,theme_tag`
- Katalog ayrıca hem `YYYY-MM.csv` aylık hem `YYYY.csv` yıllık shard kullanıyor. Monthly shard primary; annual shard yalnız aylıkta bulunmayan tarihi doldurabilir. Aynı tarih iki shard'da varsa canonical içerik birebir eşleşmezse fail-closed.
- İlk CI failure legacy schema varsayımından kaynaklandı ve düzeltildi.
- İkinci CI failure yalnız aylık shardların sayılmasından kaynaklandı: 3.959 günlük kayıt bulundu; eksik görünen 59 gün 2026 Ocak+Şubat kayıtlarının yıllık `2026.csv` shardında tutulmasından kaynaklanıyordu. Annual-shard reconciliation eklendi.
- Son validator commit: `3c4c4e7d53d4ab2582f7af8a53b444fd1eb9a937`.
- Bu exact SHA için yeni CI tetiklendi; son gözlemde tamamlanmış RC-0003 sonucu henüz yoktu, bu nedenle green veya TESTED varsayılmıyor.

## Doğrulanmış ana ilerleme

- Calculation, timezone/date, astronomy provider, Western, numerology, BaZi ve Çin astrolojisi çekirdeklerinde source/test altyapısı mevcut.
- Free/PRO guard ve offline entitlement state mevcut.
- 15 tablolu backup/restore, transaction/rollback ve platform file-store katmanları mevcut.
- Professional/combined PDF planning, preview/build parity ve structural validation mevcut.
- UI action/accessibility contracts mevcut; catastrophic restore rollback persistent accessible integrity alarmıdır.
- Daily Message runtime packaged loader ve production Today wiring mevcut.
- TR/EN localization delegates production app'te explicit bağlı.

## Günün Mesajı doğrulanmış kanıtı

- Ürün kataloğu hedef/kapsamı `2026-01-01 → 2036-12-31`.
- Daha önceki catalog contract kanıtı TR **4018/4018**, EN **4018/4018**, toplam **8036/8036**; missing/duplicate exact date-locale kaydı 0 olarak kaydedildi.
- Earlier exact APK packaging proof (`5283cc2381fbf850f86c85cb458f96a6b8250f45`) yaklaşık 53.2 MB release APK; APK SHA-256 `2720059bf969681f67e119cd7cf1185e41914224613f74dffcd75fc328d63948`.
- RC-1433 rolling-horizon release gate kaynak seviyesinde mevcut; final release tarihine göre strict pass gerekir.

## RC-1436 / RC-1437 astronomy evidence

- GeoNames city catalog physically bundled / `BUNDLED_VERIFIED`: 235,640 records, source/generated SHA evidence, attribution ve Flutter asset binding.
- IERS `finals2000A.all` physically bundled; runtime loader exact SHA/version doğruluyor, published UT1-UTC satırlarını parse ediyor ve physical coverage dışına fail-closed davranıyor.
- Earth-orientation manifestindeki eski `pendingRuntimeData: NOT_DONE` durumu fiziksel kanıtla hizalandı: `BUNDLED_VERIFIED_SUBGATE`; `fullRc1437Done=false` korunuyor.
- Product date range explicit capability policy: `1890-01-01` inclusive → `2111-01-01` exclusive. Ürün aralığında fakat published IERS EOP coverage dışında kalan UT1-dependent hesaplar `EOP_OUTSIDE_PUBLISHED_COVERAGE` ile fail-closed; UTC-for-UT1 substitution, nearest-neighbour, extrapolation ve fabricated future EOP yasak.
- EOP validator fiziksel `assets/data/eop/finals2000A.all` için 3,763,572 byte ve SHA-256 `e3905ff7a74b791744704aa3e900a2161e96db97a30095d8fc442b04e4cfe058` değerlerini manifest/runtime loader ile çapraz doğruluyor.
- JPL/NASA NAIF DE440s SPK physically bundled; exact SHA/byte evidence ve runtime integrity loader mevcut.
- DAF/SPK parser; Type-2 record/Chebyshev position+velocity evaluator; target/center body graph chaining ve ilgili fail-closed contract testleri mevcut.
- Real packaged DE440s J2000 Type-2 ve Earth(399)→EMB(3)→SSB(0) graph testleri mevcut.
- Raw SPK state tolerance contract: position max `0.001 km` / axis, velocity max `1e-9 km/s` / axis. Bu yalnız raw ephemeris state alt-kapısıdır; RC-1436 kapsamındaki diğer motor toleranslarının yerine geçmez.

### Official independent JPL golden

- `evidence/rc1436/jpl_horizons_earth_ssb_j2000.json` fiziksel canonical evidence olarak repository'de.
- Materializer exact NASA/JPL Horizons API query kullanıyor: Earth `399`, SSB `@0`, JD `2451545.0`, TDB, ICRF/FRAME, geometric `VEC_CORR=NONE`, KM-S, VEC_TABLE=2.
- Evidence API signature, request URL, captured time, raw response SHA-256 ve x/y/z/vx/vy/vz state taşıyor.
- Packaged DE440s comparator mevcut raw-state tolerance contract altında PASS kanıtına sahip.
- Multi-vector Horizons materializer/test altyapısı (Earth 1900/J2000/2100, Sun J2000, Moon J2000) mevcut; canonical `evidence/rc1436/jpl_horizons_de440s_coverage.json` son kontrolde henüz repository'de fiziksel olarak yoktu.

**RC-1436 ve RC-1437 bütünüyle DONE değil.** Tek J2000 Earth→SSB vektörü bütün astronomik motorların, tüm tarih aralığının veya tüm bağlayıcı toleransların kanıtı değildir.

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

## Açık ana blocker'lar

- RC-0003 independent editorial provenance/review (repository contract TESTED olabilir ama provenance olmadan DONE değil),
- RC-0001 ve RC-0004 sonrası requirement reconciliation / dependency sırası,
- RC-1436 için daha geniş independent official ephemeris golden/tolerance coverage,
- RC-1439 canonical physical reference screenshots/images + hashes,
- secret-backed signed reproducible clean-checkout APK actual execution,
- Daily Message real airplane-mode device lookup proof,
- production Unicode PDF font/license/hash/parser-render/device delivery proof,
- Play/rewarded real-device evidence,
- visual/accessibility real-device regression,
- final exact 1.442-RC lifecycle audit.

## Son checkpoint

`automation_runs/2026-09-04_0252_rc0003_editorial_independence.md`

## Sıradaki çalışma

1. `3c4c4e7d...` exact RC-0003 CI sonucunu doğrula; kırmızıysa decoded log kök nedenini aynı dependency üzerinde düzelt.
2. Green ise bot-persisted RC-0003 `TESTED` matrix satırını fiziksel doğrula.
3. Independent editorial provenance/review kanıtını oluşturmadan RC-0003 VERIFIED/DONE yapma.
4. RC-0004 professional/natural terminology contract ve bağımsız uygulanabilir RC işlerine devam et.
5. RC-1436/1437, RC-1439, signed reproducible release ve real-device kapılarını bağımsız işler olarak ilerlet.
6. Real-device proof + final 1.442 RC lifecycle audit tamamlanmadan FINAL deme.

**FINAL: NO.**
