# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında **güncel** checkpoint'i tutar. Ayrıntılı tarihçe `automation_runs/` altındadır. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. `SOURCE_LEVEL_IMPLEMENTED` veya `[x]` yalnız kaynak/test sözleşmesinin mevcut olduğunu anlatır; requirement state ancak gerçek workflow/test/evidence kanıtıyla DONE olabilir.

## Ana kapsam

- MASTER: `RC-0001 → RC-1442`.
- Requirement traceability ve semantic evidence denetimi mevcut; kanıtsız DONE yasak.
- Repository-wide evidence integrity gate bütün `evidence/**/*.json` ağacını RC token/path/JSON bütünlüğü açısından tarıyor.
- Ana bilgi mimarisi: `Bugün · Araçlar · Kayıtlar · Profil`.
- Araçlar: Astroloji / Numeroloji / Spiritüel / Kişisel Gelişim; Astroloji altında Batı / Vedik / Çin / BaZi / Gezegen Saatleri ayrı.
- Canonical SCREEN-ID / ACTION-ID / Feature-ID sözleşmeleri mevcut.
- UI design-token kontrastı artık gerçek sRGB relative-luminance hesabıyla ölçülüyor; RC-1441 semantic evidence altında.
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
- Accessibility: 48dp touch target, 4.5:1 normal-text / 3.0:1 large-text contract, measured design-token contrast and low-contrast accent restrictions.

## Evidence / requirement audit — güncel durum

- [x] Seçilmiş evidence sözleşmeleri için exact MASTER-aware semantic RC ownership denetimi mevcut.
- [x] Persisted Western snapshot / technical manifest / PDF service ayrı semantic audit altında.
- [x] Western production calculation write-boundary structural audit mevcut.
- [x] Genel integrity validator: `tools/requirements/validate_evidence_integrity.py`.
- [x] Bütün evidence JSON dosyalarında invalid RC formatı, out-of-range RC, duplicate RC ve çelişen `requirements` / `requirement_ids` setleri fail-closed.
- [x] Evidence içindeki local `sources` / `tests` / `validators` yolları gerçek repository dosyasına çözülmek zorunda; absolute/traversal path reddediliyor.
- [x] Invalid UTF-8/JSON ve `done=true` + açık release blocker kombinasyonu reddediliyor.
- [x] Merkezi `Requirements Contract` genel integrity gate'ini semantic auditlerden önce çalıştıracak şekilde bağlı.
- [x] `evidence/ui/design_token_contrast_contract.json` exact `RC-1441` semantic ownership denetimine bağlı.
- [ ] İlk görünür CI koşusunda yeni genel gate + UI contrast gate'in bütün mevcut evidence ağacını yeşil geçtiği exact commit kanıtı henüz yok.
- [ ] Semantic allowlist dışında kalan requirement-bearing evidence aileleri kademeli olarak MASTER-aware exact ownership denetimine alınmaya devam edecek.

## UI / Accessibility — güncel durum

- [x] Primary nav sözleşmesi `Bugün · Araçlar · Kayıtlar · Profil` olarak kilitli.
- [x] Minimum touch target 48dp.
- [x] Normal metin minimum kontrast 4.5:1; büyük metin 3.0:1.
- [x] `tools/ui/validate_design_tokens.py` required token çiftlerini gerçek sRGB relative luminance ile ölçüyor.
- [x] `textPrimary`, `textMuted`, `primary`, `primaryStrong`, `danger` için canonical light-surface text pair contract mevcut.
- [x] `gold` ve `success` canonical light surfaces üzerinde normal-text tokenı olarak kullanılamaz; non-text accent olarak kilitli.
- [x] Accessibility contract measured contrast gate'e bağlı ve Requirements Contract bu validatorları çalıştırıyor.
- [ ] Rendered widget kaynaklarında ad-hoc low-contrast color kullanımının repository-wide taraması henüz yok.
- [ ] Real-device screen-reader traversal.
- [ ] Tüm gerekli ekran state'lerinde 2.0x text-scale overflow/golden regression.
- [ ] APPROVED UI visual regression.
- [ ] Exact visible accessibility workflow SUCCESS.

## Western persistence / PDF — güncel durum

- [x] `WesternNatalPersistenceService` production SQLite runtime'a compose edilmiş durumda.
- [x] Western snapshot + SHA + CalculationManifest tek transaction persistence boundary'sine sahip.
- [x] Persisted Western PDF service historical astronomy'yi yeniden hesaplamıyor; sealed snapshot + linked CalculationManifest kullanıyor.
- [x] Placements / houses / aspects + technical manifest PDF projection source-level mevcut.
- [x] Production write-boundary audit `tools/astronomy/validate_western_natal_write_boundary.py` ile korunuyor.
- [x] `CoreRepositories` generic/public calculations repository expose edemez.
- [x] Explicit calculations-table production write yolu allowlist dışında CI tarafından reddediliyor; doğrulanmış backup restore kontrollü istisna.
- [x] Persisted Western snapshot + technical manifest + PDF service evidence ortak MASTER-aware semantic validator tarafından exact RC setleriyle doğrulanıyor.
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

## Son checkpoint — 2026-08-22 22:53

Checkpoint: `automation_runs/2026-08-22_2253_ui_contrast_semantic_gate.md`

Workflow-target source commit: `b4c7aad7d13ea3282589567e0da5b481889e7b5f`.
Exact görünür GitHub Actions SUCCESS henüz kanıtlanmadı. Bu yüzden `RC-1441` DONE yapılmadı.

## Sıradaki çalışma

1. Rendered UI kaynaklarında ad-hoc low-contrast renk kullanımını yakalayan source-level validator ekle.
2. 2.0x text-scale/widget semantics kapsamını genişlet.
3. Requirement-bearing kalan evidence dosyalarını semantic RC drift açısından audit et ve merkezi gate'e bağlamaya devam et.
4. Approved font gerektirmeyen PDF structural/page/parity regression kapsamını genişlet.
5. Fiziksel artifact blocker'larında sahte veri/checksum üretme; blocker dışı requirement'larda ilerlemeyi sürdür.

**FINAL: NO.**