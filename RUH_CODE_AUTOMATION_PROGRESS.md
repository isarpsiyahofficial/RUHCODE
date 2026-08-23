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
- Professional PDF: local A4 planning/renderer contracts, structural inspector, `/Pages /Count` consistency, final EOF + `startxref` + xref-target validation, Root→Catalog→Pages object-graph resolution, table chunking, native delivery, persisted Pythagorean handler, sealed persisted Western snapshot + technical manifest + section projection, strong UI↔PDF subject/snapshot parity.
- Professional PDF preflight preview gerçek builder'a bağlı: canonical Preview action, calculation-type aware section catalog, preview→build exact-plan parity ve stale-preview invalidation source-level mevcut.

## UI / Accessibility — güncel durum

- [x] Minimum touch target 48dp.
- [x] Normal metin minimum kontrast 4.5:1; büyük metin 3.0:1.
- [x] Canonical design tokens gerçek sRGB relative-luminance hesabıyla denetleniyor.
- [x] `gold` ve `success` canonical light surfaces üzerinde normal metin değil non-text accent olarak kilitli.
- [x] `lib/src/ui/theme/ruh_design_tokens.dart` canonical JSON → Flutter runtime bridge olarak eklendi.
- [x] `RuhCodeApp`, ham Flutter renk tekrarından `RuhAppTheme.light()` kullanımına geçirildi.
- [x] Runtime token validator ve ThemeData regression testi mevcut.
- [x] 360x800 + 2.0x text-scale: Araçlar, Kayıtlar, Profil→Ayarlar→PDF yolları regression kapsamına alındı.
- [x] Numeroloji localized metric/value semantics regression mevcut.
- [x] Professional PDF create/preview/share kontrolleri canonical ACTION-ID + Semantics + 48dp regression altında.
- [x] Backup create/share/import ve restore merge/replace Semantics + 48dp + deterministic focus-order regression altında.
- [ ] Real-device screen-reader/focus-order traversal.
- [ ] Tüm gerekli ekran/state'lerde 2.0x text-scale overflow/golden regression.
- [ ] APPROVED UI visual regression.
- [ ] Exact visible accessibility workflow SUCCESS.

## Backup native transport — güncel durum

- [x] `BackupSettingsPage`: `Tam Yedek Oluştur`, `Yedeği Paylaş`, `Yedek Dosyası Seç`.
- [x] Share/merge/replace canonical runtime action olarak kayıtlı ve FREE/offline-available.
- [x] UI share action gerçek `.ruhcode.zip` native paylaşım sınırını çağırıyor.
- [x] Valid preview merge/replace gerçek import mode'larına bağlı.
- [x] RC-0794 için full backup'tan ayrı canonical UTF-8 tek-tabla CSV exporter source-level mevcut.
- [ ] Android real-device share-sheet smoke proof.
- [ ] Android real-device restore focus/screen-reader proof.
- [ ] Exact visible Backup/UI/Flutter CI SUCCESS.

## Evidence / requirement audit — güncel durum

- [x] Genel integrity validator bütün `evidence/**/*.json` dosyalarında RC/path/UTF-8/JSON bütünlüğünü fail-closed doğruluyor.
- [x] Numeroloji, BaZi, PDF, Backup, Entitlement, UI accessibility ve persisted Western evidence ailelerinin önemli kısmı exact MASTER-aware semantic ownership altında.
- [x] Runtime dead-action validator canonical action sabiti/binding/source kullanımını çaprazlıyor.
- [x] Local PDF renderer evidence RC-0950/0951/0953 ile sınırlı; RC-0952 independent full-parser/open proof olmadan sahiplenilmiyor.
- [x] PDF preflight evidence RC-0929/1440/1441 source-level zincirine bağlı ve `done=false`.
- [ ] Semantic allowlist dışında kalan requirement-bearing evidence aileleri kademeli olarak exact MASTER ownership denetimine alınmaya devam edecek.
- [ ] Exact görünür CI başarı kanıtı hâlâ yok; combined-status son commitlerde `statuses=[]` dönüyor.

## Western persistence / PDF — güncel durum

- [x] Western snapshot + SHA + CalculationManifest tek transaction persistence boundary'sine sahip.
- [x] Persisted Western PDF historical astronomy'yi yeniden hesaplamıyor.
- [x] Placements / houses / aspects + technical manifest PDF projection source-level mevcut.
- [x] Structural inspector `/Pages /Count`, final `%%EOF`, `startxref`, xref/XRef target ve `/Root` sınırlarını fail-closed doğruluyor.
- [x] `/Root` artık gerçek Catalog'a, Catalog `/Pages` referansı gerçek Pages tree'ye çözülmek zorunda.
- [x] UI↔PDF parity subject kind + stable subject ID + digest üçlüsüyle korunuyor.
- [x] RC-0929 preflight preview gerçek `SCR-PDF-BUILDER-001` Preview action/state'ine bağlı.
- [x] Calculation-type aware section catalog yalnız gerçek handler'ın desteklediği bölümleri kullanıcıya gösteriyor.
- [x] Preview→create aynı exact canonical report-plan input parity testine bağlı.
- [x] Verified-but-unselected PDF payloadları section toggle'larını bozmuyor; selected section strict kalıyor.
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

## Son checkpoint — 2026-08-23 14:54

Checkpoint: `automation_runs/2026-08-23_1454_pdf_object_graph_hardening.md`

Bu turda PDF structural inspector xref/trailer `/Root` referansını gerçek Catalog nesnesine ve Catalog `/Pages` referansını gerçek Pages tree nesnesine çözmek zorunda olacak şekilde sertleştirildi. Yanlış Root ve yanlış Pages hedefleri için fail-closed regression testleri eklendi. Önceki 10:14 commit zincirindeki calculation-aware PDF preflight/section-parity değişikliklerinin main üzerinde olduğu doğrulandı ve bu ilerleme dosyasındaki stale durum düzeltildi.

Latest tested source commit `344734faae6e2df5a05845d1fedfcf27926964d1` için GitHub combined-status yine `statuses=[]` döndürdü. Bu nedenle ilgili PDF requirement'ları DONE değildir; RC-0952 independent full-parser/open proof gelmeden açık kalır.

## Sıradaki çalışma

1. PDF structural evidence/validator'ı Root→Catalog→Pages resolution kontrolünü zorunlu kılacak şekilde genişlet.
2. Font gerektirmeyen PDF data/snapshot parity testlerini genişlet.
3. Remaining requirement-bearing evidence ailelerini semantic RC drift açısından audit et.
4. Fiziksel artifact/font/UI blocker'larında sahte veri/checksum üretme; blocker dışı requirement'larda ilerlemeyi sürdür.

**FINAL: NO.**