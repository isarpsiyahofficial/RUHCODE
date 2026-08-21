# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bu dosya tekrar eden geliştirme çalışmalarında güncel checkpoint'i tutar. Bağlayıcı kaynaklar `RUH_CODE_MASTER_INDEX.md`, şartname dosyaları ve `RUH_CODE_MASTER_TODO.md` dosyasıdır. `SOURCE_LEVEL_IMPLEMENTED` veya `[x]` burada yalnız kaynak/test sözleşmesinin mevcut olduğunu anlatır; requirement state ancak gerçek workflow/test/evidence kanıtıyla DONE olabilir.

## Ana kapsam

- MASTER: `RC-0001 → RC-1442`.
- Requirement traceability altyapısı mevcut; kanıtsız DONE yasak.
- Ana bilgi mimarisi: `Bugün · Araçlar · Kayıtlar · Profil`.
- Araçlar: Astroloji / Numeroloji / Spiritüel / Kişisel Gelişim; Astroloji altında Batı / Vedik / Çin / BaZi / Gezegen Saatleri ayrı.
- Canonical SCREEN-ID / ACTION-ID / Feature-ID sözleşmeleri mevcut.
- APPROVED final UI PNG/reference seti henüz tamamlanmadı; visual regression final kapısı bu nedenle açık.

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
- [x] PDF policy netleştirildi: `pdf.sample_preview` FREE; `pdf.professional_export` PRO.
- [x] `ui/action_registry.csv` PDF policy ile hizalandı: `PDF Raporları` hub FREE, `Örnek PDF Önizle` FREE, gerçek profesyonel üretim/paylaşım PRO.
- [x] Ayrı `PDF Entitlement Contract` validator + CI workflow eklendi.
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
- [x] Schema-v1 registry artık 15 logical CSV tablo içeriyor.
- [x] `tarot_cards.csv` RC-0788 için standalone normalized tablo: `session_id → tarot_sessions.id`, `position_index`, `card_id`, `upright/reversed` orientation.
- [x] Yeni writer `tarot_cards.csv` dosyasını her zaman üretir.
- [x] Eski schema-v1 package dosyayı içermiyorsa geriye uyumlu biçimde explicit boş tarot-card tablosu materialize edilir; diğer eksik üyeler hata kalır.
- [x] Full SQLite all-table lifecycle fixture artık 15/15 non-empty; tarot card gerçek session'a bağlı ve raw table equality restore sonrası karşılaştırılır.
- [x] Backup schema/full-lifecycle evidence + validators ve semantic RC traceability RC-0788'e genişletildi.
- [ ] Exact Backup CSV workflow SUCCESS görünür değil; RC-0788 dahil ilgili RC'ler DONE değil.
- [ ] Android gerçek cihaz save/open/share smoke testi.
- [ ] Released historical backup fixture bulunduğunda gerçek fixture doğrulaması.
- [ ] `pubspec.lock` yalnız gerçek `flutter pub get` çözümlemesinden sonra commit edilmeli.

## Profesyonel PDF — source-level

- [x] Local A4 renderer/planning/snapshot identity/parity sözleşmesi.
- [x] PDF output structural inspector + table chunking + page safety.
- [x] Western vector geometry adapter source-level.
- [x] Numerology canonical snapshot → PDF data parity source-level.
- [x] Free sample preview ve PRO professional export ayrımı canonical feature + action registry seviyesinde kilitli.
- [ ] Free sample PDF hub/preview ve PRO builder gerçek Settings runtime UI'a bağlanmalı.
- [ ] Production Unicode TR/EN font binary + lisans + immutable SHA.
- [ ] Western production vector painter + approved glyph assets.
- [ ] Vedik vector chart embedding; BaZi/Numerology production table renderers.
- [ ] 5/25/50+ real rendered page tests, parser/crop/glyph/visual regression.
- [ ] Exact PDF workflows görünür SUCCESS.

## Semantic evidence / UI quality

- [x] Merkezi semantic evidence validator Numeroloji, BaZi, PDF, Backup ve Entitlement ailelerini denetliyor.
- [x] Backup schema evidence artık literal MASTER `RC-0788 tarot_cards.csv` sahipliğini de kontrol ediyor.
- [x] Runtime action bindings registry + Feature Catalog Free/PRO parity ile çaprazlanıyor.
- [x] 48dp minimum touch target, Semantics labels, 2.0x critical navigation contract source-level.
- [ ] Kalan evidence ailelerini semantic RC drift açısından taramaya devam et.
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

## Son tur — 2026-08-22 00:54

Checkpoint: `automation_runs/2026-08-22_0054_pdf_policy_tarot_backup.md`

Öne çıkan commitler:
- `bae8b2e64d4000cec99d58fa4f0e88c64871643f` PDF action Free/PRO policy düzeltmesi
- `b3a5a85be52564d27a7489ee7ab80781377c4a00` PDF entitlement validator
- `2b3dcab2235104d1a891836c5865c007c54a5e2b` PDF entitlement CI
- `b1e9648630f398c3462c4beaaca17a182215e105` tarot_cards schema
- `08907e8af38bcb7d41629418a2900f9294019bf4` schema-v1 additive compatibility reader
- `743b9f3043b367210ef382b1f297d8cb84dabf09` backup schema tests
- `3aecb130bf4c13891b91725b9bdf8cdd825b5513` old-v1 package compatibility test
- `a0e65047bdc0a6f151adb0bce21d90d10134c748` RC-0788 evidence
- `fbe9fbfdf71f44de9947799304a8a5be23c5f20c` semantic traceability extension
- `fc14a56000fb3a2613332148276a6758301f2c0a` 15-table SQLite lifecycle fixture
- `89578d6795dded5ad285d297733f59e19092fc45` lifecycle evidence update
- `2396707c7555b33ac68639695e2024d3263216c0` lifecycle validator update

GitHub combined-status son exact source commit için yine `statuses=[]` döndürdü. SUCCESS uydurulmadı ve bu turdaki RC'ler DONE yapılmadı.

## Sıradaki çalışma

1. PDF sample preview FREE / professional builder PRO ayrımını gerçek Settings runtime UI ve canonical ACTION bindings'e bağla.
2. Exact Backup CSV / PDF Entitlement workflow sonucu görünürse kırmızıları aynı turda düzelt.
3. Kalan evidence ailelerinde semantic RC ownership drift taramasını sürdür.
4. Blocker gerektirmeyen UI/backup/PDF/accessibility işlerini ilerlet.
5. Requirement state'i yalnız görünür test/workflow/evidence kanıtıyla yükselt.

## Final durumu

**FINAL DEĞİL.** RC-0001→RC-1442 tamamı ve zorunlu release kapıları gerçek kanıtla yeşil olmadan FINAL denmeyecek.
