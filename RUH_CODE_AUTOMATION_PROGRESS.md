# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında **güncel** checkpoint'i tutar. Ayrıntılı tarihçe `automation_runs/` altındadır. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. `SOURCE_LEVEL_IMPLEMENTED` veya `[x]` yalnız kaynak/test sözleşmesinin mevcut olduğunu anlatır; requirement state ancak gerçek workflow/test/evidence kanıtıyla DONE olabilir.

## Ana kapsam

- MASTER: `RC-0001 → RC-1442`.
- Requirement traceability + repository-wide evidence integrity mevcut; kanıtsız DONE yasak.
- Ana bilgi mimarisi: `Bugün · Araçlar · Kayıtlar · Profil`.
- Canonical SCREEN-ID / ACTION-ID / Feature-ID sözleşmeleri mevcut.
- APPROVED final UI PNG/reference/hash seti henüz tamamlanmadı; visual regression final kapısı açık.

## Source-level ilerlemiş ana bloklar

- Gregorian calendar/leap-year/date identity, Julian/time-scale/sidereal-time provider sınırları.
- Strict EphemerisProvider / EarthOrientationProvider sözleşmeleri, solar events ve Gezegen Saatleri.
- DailySnapshot: Planetary Hour, Moon Phase, Tropical Moon Sign, Personal Day, transit factor, Vedik daily primitives.
- Western: ASC/MC, Whole Sign/Equal/Porphyry/strict Placidus, placements, aspects/orbs, element/modality, aspect grid, dignity/rulership, sealed persisted snapshot + atomic manifest persistence.
- Numeroloji: Pythagorean, Chaldean, Lo Shu, cycles, Pinnacles/Challenges, name metrics, Karmic Debt, compatibility, canonical snapshot/fingerprint, UI/PDF parity.
- BaZi primitives: stems/branches, sexagenary cycle, Hidden Stems, Five Elements, Yin/Yang, Day Master, Ten Gods.
- Entitlement: canonical Feature IDs, UI/route/service guards, offline snapshot/time anchor, Google Play lifetime restore composition, rewarded-ad cancel/failure safety.
- Backup: strict CSV, 15-table schema, SHA/checksum/FK preview, transactional merge/replace/rollback, SQLite importer/exporter, portable `.ruhcode.zip`, native Save As/picker/share, legacy migration, canonical tek-tabla CSV exporter.
- Professional PDF: local A4 planning/renderer contracts, structural inspector, `/Pages /Count` consistency, final EOF + `startxref` + xref-target validation, table chunking, native delivery, persisted Pythagorean handler, sealed persisted Western snapshot + technical manifest + section projection, strong UI↔PDF subject/snapshot parity.
- Professional PDF preflight preview: exact `PdfReportPlan` üzerinden section order/locale/cover/page-spec/branding taşıyan, byte üretiminden önce çalışan fail-closed preview modeli source-level mevcut.

## UI / Accessibility — güncel durum

- [x] Minimum touch target 48dp.
- [x] Normal metin minimum kontrast 4.5:1; büyük metin 3.0:1.
- [x] Canonical design tokens gerçek sRGB relative-luminance hesabıyla denetleniyor.
- [x] `gold` ve `success` canonical light surfaces üzerinde normal metin değil non-text accent olarak kilitli.
- [x] `lib/src/ui/theme/ruh_design_tokens.dart` canonical JSON → Flutter runtime bridge olarak eklendi.
- [x] `RuhCodeApp`, ham `Color(0x...)` / `Colors.white` tema tekrarından `RuhAppTheme.light()` kullanımına geçirildi.
- [x] `tools/ui/validate_runtime_theme_tokens.py`, JSON↔Dart token eşitliğini ve UI/app kaynaklarında token bridge dışı raw Flutter color kullanımını fail-closed reddediyor.
- [x] ThemeData canonical palette regression testi mevcut.
- [x] 360x800 + 2.0x text-scale: Araçlar, Kayıtlar, Profil→Ayarlar→PDF yolları regression kapsamına alındı.
- [x] Numeroloji localized metric/value semantics regression mevcut.
- [x] Professional PDF create/share kontrolleri explicit Semantics + 48dp regression altında.
- [x] Backup create/share/import kontrolleri explicit Semantics + 48dp regression altında.
- [x] Valid backup preview sonrası `Birleştir` / `Değiştir` canonical ACTION-ID, explicit Semantics, 48dp ve deterministic merge→replace focus-order regression altında.
- [x] UI accessibility evidence ailesi exact MASTER-aware semantic validatorlarla korunuyor.
- [ ] Real-device screen-reader/focus-order traversal.
- [ ] Tüm gerekli ekran/state'lerde 2.0x text-scale overflow/golden regression.
- [ ] APPROVED UI visual regression.
- [ ] Exact visible accessibility workflow SUCCESS.

## Backup native transport — güncel durum

