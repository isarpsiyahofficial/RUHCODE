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
- [x] Production `LocalDatabaseProfessionalPdfSnapshotSource` calculation + CalculationManifest'i aynı transaction içinde okuyup fail-closed davranıyor.
- [x] `RuhCodeRuntime` persisted calculation PDF source'u composition root içinde oluşturuyor/expose ediyor.
- [x] Typed saved-calculation catalog (`ProfessionalPdfRecordCatalog` → `ProfessionalPdfCatalogActions`) production startup'ta UI boundary'ye tek kez bağlanıyor.
- [x] Builder ham record ID alanını kaldırdı; typed `Kayıtlı Hesaplama` selector kullanıyor.
- [x] `PersistedCalculationPdfRouter` exact calculation-type handler routing sağlıyor; unknown/duplicate/empty registry fail-closed.
- [x] Native PDF Save As/share gateway ve delivery service source-level; cancellation/unavailable typed.
- [x] `ProfessionalPdfDeliveryActions` / `ProfessionalPdfDeliveryUiActions` verified delivery zincirini UI-safe sonuçlara taşıyor.
- [x] Builder doğrulanmış PDF sonrası, delivery gerçekten bağlıysa canonical share kontrolü gösteriyor; exact record/section seçimi korunuyor.
- [x] Share dismissal normal cancellation UI durumu; sahte hata/sahte başarı yok.
- [x] Share control Semantics + 48dp minimum target taşıyor; create/share runtime action bindings structural CI'a bağlı.
- [x] Professional PDF application evidence + semantic MASTER RC ownership validator + ayrı CI contract yeni source/testleri kapsıyor.
- [x] Professional PDF application evidence merkezi semantic traceability audit'e dahil edildi.
- [ ] Persisted calculation type'lar için gerçek production report handler composition tamamlanmalı.
- [ ] Production build-side `ProfessionalPdfApplicationActions` ve delivery binding yalnız gerçek local renderer + approved font provider ile runtime'a bağlanmalı; fake/demo build yasak.
- [ ] Production Unicode TR/EN font binary + lisans + immutable SHA.
- [ ] Western production vector painter + approved glyph assets.
- [ ] Vedik vector chart embedding; BaZi/Numerology production table renderers.
- [ ] 5/25/50+ real rendered page tests, parser/crop/glyph/visual regression.
- [ ] Android/iOS real-device PDF Save As/share smoke evidence.
- [ ] Exact PDF workflows görünür SUCCESS.

## Semantic evidence / UI quality

- [x] Merkezi semantic evidence validator Numeroloji, BaZi, PDF, Backup, Entitlement, terminology/interpretation ve Western astronomy ailelerini denetliyor.
- [x] `requirements[]` ve `requirement_ids[]` evidence formatları merkezi semantic audit'te destekleniyor.
- [x] Professional PDF application evidence exact RC seti global semantic audit'e eklendi.
- [x] Yanlış TODO-index→RC eşlemeleri birden fazla evidence ailesinde temizlendi.
- [x] Runtime action bindings registry + Feature Catalog Free/PRO parity ile çaprazlanıyor.
- [x] 48dp minimum touch target, Semantics labels, 2.0x critical navigation contract source-level.
- [x] Professional PDF create ve share action'ları canonical runtime binding setinde.
- [ ] Historical `ACTION-PDF-PREVIEW-SHARE` source-screen terminolojisini builder/preview semantic ayrımıyla temizle; RC-1440 final audit öncesi ayrı canonical ID gerekebilir.
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

## Son tur — 2026-08-22 08:53

Checkpoint: `automation_runs/2026-08-22_0853_pdf_share_ui_contract.md`

Öne çıkan işler:
- professional PDF delivery UI abstraction
- runtime build/delivery fallback sınırı
- verified builder → native share action
- share success/cancel widget regressions
- UI delivery adapter safe-filename regression
- create/share runtime action binding parity
- professional PDF evidence/validator/CI hardening
- ilk adapter implementasyonundaki named `request:` hatası aynı turda yakalanıp düzeltildi

Workflow/test-source commit `bc964feb18f2de998127e0ba292208027bb72d2d` için GitHub combined-status `statuses=[]`; source-level evidence `done=false`, ilgili RC'ler DONE değil.

## Sıradaki çalışma

1. PDF action registry preview/builder semantic action ayrımını güvenli full-registry edit ortamında canonical ID ile çöz.
2. Production font blocker'ından bağımsız PDF table/page/parity regressionlarını genişlet.
3. Western persisted snapshot için açık versioned persistence schema tasarla; mevcut olmayan eski payload şeması varmış gibi davranma.
4. Requirement-bearing kalan evidence dosyalarını semantic RC ownership audit'e al.
5. Fiziksel ephemeris/EOP/Lahiri/GeoNames, 8.036 günlük mesaj, APPROVED UI refs, production PDF fonts ve clean-checkout lockfile blocker'larını açık tut.
6. Requirement state'i yalnız görünür test/workflow/evidence kanıtıyla yükselt.

## Final durumu

**FINAL DEĞİL.** RC-0001→RC-1442 tamamı ve zorunlu release kapıları gerçek kanıtla yeşil olmadan FINAL denmeyecek.
