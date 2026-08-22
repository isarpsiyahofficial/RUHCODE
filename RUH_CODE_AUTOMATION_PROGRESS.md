# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında güncel checkpoint'i tutar. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. `SOURCE_LEVEL_IMPLEMENTED` veya `[x]` burada yalnız kaynak/test sözleşmesinin mevcut olduğunu anlatır; requirement state ancak gerçek workflow/test/evidence kanıtıyla DONE olabilir.

## Ana kapsam

- MASTER: `RC-0001 → RC-1442`.
- Requirement traceability altyapısı mevcut; kanıtsız DONE yasak.
- Ana bilgi mimarisi: `Bugün · Araçlar · Kayıtlar · Profil`.
- Araçlar: Astroloji / Numeroloji / Spiritüel / Kişisel Gelişim; Astroloji altında Batı / Vedik / Çin / BaZi / Gezegen Saatleri ayrı.
- Canonical SCREEN-ID / ACTION-ID / Feature-ID sözleşmeleri mevcut.
- APPROVED final UI PNG/reference seti henüz tamamlanmadı; visual regression final kapısı açık.

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
- [x] Runtime Tools/Records route'ları canonical Feature ID kullanıyor.
- [x] Çin basic FREE ve BaZi basic PRO drift'i giderildi.
- [x] PDF policy: `pdf.sample_preview` FREE; `pdf.professional_export` PRO.
- [x] Settings → PDF Raporları → FREE preview / PRO builder runtime route'larına canonical ACTION/Feature ID ve `FeatureAccessGuard` ile bağlı.
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
- [x] TR/EN backup UI state/copy contract; rollback sonucu typed.
- [x] Legacy v0 migrator; unknown birth time midnight'e uydurulmuyor.
- [x] Schema-v1 registry 15 logical CSV tablo içeriyor; `tarot_cards.csv` normalized standalone tablo.
- [x] Settings backup ekranı gerçek `BackupApplicationService` aksiyonlarıyla runtime'a bağlı; preview/merge/replace/cancel/invalid/rollback state'leri mevcut.
- [ ] Exact Backup CSV workflow SUCCESS görünür değil; ilgili RC'ler DONE değil.
- [ ] Android gerçek cihaz save/open/share smoke testi.
- [ ] Released historical backup fixture doğrulaması.
- [ ] `pubspec.lock` yalnız gerçek `flutter pub get` çözümlemesinden sonra commit edilmeli.

## Profesyonel PDF — source-level

- [x] Local A4 renderer/planning/snapshot identity/parity sözleşmesi.
- [x] PDF output structural inspector + table chunking + page safety.
- [x] Western vector geometry adapter source-level.
- [x] Numerology canonical snapshot → PDF data parity source-level.
- [x] Free sample preview / PRO professional export policy canonical Feature Catalog + action registry seviyesinde kilitli.
- [x] Free sample PDF hub/preview ve PRO builder Settings runtime UI'a bağlı.
- [x] Demo preview açıkça `Örnek Kişi — Demo Profil`; gerçek kullanıcı/danışan/kayıt verisinden ayrılmış.
- [x] `ProfessionalPdfApplicationService<TSnapshot>` exact selected record → guarded PRO service → PDF structural inspection zincirini kuruyor.
- [x] FREE kullanıcıda PDF delegate'in hiç çalışmadığını ve PRO kullanıcının exact snapshot/section order kullandığını doğrulayan test sözleşmesi var.
- [x] Builder UI `ProfessionalPdfBuildActions` üzerinden gerçek application action'a delege ediyor; canonical `ACTION-PDF-PREVIEW-CREATE` kullanıyor; production action yoksa sahte başarı göstermiyor.
- [x] Professional PDF application evidence + semantic MASTER RC ownership validator + ayrı CI contract mevcut.
- [ ] Production `ProfessionalPdfSnapshotSource` adapterı `RuhCodeRuntime` composition root'a bağlanmadı.
- [ ] Builder final UX'te ham record ID yerine typed saved-calculation selector kullanmalı.
- [ ] Native PDF save/share gateway application result bytes üzerine bağlanmalı.
- [ ] Production Unicode TR/EN font binary + lisans + immutable SHA.
- [ ] Western production vector painter + approved glyph assets.
- [ ] Vedik vector chart embedding; BaZi/Numerology production table renderers.
- [ ] 5/25/50+ real rendered page tests, parser/crop/glyph/visual regression.
- [ ] Exact PDF workflows görünür SUCCESS.

## Semantic evidence / UI quality

- [x] Merkezi semantic evidence validator Numeroloji, BaZi, PDF, Backup, Entitlement, terminology/interpretation ve Western astronomy ailelerini denetliyor.
- [x] Yanlış TODO-index→RC eşlemeleri birden fazla evidence ailesinde temizlendi.
- [x] Runtime action bindings registry + Feature Catalog Free/PRO parity ile çaprazlanıyor.
- [x] 48dp minimum touch target, Semantics labels, 2.0x critical navigation contract source-level.
- [x] Professional PDF create action canonical runtime binding setine eklendi.
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

## Son tur — 2026-08-22 03:22

Checkpoint: `automation_runs/2026-08-22_0322_professional_pdf_application_builder.md`

Öne çıkan işler:
- Professional PDF application service + strict selected-record boundary.
- Service-level canonical PRO guard + structural output inspection.
- PDF builder UI action abstraction ve gerçek build state.
- Canonical PDF create ACTION-ID runtime binding.
- Application + widget regression tests.
- Professional PDF evidence / semantic RC validator / CI contract.

GitHub combined-status exact workflow hedefi için görünür individual check sonucu oluşmadan SUCCESS iddiası yapılmayacak. Bu turun source-level evidence'i `done=false`; ilgili RC'ler DONE yapılmadı.

## Sıradaki çalışma

1. Production persisted calculation modelinden `ProfessionalPdfSnapshotSource` adapterı oluştur ve `RuhCodeRuntime` composition root'a bağla.
2. Builder'da ham record ID yerine typed saved-calculation selector hazırla.
3. Native PDF save/share application akışını bağla.
4. Requirement-bearing kalan evidence dosyalarını semantic RC ownership audit'e al.
5. Production font blocker gerektirmeyen PDF data/table/interaction testlerini genişlet.
6. Requirement state'i yalnız görünür test/workflow/evidence kanıtıyla yükselt.

## Final durumu

**FINAL DEĞİL.** RC-0001→RC-1442 tamamı ve zorunlu release kapıları gerçek kanıtla yeşil olmadan FINAL denmeyecek.