- [x] Gerçek `BackupSettingsPage` artık `Tam Yedek Oluştur`, `Yedeği Paylaş`, `Yedek Dosyası Seç` yüzeylerini gösteriyor.
- [x] `ACTION-BACKUP-SHARE`, restore merge/replace canonical runtime action olarak kayıtlı.
- [x] Share/merge/replace action'ları FREE, offline-available ve a11y-label-required.
- [x] UI share action gerçek `.ruhcode.zip` native paylaşım sınırını çağırıyor.
- [x] Native share cancellation normal state.
- [x] Valid preview merge/replace gerçek import mode'larına bağlı.
- [x] RC-0794 için full backup'tan ayrı canonical UTF-8 tek-tabla CSV exporter source-level mevcut.
- [ ] Android real-device share-sheet smoke proof.
- [ ] Android real-device restore focus/screen-reader proof.
- [ ] Exact visible Backup/UI/Flutter CI SUCCESS.

## Evidence / requirement audit — güncel durum

- [x] Genel integrity validator bütün `evidence/**/*.json` dosyalarında RC/path/UTF-8/JSON bütünlüğünü fail-closed doğruluyor.
- [x] Seçilmiş evidence aileleri exact MASTER-aware semantic ownership altında.
- [x] UI accessibility için ayrı RC-1441 semantic validator mevcut.
- [x] Backup native transport, application-service ve restore-preview exact semantic validatorlar altında.
- [x] Persisted Western snapshot / technical manifest / PDF service ayrı semantic audit altında.
- [x] Local PDF renderer evidence exact RC-0950/0951/0953 sahipliği altında; RC-0952 full-parser/open kanıtı gelmeden sahiplenilmiyor.
- [x] PDF report-planning evidence RC-0929'u yanlış sahiplenmiyor.
- [x] Yeni preflight-preview evidence yalnız exact RC-0929 sahipliğiyle MASTER-aware validator altında ve `done=false`.
- [ ] Semantic allowlist dışında kalan requirement-bearing evidence aileleri kademeli olarak exact MASTER ownership denetimine alınmaya devam edecek.
- [ ] Exact görünür CI başarı kanıtı hâlâ yok; combined-status son commitlerde `statuses=[]` dönüyor.

## Western persistence / PDF — açık ana kapılar

- [x] Western snapshot + SHA + CalculationManifest tek transaction persistence boundary'sine sahip.
- [x] Persisted Western PDF historical astronomy'yi yeniden hesaplamıyor.
- [x] Placements / houses / aspects + technical manifest PDF projection source-level mevcut.
- [x] Structural inspector `/Pages /Count`, final `%%EOF`, `startxref`, xref/XRef target ve `/Root` sınırlarını fail-closed doğruluyor.
- [x] UI↔PDF parity subject kind + stable subject ID + digest üçlüsüyle korunuyor.
- [x] RC-0929 için byte üretiminden önce exact report-plan preview modeli source-level mevcut.
- [ ] RC-0929 preflight preview modelini `SCR-PDF-BUILDER-001` gerçek `Önizle` action/state'ine bağla.
- [ ] Preview→create aynı exact report-plan parity widget/integration kanıtı.
- [ ] Production Unicode TR/EN font binary + lisans + immutable SHA.
- [ ] Independent full-parser/open proof.
- [ ] Western production vector painter + APPROVED glyph assets.
- [ ] 5/25/50+ gerçek rendered PDF, parser/crop/glyph/visual regression.
- [ ] Android/iOS gerçek cihaz PDF Save As/share smoke evidence.

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
- Independent full PDF parser/glyph/crop/visual proof.
- Exact GitHub Actions SUCCESS kanıtları.
- `pubspec.lock` yalnız gerçek dependency resolution sonrası.
- Clean-checkout/reproducible release APK.
- Play/rewarded-ad gerçek cihaz kanıtları.
- Airplane-mode + Golden Lifecycle + final 1.442 RC audit.

## Son checkpoint — 2026-08-23 10:55

Checkpoint: `automation_runs/2026-08-23_1055_pdf_preflight_preview.md`

Bu turda RC-0929 için demo/sample PDF'den ayrı professional preflight preview modeli eklendi. Preview exact `PdfReportPlan` üzerinden section order, locale, cover style, A4/page spec ve branding bilgisini koruyor; empty/duplicate/unknown planlar fail-closed. Unit test, exact RC-0929 evidence, MASTER-aware validator ve Professional PDF Contract wiring eklendi. Runtime builder `Önizle` action/state bağlantısı henüz yapılmadığı ve exact CI görünmediği için RC-0929 DONE değildir.

Workflow-target source commit `8cc69aa4f554ef61eda4e999d85136acb2c36d79` için GitHub combined-status yine `statuses=[]` döndürdü.

## Sıradaki çalışma

1. Builder-specific canonical preview ACTION-ID oluştur ve preflight preview modelini `SCR-PDF-BUILDER-001` gerçek state'ine bağla.
2. Preview → create aynı exact report-plan parity testini ekle.
3. Remaining backup/PDF requirement-bearing evidence ailelerini semantic RC drift açısından audit et.
4. Fiziksel artifact/font/UI blocker'larında sahte veri/checksum üretme; blocker dışı requirement'larda ilerlemeyi sürdür.

**FINAL: NO.**