# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya güncel source-level checkpoint'i özetler. Ayrıntılı çalışma geçmişi `automation_runs/` altındadır. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md` ve `RUH_CODE_MASTER_TODO.md` dosyalarıdır.

**Kural:** `SOURCE_LEVEL_IMPLEMENTED` veya matrix'teki `IMPLEMENTED`, requirement'ın DONE olduğu anlamına gelmez. `DONE` yalnız explicit state + gerekli test/golden/device/release kanıtı ile verilebilir.

## Requirement traceability — güncel

- Kapsam exact `RC-0001 → RC-1442`.
- Evidence yalnız ilgili RC'yi en fazla `IMPLEMENTED` seviyesine çıkarabilir; source-level kanıt otomatik TESTED/VERIFIED/DONE üretmez.
- Repository-wide evidence integrity, semantic ownership ve matrix provenance kapıları aktiftir.
- PDF/backup/UI/Western/combined semantic validator'ları merkezi Requirements Contract'a bağlıdır.
- Daily-message structural lifecycle ve contiguous editorial-progress validator'ları da merkezi Requirements Contract'a bağlıdır.

## Source-level ilerlemiş ana bloklar

- Gregorian calendar / leap-year / exact-date identity.
- UTC/TT/UT1/sidereal-time provider sınırları.
- Ephemeris/EOP strict provider sözleşmeleri.
- Solar events ve Gezegen Saatleri.
- DailySnapshot: planetary hour, Moon phase/sign, Personal Day, transit ve Vedik daily primitives.
- Western: ASC/MC, Whole Sign/Equal/Porphyry/strict Placidus, placements, aspects/orbs, distribution, aspect grid, dignity/rulership, sealed persisted natal snapshot ve atomic manifest persistence.
- Numeroloji: Pythagorean, Chaldean, Lo Shu, cycles, Pinnacles/Challenges, name metrics, Karmic Debt, compatibility, canonical snapshot/fingerprint, UI/PDF parity.
- BaZi primitives: stems/branches, sexagenary cycle, Hidden Stems, Five Elements, Yin/Yang, Day Master, Ten Gods.
- Çin Astrolojisi basic year core.
- Entitlement: canonical Feature IDs, UI/route/service guards, offline entitlement snapshot/time anchor, Play lifetime restore composition, rewarded cancel/failure safety.
- Backup: strict CSV, 15-table schema, manifest/checksum/FK preview, transactional merge/replace/rollback, SQLite export/import, `.ruhcode.zip`, native save/pick/share, legacy migration, tek-tabla CSV export.
- Professional PDF: local planning/renderer contracts, preview→build parity, persisted Numerology/Western handlers, structural inspection, native delivery, subject/snapshot parity ve page geometry validation.
- Combined PDF: persisted Western + Pythagorean projection, localized system separation, guarded multi-record preview/build, görünür Flutter route, exact-preview native delivery ve action/accessibility sözleşmesi.
- Daily-message editorial pipeline: deterministic period shards, safe paired batch append, partial QA without weakening strict release completeness ve ledger-backed contiguous coverage.

## Günün Mesajı — güncel editoryal ilerleme

Bağlayıcı başlangıç hedefi **4.018 tarih × 2 bağımsız dil = 8.036 kayıt**.

Committed ve evidence-ledger ile eşleşen contiguous coverage:

- TR: `2026-01-01 → 2027-02-28` = **424 kayıt**
- EN: `2026-01-01 → 2027-02-28` = **424 kayıt**
- toplam: **848 / 8.036**
- kalan: **7.188 kayıt**
- sıradaki exact başlangıç: **2027-03-01**

Bu turda Şubat 2027 için **28 TR + 28 bağımsız EN = 56 yeni mesaj** eklendi. İngilizce track Türkçe track'in makine çevirisi olarak kullanılmıyor. TR dosyasında bulunan bir yazım hatası ledger ilerletilmeden önce düzeltildi.

Kalite/ilerleme güvenliği:

