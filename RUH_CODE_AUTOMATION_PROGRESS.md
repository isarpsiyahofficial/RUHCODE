# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında **güncel** checkpoint'i tutar. Ayrıntılı tarihçe `automation_runs/` altındadır. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. `SOURCE_LEVEL_IMPLEMENTED` veya `[x]` yalnız kaynak/test sözleşmesinin mevcut olduğunu anlatır; requirement state ancak gerçek workflow/test/evidence kanıtıyla DONE olabilir.

## Ana kapsam

- MASTER: `RC-0001 → RC-1442`.
- Requirement traceability ve semantic evidence denetimi mevcut; kanıtsız DONE yasak.
- Ana bilgi mimarisi: `Bugün · Araçlar · Kayıtlar · Profil`.
- Araçlar: Astroloji / Numeroloji / Spiritüel / Kişisel Gelişim; Astroloji altında Batı / Vedik / Çin / BaZi / Gezegen Saatleri ayrı.
- Canonical SCREEN-ID / ACTION-ID / Feature-ID sözleşmeleri mevcut.
- APPROVED final UI PNG/reference/hash seti henüz tamamlanmadı; visual regression final kapısı açık.

## DailySnapshot / içerik

- [x] Exact date + IANA zone + coordinate + engine/tz version identity.
- [x] Planetary Hour, Moon Phase, Tropical Moon Sign, Pythagorean Personal Day.
- [x] Transit factor ve applying/exact/separating sınıflandırması.
- [x] Vedik daily primitives: sidereal Sun/Moon, Nakshatra, Pada, Tithi, Paksha.
- [x] Günün Mesajı exact-date/locale/rolling-horizon/duplicate/near-duplicate kalite sözleşmesi.
- [ ] Fiziksel ephemeris/EOP/Lahiri ve bağımsız accuracy kanıtları.
- [ ] Gerçek 4.018 TR + bağımsız 4.018 EN editoryal Günün Mesajı içeriği.

## Calculation source-level

- [x] Gregorian calendar/leap-year/date identity.
- [x] Julian/time-scale/sidereal-time provider sınırları.
- [x] Strict EphemerisProvider / EarthOrientationProvider sözleşmeleri.
- [x] Solar events + Gezegen Saatleri.
- [x] Western Whole Sign / Equal / Porphyry / strict Placidus, ASC/MC, placements, aspects, orbs, elements, modalities, aspect-grid, classical dignity/rulership.
- [x] Numeroloji: Pythagorean, Chaldean, Lo Shu, cycles, Pinnacles/Challenges, Balance/Karmic Lessons/Hidden Passion, Karmic Debt, compatibility, canonical snapshot/fingerprint, UI/PDF parity source-level.
- [x] BaZi primitives: Heavenly Stems, Earthly Branches, sexagenary cycle, Hidden Stems, Five Elements, Yin/Yang, Day Master, Ten Gods.
- [ ] Fiziksel IERS EOP / offline ephemeris / Lahiri / GeoNames artifacts + checksums.
- [ ] Independent golden accuracy suites ve exact visible workflow SUCCESS.

## Free / PRO / entitlement

- [x] Merkezi `RuhFeatureIds` + tek Free/PRO policy kaynağı.
- [x] UI/route/service guard zinciri.
- [x] Offline entitlement snapshot + rollback-resistant UTC anchor source-level.
- [x] Google Play lifetime ownership restore/cached-offline composition source-level.
- [x] Rewarded-ad cancel/failure güvenlik coordinator source-level.
- [x] Professional client/preset ve PDF servis seviyesinde guard.
- [x] Çin basic FREE ve BaZi basic PRO parity.
- [x] PDF policy: `pdf.sample_preview` FREE; `pdf.professional_export` PRO.
- [ ] Gerçek Play-distributed reinstall/device-change device proof.
- [ ] Gerçek rewarded-ad SDK device proof.
- [ ] Exact release-mode Free/PRO/temporary workflow görünür SUCCESS.

## Backup / CSV — source-level

- [x] Strict Unicode CSV codec.
- [x] SHA-256 manifest, checksum/count/schema/FK preview.
- [x] Transactional merge/replace + durable safety snapshot + rollback.
- [x] Production SQLite importer/exporter.
- [x] Portable `.ruhcode.zip`, zip-slip/CRC/duplicate/zip-bomb guards.
- [x] Native Save As / picker / share gateway ve application service.
- [x] TR/EN backup UI states; rollback sonucu typed.
- [x] Legacy v0 migrator; unknown birth time midnight'e uydurulmuyor.
- [x] Schema-v1 registry 15 logical CSV tablo içeriyor; `tarot_cards.csv` normalized standalone tablo.
- [ ] Exact Backup CSV workflow SUCCESS görünür değil; ilgili RC'ler DONE değil.
- [ ] Android gerçek cihaz save/open/share smoke testi.
- [ ] Released historical backup fixture doğrulaması.
- [ ] `pubspec.lock` yalnız gerçek `flutter pub get` çözümlemesinden sonra commit edilmeli.

## Profesyonel PDF — source-level

