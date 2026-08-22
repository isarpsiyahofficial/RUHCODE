# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında güncel checkpoint'i tutar. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. `SOURCE_LEVEL_IMPLEMENTED` veya `[x]` burada yalnız kaynak/test sözleşmesinin mevcut olduğunu anlatır; requirement state ancak gerçek workflow/test/evidence kanıtıyla DONE olabilir.

## Ana kapsam

- MASTER: `RC-0001 → RC-1442`.
- Requirement traceability altyapısı mevcut; kanıtsız DONE yasak.
- `requirement_state.csv` sparse override dosyasıdır; 1.442 satırlık matrix `build_requirement_matrix.py` ile şartnameden üretilir.
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
- [x] Western astronomy evidence RC sahiplikleri MASTER ile yeniden denetlendi; yanlış TODO-index→RC eşlemeleri temizlendi.
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
- [x] Settings → PDF Raporları → FREE preview / PRO builder gerçek runtime route'larına canonical ACTION/Feature ID ve `FeatureAccessGuard` ile bağlandı.
- [x] Runtime action bindings ve Free/PRO widget route matrisi genişletildi.
- [x] PDF Entitlement validator runtime bindingleri ve demo-data isolation marker'larını zorunlu kılıyor.
- [x] UI / PDF Entitlement / Feature Entitlement workflow kapsamı `lib/src/ui/pdf/**` ve runtime route testlerini içeriyor.
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
- [x] Schema-v1 registry 15 logical CSV tablo içeriyor.
- [x] `tarot_cards.csv` RC-0788 standalone normalized tablo.
- [x] Eski schema-v1 package additive `tarot_cards.csv` eksikliğini boş tablo olarak materialize edebiliyor; diğer eksik üyeler hata kalıyor.
- [x] Full SQLite all-table lifecycle fixture 15/15 non-empty.
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
- [x] Free sample PDF hub/preview ve PRO builder gerçek Settings runtime UI'a bağlandı.
- [x] Demo preview açıkça `Örnek Kişi — Demo Profil` ve gerçek kullanıcı/danışan/kayıt verisinden ayrılmış içerik olarak işaretlendi.
- [ ] Runtime professional builder henüz gerçek guarded PDF application service'e bağlanmadı; route var olması export DONE değildir.
- [ ] Production Unicode TR/EN font binary + lisans + immutable SHA.
- [ ] Western production vector painter + approved glyph assets.
- [ ] Vedik vector chart embedding; BaZi/Numerology production table renderers.
- [ ] 5/25/50+ real rendered page tests, parser/crop/glyph/visual regression.
- [ ] Exact PDF workflows görünür SUCCESS.

## Semantic evidence / UI quality

- [x] Merkezi semantic evidence validator Numeroloji, BaZi, PDF, Backup ve Entitlement ailelerini denetliyor.
- [x] Terminology evidence'daki yanlış `RC-0539/0540/0541` sahiplikleri kaldırıldı; gerçek `RC-1059→1065` ile kilitlendi.
- [x] Interpretation claim/quality evidence merkezi semantic ownership validator'a bağlandı.
- [x] Western astronomy evidence aileleri semantic validator'a bağlandı; yanlış `RC-026x/027x` TODO-index kaymaları temizlendi.
- [x] Backup schema evidence literal MASTER `RC-0788 tarot_cards.csv` sahipliğini kontrol ediyor.
- [x] Runtime action bindings registry + Feature Catalog Free/PRO parity ile çaprazlanıyor.
- [x] 48dp minimum touch target, Semantics labels, 2.0x critical navigation contract source-level.
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

## Son tur — 2026-08-22 02:54

Checkpoint: `automation_runs/2026-08-22_0254_pdf_runtime_semantic_traceability.md`

Öne çıkan işler:
- Settings PDF runtime wiring + canonical ACTION/Feature guards.
- Free/PRO PDF widget route tests.
- UI/PDF/Entitlement workflow kapsam genişletmesi.
- Demo person/data isolation marker ve validator.
- Terminology + interpretation semantic evidence audit.
- Western astronomy evidence RC ownership audit ve toplu drift düzeltmesi.

GitHub combined-status exact HEAD için yine `statuses=[]` döndürdü. Container clean-clone denemesi de `github.com` DNS çözümleme hatasıyla başarısız oldu. SUCCESS uydurulmadı ve bu turdaki RC'ler DONE yapılmadı.

## Sıradaki çalışma

1. Requirement-bearing kalan evidence dosyalarını semantic RC ownership audit'e al.
2. Professional PDF builder'ı gerçek guarded PDF application service'e bağla.
3. Settings backup aksiyonlarını mevcut `BackupApplicationService` ile gerçek runtime'a bağla; cancel/success/invalid-preview/rollback state'lerini göster.
4. Exact Actions sonuçları görünürse Requirements/UI/PDF Entitlement/Feature Entitlement kırmızılarını aynı turda düzelt.
5. Blocker gerektirmeyen UI/backup/PDF/accessibility işlerini ilerlet.
6. Requirement state'i yalnız görünür test/workflow/evidence kanıtıyla yükselt.

## Final durumu

**FINAL DEĞİL.** RC-0001→RC-1442 tamamı ve zorunlu release kapıları gerçek kanıtla yeşil olmadan FINAL denmeyecek.