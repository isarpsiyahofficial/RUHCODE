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
- [x] UI accessibility evidence ailesi exact `RC-1441` MASTER-aware semantic validator ile korunuyor.
- [ ] Valid backup preview sonrası merge/replace action semantics + focus coverage.
- [ ] Real-device screen-reader/focus-order traversal.
- [ ] Tüm gerekli ekran/state'lerde 2.0x text-scale overflow/golden regression.
- [ ] APPROVED UI visual regression.
- [ ] Exact visible accessibility workflow SUCCESS.

## Backup native transport — güncel durum

- [x] Gerçek `BackupSettingsPage` artık `Tam Yedek Oluştur`, `Yedeği Paylaş`, `Yedek Dosyası Seç` yüzeylerini gösteriyor.
- [x] `ACTION-BACKUP-SHARE` canonical runtime extension ve runtime binding olarak kayıtlı.
- [x] Share action FREE, offline-available ve a11y-label-required.
- [x] UI share action gerçek `BackupApplicationActions.exportAndShare()` sınırını çağırıyor ve `.ruhcode.zip` dosya adı kullanıyor.
- [x] Kullanıcı native share sheet'i kapattığında normal cancellation state gösteriliyor.
- [x] Backup action wording validator create/share/restore üçlüsünü base + runtime extension registries üzerinden doğruluyor.
- [x] `evidence/backup/native_share_transport_contract.json` exact `RC-1300 / RC-1301` sahipliğiyle MASTER-aware audit altında.
- [ ] Android real-device share-sheet smoke proof.
- [ ] iOS dağıtım hedeflenirse iOS share-sheet smoke proof.
- [ ] Exact visible Backup/UI/Flutter CI SUCCESS.

## Evidence / requirement audit — güncel durum

- [x] Genel integrity validator bütün `evidence/**/*.json` dosyalarında RC/path/UTF-8/JSON bütünlüğünü fail-closed doğruluyor.
- [x] Seçilmiş evidence aileleri exact MASTER-aware semantic ownership altında.
- [x] UI accessibility için ayrı RC-1441 semantic validator mevcut.
- [x] Backup native transport için ayrı RC-1300/RC-1301 semantic validator mevcut.
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

## Son checkpoint — 2026-08-23 00:52

Checkpoint: `automation_runs/2026-08-23_0052_runtime_theme_text_scale_gate.md`

Bu turda runtime theme/token drift kapısı, 2.0x text-scale ve kritik widget semantics regresyonları, gerçek Backup native-share UI/action wiring ve RC-1300/1301 semantic evidence zinciri eklendi.

Exact görünür GitHub Actions SUCCESS henüz kanıtlanmadı; latest combined-status `statuses=[]`. Bu yüzden `RC-1441`, `RC-1300`, `RC-1301` DONE yapılmadı.

## Sıradaki çalışma

1. Valid backup preview fixture üzerinden merge/replace action Semantics + 48dp/focus regression ekle.
2. Requirement-bearing kalan evidence dosyalarını semantic RC drift açısından audit et ve merkezi gate'e bağlamaya devam et.
3. Approved font gerektirmeyen PDF structural/page/parity regression kapsamını genişlet.
4. `pubspec.lock` yalnız gerçek Flutter dependency resolution kanıtı elde edildiğinde ekle.
5. Fiziksel artifact blocker'larında sahte veri/checksum üretme; blocker dışı requirement'larda ilerlemeyi sürdür.

**FINAL: NO.**
