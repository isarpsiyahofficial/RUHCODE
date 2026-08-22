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
- Backup: strict CSV, 15-table schema, SHA/checksum/FK preview, transactional merge/replace/rollback, SQLite importer/exporter, portable `.ruhcode.zip`, native Save As/picker/share, legacy migration.
- Professional PDF: local A4 planning/renderer contracts, structural inspector, table chunking, native delivery, persisted Pythagorean handler, sealed persisted Western snapshot + technical manifest + section projection.

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
- [x] `ACTION-BACKUP-SHARE` canonical runtime extension ve runtime binding olarak kayıtlı.
- [x] `ACTION-BACKUP-RESTORE-MERGE` / `ACTION-BACKUP-RESTORE-REPLACE` valid preview state'inde canonical runtime action olarak kayıtlı.
- [x] Share/merge/replace action'ları FREE, offline-available ve a11y-label-required.
- [x] UI share action gerçek `BackupApplicationActions.exportAndShare()` sınırını çağırıyor ve `.ruhcode.zip` dosya adı kullanıyor.
- [x] Kullanıcı native share sheet'i kapattığında normal cancellation state gösteriliyor.
- [x] Valid preview merge/replace gerçek `BackupImportMode.merge/replace` çağrılarına bağlı.
- [x] Backup action wording/restore-preview validatorları runtime registry + binding + widget sözleşmesini doğruluyor.
- [x] `evidence/backup/native_share_transport_contract.json` exact `RC-1300 / RC-1301` sahipliğiyle MASTER-aware audit altında.
- [x] `evidence/ui/backup_restore_preview_accessibility_contract.json` RC-0832→0839 + RC-1440/1441 sahipliğiyle MASTER-aware structural audit altında.
- [ ] Android real-device share-sheet smoke proof.
- [ ] Android real-device restore focus/screen-reader proof.
- [ ] iOS dağıtım hedeflenirse iOS share-sheet smoke proof.
- [ ] Exact visible Backup/UI/Flutter CI SUCCESS.

## Evidence / requirement audit — güncel durum

- [x] Genel integrity validator bütün `evidence/**/*.json` dosyalarında RC/path/UTF-8/JSON bütünlüğünü fail-closed doğruluyor.
- [x] Seçilmiş evidence aileleri exact MASTER-aware semantic ownership altında.
- [x] UI accessibility için ayrı RC-1441 semantic validator mevcut.
- [x] Backup native transport için ayrı RC-1300/RC-1301 semantic validator mevcut.
- [x] Backup restore preview için RC-0832→0839 + RC-1440/1441 semantic/action validator mevcut.
- [x] Persisted Western snapshot / technical manifest / PDF service ayrı semantic audit altında.
- [x] Western production calculation write-boundary structural audit mevcut.
- [ ] Semantic allowlist dışında kalan requirement-bearing evidence aileleri kademeli olarak exact MASTER ownership denetimine alınmaya devam edecek.
- [ ] Exact görünür CI başarı kanıtı hâlâ yok; combined-status son commitlerde `statuses=[]` dönüyor.

## Western persistence / PDF — açık ana kapılar

- [x] Western snapshot + SHA + CalculationManifest tek transaction persistence boundary'sine sahip.
- [x] Persisted Western PDF historical astronomy'yi yeniden hesaplamıyor.
- [x] Placements / houses / aspects + technical manifest PDF projection source-level mevcut.
- [ ] Production Unicode TR/EN font binary + lisans + immutable SHA.
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
- Exact GitHub Actions SUCCESS kanıtları.
- `pubspec.lock` yalnız gerçek dependency resolution sonrası.
- Clean-checkout/reproducible release APK.
- Play/rewarded-ad gerçek cihaz kanıtları.
- Airplane-mode + Golden Lifecycle + final 1.442 RC audit.

## Son checkpoint — 2026-08-23 02:52

Checkpoint: `automation_runs/2026-08-23_0252_backup_restore_preview_accessibility.md`

Bu turda valid backup preview sonrası merge/replace canonical action sözleşmesi, explicit Semantics, 48dp hedef, deterministic focus order, widget regression, MASTER-aware evidence ve CI trigger/gate kapsamı eklendi.

Workflow-target commit `330a9cc307afce51f2bf22a067975ea5c634237a` için GitHub combined-status yine `statuses=[]` döndürdü. Bu yüzden RC-0832→0839, RC-1440 ve RC-1441 DONE yapılmadı.

## Sıradaki çalışma

1. Requirement-bearing kalan evidence dosyalarını semantic RC drift açısından audit et ve merkezi gate'e bağlamaya devam et.
2. Approved font gerektirmeyen PDF structural/page/parity regression kapsamını genişlet.
3. `pubspec.lock` yalnız gerçek Flutter dependency resolution kanıtı elde edildiğinde ekle.
4. Fiziksel artifact blocker'larında sahte veri/checksum üretme; blocker dışı requirement'larda ilerlemeyi sürdür.

**FINAL: NO.**