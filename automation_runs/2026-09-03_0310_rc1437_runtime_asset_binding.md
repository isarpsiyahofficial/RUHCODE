# RUH CODE — RC-1437 runtime asset binding checkpoint

## Exact çalışma kapsamı

Bu checkpoint RC-0001→RC-1442 bağlayıcı kapsamını değiştirmez. `requirements/requirement_state.csv` değiştirilmedi; yalnız source veya validator eklenmesi hiçbir requirement'ı otomatik DONE yapmaz.

## Bu çalıştırmada yapılan gerçek değişiklikler

1. IERS `finals2000A.all` fiziksel asseti için Flutter runtime loader eklendi (`0302a2deb236be2450f7a63a146f328b77b351d8`). Loader packaged bytes üzerinde exact SHA-256 doğruluyor, fixed-width MJD/UT1-UTC alanlarını parse ediyor ve `BundledEarthOrientationProvider` üzerinden kapsama dışında fail-closed davranıyor.
2. Gerçek packaged IERS asset testi eklendi (`bc3c735ae7c64152fc742410d52cae5293422721`). Test rootBundle üzerinden fiziksel asseti açıyor, provenance SHA'sını, kullanılabilir coverage'ı ve out-of-range RangeError davranışını doğruluyor.
3. Exact `bc3c735...` CI'da Flutter Quality `unnecessary_import` nedeniyle fatal analyze kırmızısı verdi. Kök neden aynı turda giderildi (`1c5a9abf86f6a676721e8104d7c9899fb80ba083`).
4. Aynı exact SHA'da City Catalog Contract kırmızıydı. Kök neden fiziksel katalog `BUNDLED_VERIFIED` olduktan sonra validator'ın stale olarak yalnız `SOURCE_SELECTED_NOT_BUNDLED` kabul etmesiydi. Validator zayıflatılmadı; bunun yerine fiziksel catalog SHA/size, 200k+ JSONL kayıt, duplicate stable ID, coordinate range, timezone field, attribution asset ve pubspec asset binding doğrulamaları eklendi (`970094301fcb50d61e98f4d2f730bdf7efa58776`).
5. DE440s için fiziksel runtime integrity loader eklendi (`82cb7c9ca9e2e7764c66912cfed511a39701c50d`). Loader packaged `assets/data/ephemeris/de440s.bsp` dosyasını byte-size, `DAF/SPK` magic ve exact SHA-256 ile doğruluyor.
6. Gerçek packaged DE440s asset testi eklendi (`7727857bac78d22dab96585782e72638794a2adf`). Bu yalnız fiziksel/runtime bağını kanıtlar; SPK celestial evaluator veya bağımsız golden accuracy kanıtı değildir.
7. RC-1437 için fiziksel runtime-asset validator eklendi ve canonical camelCase manifest yapısına hizalandı (`e33fe596c743dc2d05aa6025ac1712f426f3a57b`, `2a35c8fb866289aa7818a998f10384eae6b87a53`). Validator fiziksel IERS/DE440s hash-size/header, evidence/manifest/pubspec/source/test bağlarını ve no-network/fail-closed kurallarını doğrular. DE440s `proven=false`, runtime computation integration=false ve independent golden=false şartlarını özellikle korur.
8. Ayrı `RC-1437 Runtime Assets` CI kapısı eklendi (`d718bed68661ca42c8a5227764196f7d885df556`).

## CI durumu

- `bc3c735...` üzerinde iki kırmızı kök neden çıkarıldı: Flutter analyzer stale import ve City Catalog stale status validator. İkisi de aynı çalıştırmada source seviyesinde düzeltildi.
- `d718bed68661ca42c8a5227764196f7d885df556` exact HEAD için 24 workflow tetiklendi. Son gözlemde completed failure sayısı 0'dı; koşular henüz tamamlanmadığı için green sayılmadı.

## RC-1437 gerçek durum

Fiziksel city catalog, IERS EOP ve DE440s artık tracked/bundled/checksummed durumda ve runtime asset binding'i önemli ölçüde ilerledi. Ancak RC-1437 bütünü DONE değildir. Özellikle:

- DE440s SPK evaluator'ın gerçek celestial state üretmesi ve independent golden vectors ile doğrulanması gerekiyor.
- Product range 1890→2110 ile IERS'in gerçek yayımlanmış EOP kapsamı aynı değildir; yayımlanmamış gelecek EOP uydurulamaz. Range dışı davranış/versioned model kanıtı final sözleşmeye bağlanmalı.
- Yeni packaged-asset testleri ve runtime validator exact HEAD üzerinde CI SUCCESS olmadan kanıt sayılmaz.

## Diğer açık release blokları

- RC-1439 canonical fiziksel UI reference image + screen ID + SHA-256 seti.
- Production signing secrets ile gerçek signed reproducible clean-checkout APK execution ve exact artifact evidence.
- Real-device airplane-mode/offline, accessibility, Play/rewarded ve PDF delivery kanıtları.
- Final exact RC-0001→RC-1442 lifecycle audit.

## Sonraki çalışma

1. `d718bed...` exact CI completion oku; kırmızı varsa kök nedeni düzelt.
2. DE440s evaluator + bağımsız golden-vector accuracy hattını dependency sırasıyla ilerlet.
3. RC-1439 ve real-device/release blockerlarından bağımsız ilerleyebilenleri paralel kapat.
4. Kanıtsız DONE ekleme ve zorunlu kapılar tamamlanmadan FINAL deme.

**FINAL: NO.**
