# Ruh Code — Flutter 3-Failure Repair + APK Packaging Green Checkpoint

## Bağlayıcı kapsam

- `RUH_CODE_MASTER_TODO.md`, `RUH_CODE_MASTER_INDEX.md` ve RC-0001→RC-1442 bağlayıcı kapsamı yeniden esas alındı.
- `RUH_CODE_AUTOMATION_PROGRESS.md` ve `requirements/requirement_state.csv` yeniden okundu.
- Sparse requirement override ledger değiştirilmedi; kanıtsız DONE eklenmedi.

## Exact completed Flutter Quality baseline

Exact HEAD: `5283cc2381fbf850f86c85cb458f96a6b8250f45`

- workflow run/job: `33574223425 / 100074533697`
- Flutter: `3.44.7`
- `flutter analyze --fatal-infos`: **SUCCESS — No issues found**
- `flutter test --reporter expanded`: **FAILURE**
- exact final summary: **`+590 -3`**
- diagnostic artifact: `9826177189`

Exact üç failure:

1. `test/ui/backup/backup_accessibility_test.dart`
   - canonical production semantics label `Mevcut Verilerle Birleştir` iken test stale kısa `Birleştir` bekliyordu.
   - aynı drift replace için de `Değiştir` vs `Mevcut Verileri Değiştir` idi.
2. `test/ui/backup/backup_runtime_wiring_test.dart`
   - rollback-failed production mapping doğruydu; test `pumpAndSettle()` ile Snackbar yaşam döngüsünü tamamen ilerletip mesajı auto-dismiss sonrasında arıyordu.
3. `test/ui/accessibility_text_scale_test.dart`
   - 2.0x text scale altında `Profesyonel PDF Oluştur` canonical action'ı PDF hub ListView viewport'unun dışındaydı; test scrolling yapmadan text'i görünür kabul ediyordu.

## Bu tur uygulanan repair commitleri

- `c2b0464a55804a7ffbfeaf2310518d5326fa46cd` — backup restore semantics expectations production canonical full labels ile hizalandı; 48dp ve focus-order kontrolleri korunuyor.
- `fe19eb70383420ca4fd0e989254f50d150142f9c` — rollback-failed Snackbar testinde auto-dismiss sonrasını bekleyen `pumpAndSettle` kaldırıldı; mesaj görünür animasyon aralığında doğrulanıyor.
- `c466306bc9f33010ee4f15c5355eee6ace434216` — 2.0x PDF hub testi `RuhActionIds.pdfBuild` canonical action'ını gerçek Scrollable içinde görünür hale getirip sonra doğruluyor.

Hiçbir production quality threshold, entitlement guard, backup rollback semantics veya accessibility contract gevşetilmedi.

## Daily Message APK Packaging — exact SUCCESS

Aynı completed exact source HEAD `5283cc2381fbf850f86c85cb458f96a6b8250f45` üzerinde:

- workflow run/job: `33574223584 / 100074534089`
- release APK build: **SUCCESS**
- APK size: **53.2 MB**
- validator: **SUCCESS**
- packaged asset prefix: `assets/flutter_assets/assets/content/daily_messages`
- TR: **4018 / 4018**
- EN: **4018 / 4018**
- missing exact date+locale: **0**
- duplicate exact date+locale: **0**
- validator errors: **0**
- date range: `2026-01-01 → 2036-12-31`
- TR schema rows: canonical `2495`, legacy-normalized `1523`
- EN schema rows: canonical `2495`, legacy-normalized `1523`
- shards: TR `131`, EN `131`
- APK SHA-256: `2720059bf969681f67e119cd7cf1185e41914224613f74dffcd75fc328d63948`
- evidence artifact: `9826254630`
- artifact ZIP SHA-256: `9f8587e256efc3ce30d158cbd1081d16b21233e29e1551fe039f208fdc018fe9`

Bu kanıt source-level katalog kontrolü değildir; gerçek `app-release.apk` ZIP içindeki packaged Flutter assetleri üzerinden yapılmıştır.

### Önemli release sınırı

Bu APK kanıtındaki Android host hâlâ clean checkout sırasında generated `build.gradle.kts` hosttur (`android_host=generated-build.gradle.kts`). Bu nedenle tracked/signable production Android host, signed reproducible release ve real-device offline proof hâlâ açık kapılardır. APK packaging SUCCESS tek başına ilgili RC'leri FINAL/DONE yapmaz.

## Yeni verification durumu

Source repair HEAD `c466306bc9f33010ee4f15c5355eee6ace434216` için 25 GitHub check oluşturuldu. Checkpoint anında `analyze-and-test` dahil runlar queued durumda olduğundan üç repair **henüz CI-green sayılmadı**.

## Sıradaki bağımlı işler

1. `c466306...` veya sonraki documentation HEAD üzerinde Flutter Quality completed sonucunu oku.
2. Kırmızıysa yeni diagnostic logdan gerçekten kalan failure'ı kapat; yeşilse exact run/job/artifact evidence kaydet.
3. Daily Message APK packaging artık exact green olduğundan sonraki Daily Message kapısı real offline/airplane-mode cihaz lookup kanıtıdır.
4. Paralelde tracked/signable Android host, production signing, physical ephemeris/EOP/font/UI-reference/device ve clean-checkout lifecycle kapılarını bağımlılık sırasıyla ilerlet.
5. RC-0001→RC-1442 tamamı kanıtlı DONE ve final exact signed release artifact doğrulanmadan FINAL deme.

**FINAL: NO.**