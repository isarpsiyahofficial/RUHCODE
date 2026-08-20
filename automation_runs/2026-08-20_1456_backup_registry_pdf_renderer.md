# Ruh Code automation checkpoint — 2026-08-20 14:56

## Bu turda gerçekten değişenler

### Backup / UI action sözleşmesi

- Primary `ui/action_registry.csv` içindeki kullanıcıya görünen eski `CSV Dışa Aktar` etiketi `Tam Yedek Oluştur` olarak değiştirildi.
- Primary `ui/action_registry.csv` içindeki kullanıcıya görünen eski `CSV İçe Aktar` etiketi `Yedekten Geri Yükle` olarak değiştirildi.
- Effect/route sözleşmeleri korunuyor: export hâlâ tam portable backup üretir; import dedicated restore ekranına gider.
- Bu iki akış OFFLINE/AVAILABLE olarak kalır.
- `tools/ui/validate_backup_action_labels.py` eklendi. Eski CSV-only wording yeniden girerse CI kırılır.
- `.github/workflows/ui-contracts.yml` bu validator'ı çalıştıracak şekilde genişletildi.

### Profesyonel PDF — local byte renderer

- `pdf: ^3.13.0` dependency'si eklendi. `pubspec.lock` henüz üretilmedi; lockfile elle uydurulmayacak.
- `PdfLocalRenderer` eklendi. PDF üretimi yerel `pw.Document` / `pw.MultiPage` üzerinden yapılır.
- A4 boyut/margin değerleri mevcut `PdfReportPlan` sözleşmesinden gelir.
- Her render section aynı exact calculation snapshot SHA-256 kimliğine ait olmak zorunda.
- Plan dışında, unavailable, empty veya cross-snapshot section render edilmez.
- Çıktının `%PDF-` imzasıyla başladığı kontrol edilir.
- Page number footer yerel üretilir.
- 50+ sayfa şartıyla çakışan varsayılan MultiPage sınırına güvenilmedi; explicit `maxReportPages = 200` eklendi.
- Section heading orphan riskini azaltmak için `NewPage(freeSpace: 72)` ve heading + ilk paragraf `Inseparable` sözleşmesi eklendi.

### PDF font güvenliği

- `PdfFontBundle` gerçek regular/bold byte'larını SHA-256 ile doğrular; family ve license ID zorunludur.
- `PdfAssetFontBundleProvider` eklendi; yalnız `tr` ve `en` için explicit asset spec kabul eder.
- TR ve EN spec'lerinin ikisi de yoksa provider kurulamaz.
- Asset byte'ları load edildikten sonra immutable SHA-256 ile yeniden doğrulanır.
- Henüz production font binary'si eklenmedi. Bu nedenle Unicode font gereksinimi DONE değildir.

### PDF application service

- `PdfLocalReportService<TSnapshot>` mevcut `PdfService<TSnapshot>` sözleşmesine bağlandı.
- Content adapter → dataset validation → report planning → font load → local byte renderer tek zincirde toplandı.
- Adapter origin ile dataset origin uyuşmazsa render reddedilir.

### Test / evidence / structural gates

- Local renderer contract tests eklendi.
- İlk test implementasyonunda Dart'ta geçersiz `'0' * 64` ifadesi fark edildi ve `List<String>.filled(64, '0').join()` ile düzeltildi.
- Asset font provider tests eklendi: TR+EN coverage, duplicate locale, tampered SHA, verified load.
- `evidence/pdf/local_renderer_contract.json` eklendi ve bilinçli olarak `done=false` tutuldu.
- `tools/pdf/validate_pdf_report_contract.py` local renderer, application service, font provider, tests ve pagination safeguards'ı source-level contract olarak doğrular.
- Mevcut `pdf-contract.yml` zaten `lib/src/pdf/**`, `test/pdf/**`, `evidence/pdf/**`, `tools/pdf/**`, `pubspec.yaml` ve `pubspec.lock` değişikliklerinde `flutter pub get` + `flutter test test/pdf` çalıştırır.

## Bu turda DONE yapılmayanlar

- Production Unicode TR/EN font binary + OFL/lisans dosyası + immutable SHA manifesti.
- Gerçek fontlarla byte-render testi.
- 5 / 25 / 50+ gerçek page-count testleri ve low-memory test.
- PDF parse/open, missing glyph, crop ve visual regression.
- Western/Vedic vector chart PDF adapterları.
- BaZi/Numerology table rendererları.
- Free sample PDF APPROVED reference + demo-only end-to-end wiring.
- `pubspec.lock`.
- Exact GitHub Actions SUCCESS kanıtı.

## Exact CI durumu

Son UI workflow hedef commit'i için connector combined-status `statuses=[]` döndürdü. Bu nedenle SUCCESS varsayılmadı ve hiçbir ilgili RC yapay biçimde DONE yapılmadı.

## Bu turdaki ana commitler

- `7d8f23e0491f3a0821eafc47a7ea2ef89f9ca3e0` — local PDF dependency
- `fe74cf58b8dccca48b23023ca240bc115468e15e` — local PDF byte renderer
- `93f7a19079b9ad97daf6dd04e6d007dc754ca11d` — portable backup action labels
- `88666955fdb9adb3e485067b05b848185e23a390` — renderer contract tests
- `3068f19619cdb89dea0cab35aca30ce501cab69f` — renderer evidence
- `b0e5aa4ee3dd4fec91a94db91262bb47db61c742` — renderer structural validation
- `84d0c173a04bf85bde83d127249e6fa6030fabad` — backup action wording validator
- `ccae7354789833171f88fe03d9c64eb7e7a4d052` — UI CI wiring
- `60d5c317410a091893763e3f5330e1c7ee351b30` — PDF local report service
- `953553628f38a92985749ec124ca6303651f10e9` — verified asset font provider
- `d22ea908ecf195f954745a568913896d30a7e48d` — renderer test syntax fix
- `11c70e0191740fc0166dfabc31365a148d215c4f` — font provider tests
- `2a27c425ae7ed04e497a5acbd11a59f22de4c49e` — service/font validator expansion
- `2ab7e9cfa60986dd9ba4cb46a430c0a6b46657fb` — long-report pagination safeguards
- `aa0a37c5aa2d760fa7e17af3be6e9a5478112712` — pagination evidence
- `06de5176e2bf4f114d22864e9ed2e7a0f2657b87` — pagination structural gate

## Sıradaki güvenli işler

1. Exact CI görünür olursa kırmızıyı aynı turda düzelt; görünmüyorsa SUCCESS uydurma.
2. Approved Unicode TR/EN font asset + license + SHA-256 manifestini fiziksel artifact ile bağla; binary yoksa blocker'ı açık tut.
3. Gerçek fontla 5/25/50+ PDF byte generation ve parse/open testlerini kur.
4. Section/table pagination ve crop/missing-glyph regression'ını genişlet.
5. Western/Vedic dynamic vector geometry'yi aynı calculation snapshot üzerinden PDF adapterına bağla.
6. BaZi/Numerology tablolarını gerçek PDF layout'a bağla.
7. `pubspec.lock` yalnız gerçek `flutter pub get` çözümlemesinden sonra commit et.
8. Paralelde physical astronomy/GeoNames/8.036 günlük mesaj/APPROVED UI reference blocker dışı işlere devam et.

**FINAL DEĞİL.**
