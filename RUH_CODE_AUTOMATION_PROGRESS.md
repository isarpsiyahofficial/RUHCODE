# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında **güncel** checkpoint'i tutar. Ayrıntılı tarihçe `automation_runs/` altındadır. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. `SOURCE_LEVEL_IMPLEMENTED` veya `[x]` yalnız kaynak/test sözleşmesinin mevcut olduğunu anlatır; requirement state ancak gerçek workflow/test/evidence kanıtıyla DONE olabilir.

## Ana kapsam

- MASTER: `RC-0001 → RC-1442`.
- Requirement traceability ve semantic evidence denetimi mevcut; kanıtsız DONE yasak.
- Ana bilgi mimarisi: `Bugün · Araçlar · Kayıtlar · Profil`.
- Araçlar: Astroloji / Numeroloji / Spiritüel / Kişisel Gelişim; Astroloji altında Batı / Vedik / Çin / BaZi / Gezegen Saatleri ayrı.
- Canonical SCREEN-ID / ACTION-ID / Feature-ID sözleşmeleri mevcut.
- APPROVED final UI PNG/reference/hash seti henüz tamamlanmadı; visual regression final kapısı açık.

## Source-level ilerlemiş ana bloklar

- Gregorian calendar/leap-year/date identity, Julian/time-scale/sidereal-time provider sınırları.
- Strict EphemerisProvider / EarthOrientationProvider sözleşmeleri, solar events ve Gezegen Saatleri.
- DailySnapshot: Planetary Hour, Moon Phase, Tropical Moon Sign, Personal Day, transit factor, Vedik daily primitives.
- Western: ASC/MC, Whole Sign/Equal/Porphyry/strict Placidus, placements, aspects/orbs, element/modality, aspect grid, dignity/rulership.
- Numeroloji: Pythagorean, Chaldean, Lo Shu, cycles, Pinnacles/Challenges, name metrics, Karmic Debt, compatibility, canonical snapshot/fingerprint, UI/PDF parity.
- BaZi primitives: stems/branches, sexagenary cycle, Hidden Stems, Five Elements, Yin/Yang, Day Master, Ten Gods.
- Entitlement: canonical Feature IDs, UI/route/service guards, offline snapshot/time anchor, Google Play lifetime restore composition, rewarded-ad cancel/failure safety.
- Backup: strict CSV, 15-table schema, SHA/checksum/FK preview, transactional merge/replace/rollback, SQLite importer/exporter, portable `.ruhcode.zip`, native Save As/picker/share, legacy migration.
- Professional PDF: local A4 planning/renderer contracts, structural inspector, table chunking, native delivery, persisted Pythagorean handler, sealed persisted Western snapshot + technical manifest + section projection.

## Western persistence / PDF — güncel durum

- [x] `WesternNatalPersistenceService` production SQLite runtime'a compose edilmiş durumda.
- [x] Western snapshot + SHA + CalculationManifest tek transaction persistence boundary'sine sahip.
- [x] Persisted Western PDF service historical astronomy'yi yeniden hesaplamıyor; sealed snapshot + linked CalculationManifest kullanıyor.
- [x] Placements / houses / aspects + technical manifest PDF projection source-level mevcut.
- [x] **Yeni production write-boundary structural audit:** `tools/astronomy/validate_western_natal_write_boundary.py`.
- [x] `CoreRepositories` generic/public calculations repository expose edemez.
- [x] Explicit calculations-table production write yolu allowlist dışında CI tarafından reddediliyor; doğrulanmış backup restore kontrollü istisna.
- [x] Persisted Western snapshot + technical manifest + PDF service evidence artık ortak MASTER-aware semantic validator tarafından exact RC setleriyle doğrulanıyor.
- [x] Hem `Persisted Western Natal PDF Contract` hem merkezi `Requirements Contract` bu semantic/write-boundary denetimlerini çalıştıracak şekilde bağlı.
- [ ] Production Unicode TR/EN font binary + lisans + immutable SHA.
- [ ] Western production vector painter + APPROVED glyph assets.
- [ ] 5/25/50+ gerçek rendered PDF, parser/crop/glyph/visual regression.
- [ ] Android/iOS gerçek cihaz PDF Save As/share smoke evidence.
- [ ] Exact visible PDF workflow SUCCESS.

## Daily Message / fiziksel artifact blocker'ları

- [x] Exact-date/locale/rolling-horizon/duplicate/near-duplicate günlük mesaj kalite sözleşmesi.
- [ ] 4.018 TR + bağımsız 4.018 EN gerçek editoryal Günün Mesajı içeriği.
- [ ] Fiziksel/versioned IERS EOP/UT1−UTC artifact + checksum/provenance.
- [ ] Ticari yeniden dağıtıma uygun offline ephemeris artifact.
- [ ] Production Lahiri/Chitrapaksha artifact.
- [ ] GeoNames source/output SHA + bulk IANA integrity.
- [ ] Independent golden astronomical accuracy suite.

## Final blocker'ları

- APPROVED UI reference/hash seti.
- Production Unicode PDF font artifact + lisans/hash.
- Exact GitHub Actions SUCCESS kanıtları.
- `pubspec.lock` yalnız gerçek dependency resolution sonrası.
- Clean-checkout/reproducible release APK.
- Play/rewarded-ad gerçek cihaz kanıtları.
- Airplane-mode + Golden Lifecycle + final 1.442 RC audit.

## Son checkpoint — 2026-08-22 18:54

Checkpoint: `automation_runs/2026-08-22_1854_western_write_boundary_semantic_audit.md`

Workflow-target commit: `4868358f8cac5ea45b6f8aedd42b86aa901f1ded`.
GitHub combined status sorgusu individual status göstermedi (`statuses=[]`); bu yüzden ilgili RC'ler DONE yapılmadı.

## Sıradaki çalışma

1. Approved font gerektirmeyen PDF structural/page/parity regression kapsamını genişlet.
2. Requirement-bearing kalan evidence dosyalarını semantic RC drift açısından audit et ve merkezi gate'e bağla.
3. UI interaction/accessibility ve backup blocker-independent açıklarını ilerlet.
4. Western write-path auditine yeni direct writer girmesini CI ile engellemeye devam et.
5. Fiziksel artifact blocker'larında sahte veri/checksum üretme; blocker dışı requirement'larda ilerlemeyi sürdür.

**FINAL: NO.**