- [x] Local A4 renderer/planning/snapshot identity/parity sözleşmesi.
- [x] PDF output structural inspector + table chunking + page safety.
- [x] Western vector geometry adapter source-level.
- [x] Numerology canonical snapshot → PDF data parity source-level.
- [x] Free sample preview / PRO professional export policy.
- [x] `ProfessionalPdfApplicationService<TSnapshot>` exact selected record → guarded PRO service → PDF structural inspection zinciri.
- [x] `LocalDatabaseProfessionalPdfSnapshotSource` calculation + CalculationManifest'i aynı transaction içinde okuyor.
- [x] Typed saved-calculation selector; raw record-ID alanı kaldırıldı.
- [x] Exact calculation-type router; unknown/duplicate handler fail-closed.
- [x] Native PDF Save As/share source-level; cancellation/unavailable typed.
- [x] Persisted Pythagorean snapshot PDF handler source-level; canonical SHA ve manifest version parity.
- [x] **Professional builder action semantic drift düzeltildi:** runtime artık `ACTION-PDF-BUILDER-CREATE` / `ACTION-PDF-BUILDER-SHARE` kullanıyor; tarihsel preview create/share ID'leri builder runtime'da yasak.
- [x] Runtime action registry extension, runtime binding, PDF entitlement validator ve accessibility validator canonical builder actionlarını birlikte doğruluyor.
- [x] **Persisted Western natal snapshot v1 eklendi:** requested/effective house system, exact 12 cusp, placements, major aspects, TT/source/engine/algorithm/data provenance.
- [x] Persisted Western snapshot canonical JSON + SHA-256 ile mühürleniyor; tamper fail-closed.
- [x] Persisted Western PDF reader CalculationManifest engine/algorithm/data version parity'sini doğruluyor.
- [x] Western PDF geometry persisted snapshot'tan üretiliyor; tarihi natal harita PDF açılışında yeniden hesaplanmıyor.
- [x] Persisted Western snapshot/PDF test, evidence, structural validator ve ayrı CI contract oluşturuldu.
- [ ] Persisted Western snapshot calculation-save boundary'ye bağlanmalı; yeni `western.natal` kaydı snapshot+SHA'yı atomik yazmalı.
- [ ] Persisted Western snapshot'tan production PDF section/table projection tamamlanmalı.
- [ ] Production build-side handler composition yalnız approved font provider ile runtime'a bağlanmalı.
- [ ] Production Unicode TR/EN font binary + lisans + immutable SHA.
- [ ] Western production vector painter + approved glyph assets.
- [ ] Vedik vector chart embedding; BaZi/Numerology production table renderers.
- [ ] 5/25/50+ real rendered page tests, parser/crop/glyph/visual regression.
- [ ] Android/iOS real-device PDF Save As/share smoke evidence.
- [ ] Exact PDF workflows görünür SUCCESS.

## Semantic evidence / UI quality

- [x] Merkezi semantic evidence validator Numeroloji, BaZi, PDF, Backup, Entitlement, terminology/interpretation ve Western astronomy ailelerini denetliyor.
- [x] Yanlış TODO-index→RC eşlemeleri birden fazla evidence ailesinde temizlendi.
- [x] Runtime action bindings registry + Feature Catalog Free/PRO parity ile çaprazlanıyor.
- [x] 48dp minimum touch target, Semantics labels, 2.0x critical navigation contract source-level.
- [x] Professional PDF builder create/share artık builder ekranına ait canonical action ID'ler kullanıyor.
- [x] Legacy `ACTION-PDF-PREVIEW-CREATE/SHARE` kimliklerinin builder runtime'a dönmesi structural validator ile engelleniyor.
- [ ] Requirement-bearing diğer evidence dosyalarını semantic RC drift açısından taramaya devam et.
- [ ] APPROVED UI reference/hash seti olmadan UI visual DONE verme.

## Açık fiziksel / harici kanıt blocker'ları

- [ ] Fiziksel/versioned IERS EOP/UT1−UTC artifact + checksum/provenance.
- [ ] Fiziksel, ticari yeniden dağıtıma uygun offline ephemeris artifact.
- [ ] Production Lahiri/Chitrapaksha artifact.
- [ ] GeoNames source/output SHA + bulk IANA integrity.
- [ ] 8.036 gerçek editoryal günlük mesaj.
- [ ] Yeni APPROVED UI reference seti.
- [ ] Production Unicode PDF font binary + lisans/hash.
- [ ] Clean-checkout lockfile/release build kanıtı.

## Son checkpoint — 2026-08-22 12:53

Checkpoint: `automation_runs/2026-08-22_1253_pdf_builder_actions_western_snapshot.md`

Öne çıkan işler:
- professional PDF builder action ID semantiği düzeltildi
- runtime registry extension + validator/CI parity
- versioned persisted Western natal snapshot v1
- canonical SHA-256 tamper kontrolü
- Placidus/Porphyry/Whole Sign/Equal için ortak resolved 12-cusp persistence projection
- manifest engine/algorithm/data parity
- persisted snapshot → PDF vector geometry; historical recalculation yok
- dedicated tests/evidence/validator/workflow

Workflow-target commit `30b8e9137251efd87678d5600b91893da61f44bf` için GitHub combined-status `statuses=[]`; source-level evidence `done=false`, ilgili RC'ler DONE değil.

## Sıradaki çalışma

1. Western calculation-save boundary'yi snapshot+SHA + CalculationManifest atomik persistence ile bağla.
2. Persisted Western PDF section/table projection oluştur; renderer içinde yeniden hesaplama yapma.
3. Yeni Western persistence evidence'ını semantic MASTER RC audit'e konservatif sahiplikle dahil et.
4. Requirement-bearing kalan evidence dosyalarını semantic RC ownership audit'e al.
5. Fiziksel ephemeris/EOP/Lahiri/GeoNames, 8.036 günlük mesaj, APPROVED UI refs, production PDF fonts ve clean-checkout lockfile blocker'larını açık tut.
6. Requirement state'i yalnız görünür test/workflow/evidence kanıtıyla yükselt.

## Final durumu

**FINAL DEĞİL.** RC-0001→RC-1442 tamamı ve zorunlu release kapıları gerçek kanıtla yeşil olmadan FINAL denmeyecek.