- exact `YYYY-MM-DD|locale` anahtar sözleşmesi korunuyor,
- `{locale}/{year}.csv` ve `{locale}/{year}-{month}.csv` shard'ları deterministic katalogda birleşiyor,
- global duplicate exact key ve shard period/date uyuşmazlığı fail-closed,
- paired editorial append TR+EN exact tarih aralığını ve contiguous ledger parity'yi zorunlu tutuyor,
- partial editorial audit gelecekte eksik tarihleri çalışma sırasında toleranslı ele alabilir ama malformed row, duplicate, exact/near duplicate, opening-pattern ve unsafe-certainty kontrollerini gevşetmez,
- strict release audit 8.036 kaydı ve leap dates'i zorunlu tutar.

`RC-1424/1425/1426/1427/1433/1434` **DONE değildir**. Full completeness + rolling release horizon + final QA + exact visible CI olmadan DONE verilmez.

## Combined PDF — güncel

`RC-0903` ve `RC-0904` source-level evidence altında, DONE değil. Persisted Western + Pythagorean snapshot'lar aynı stable subject'e ait olmak zorunda; exact preview token record-set/locale/subject/section parity'yi koruyor; drift fail-closed. `RC-0905` gerçek persisted Vedik PDF sistemi olmadan açık tutuluyor.

## UI / Accessibility — açık kalanlar

- Canonical ana navigasyon: `Bugün · Araçlar · Kayıtlar · Profil`.
- Design token contrast, 48dp, Semantics ve kritik 2.0x text-scale kaynak sözleşmeleri mevcut.
- APPROVED final UI PNG/reference/hash seti tamamlanmadı.
- Real-device screen-reader/focus traversal ve tam visual regression açık.

## Backup / PDF — açık kalanlar

- Android gerçek cihaz backup save/pick/share smoke proof.
- Release-candidate clean-install export→erase→restore proof.
- Production Unicode TR/EN PDF font binary + license + immutable SHA.
- Independent full PDF parser/open proof.
- Western production vector painter + approved glyph assets.
- Persisted Vedik PDF/vector chart, gereken BaZi production tabloları.
- 5/25/50+ gerçek rendered PDF, low-memory, glyph/crop/visual regression.
- gerçek cihaz PDF Save As/share smoke evidence.

## Fiziksel veri / içerik blocker'ları

- versioned IERS EOP/UT1−UTC artifact + checksum/provenance.
- ticari yeniden dağıtıma uygun offline ephemeris artifact.
- production Lahiri/Chitrapaksha artifact.
- GeoNames source/output SHA + bulk IANA integrity.
- independent astronomical golden accuracy suite.
- günlük mesajlarda kalan **7.188** editoryal kayıt ve strict release audit.
- 1890–2110 verified Chinese New Year boundary artifact.

## Release blocker'ları

- APPROVED UI reference/hash seti.
- Production PDF font artifact.
- Exact görünür GitHub Actions SUCCESS kanıtları.
- `pubspec.lock` yalnız gerçek dependency resolution sonrası.
- Play/rewarded real-device proof.
- clean-checkout/reproducible release APK.
- airplane-mode + Golden Lifecycle + final 1.442 RC audit.

## Son checkpoint

`automation_runs/2026-08-24_2255_daily_messages_february_2027.md`

İlgili daily-message RC'leri DONE yapılmadı.

## Sıradaki çalışma

1. Daily messages: `2027-03-01` tarihinden TR + bağımsız EN editoryal üretime devam et.
2. Yeni ayları `YYYY-MM.csv` shard olarak ekle; exact-date uniqueness ve contiguous ledger gate'ini koru.
3. Her content batch sonrası partial QA ve evidence-ledger parity'yi koru.
4. Combined evidence semantic ownership auditini sürdür; `RC-0905`'i persisted Vedik PDF olmadan sahiplenme.
5. PDF/UI/accessibility/evidence blocker-dışı işlerini sürdür.
6. Fiziksel artifact/font/UI/device-test blocker'larında kanıtsız DONE verme.

**FINAL: NO.**
