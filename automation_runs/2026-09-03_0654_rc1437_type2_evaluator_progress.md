# RUH CODE — RC-1437 Type-2 Evaluator Progress

## Baseline yeniden doğrulama

- Bağlayıcı kaynaklar ve `RUH_CODE_AUTOMATION_PROGRESS.md` yeniden okundu.
- Previous parser baseline `40da4cad02cb1e4c5fe2c16f6cc94de3e6a07045` için 25 workflow bulundu.
- Bu baseline'da City Catalog Contract RED idi. Decoded job log kök nedeni açıkça gösterdi: fiziksel bundled city catalog `pubspec.yaml` içinde `assets/data/cities/` dizin declaration ile geçerli biçimde bağlı olmasına rağmen validator yalnız literal generated file path arıyordu.

## Bu çalıştırmada gerçek uygulanan işler

1. `lib/src/calculation_core/ephemeris/spk_type2_evaluator.dart` eklendi.
   - SPK Type-2 trailer (`INIT`, `INTLEN`, `RSIZE`, `N`) fail-closed parse edilir.
   - DAF 1-based word addressing fiziksel byte sınırlarıyla doğrulanır.
   - Exact record seçimi ve right-endpoint son-record davranışı uygulanır.
   - MID/RADIUS ve Chebyshev coefficient yapısı doğrulanır.
   - Clenshaw ile X/Y/Z position hesaplanır.
   - Chebyshev türevi üzerinden vx/vy/vz km/s hesaplanır.
   - Unsupported SPK type, kapsama dışı ET, bozuk directory/record/coefficients sessiz fallback olmadan reddedilir.
   - Direct target/center segment seçiminde file-order son matching segment önceliği korunur.

2. `test/calculation_core/spk_type2_evaluator_test.dart` eklendi.
   - Deterministic synthetic Type-2 payload ile position/velocity matematiği doğrulanır.
   - Exact right endpoint davranışı test edilir.
   - Out-of-coverage ve unsupported type fail-closed test edilir.

3. `test/calculation_core/de440s_type2_runtime_test.dart` eklendi.
   - Gerçek packaged DE440s yüklenir.
   - Gerçek DAF index içinden J2000'ı kapsayan Type-2 segment seçilir.
   - Fiziksel kernel üzerinde gerçek numerical evaluation yapılır.
   - Altı state bileşeninin finite olduğu ve forbidden zero/default state'e çökmediği doğrulanır.
   - Bu test independent accuracy golden değildir; RC-1437 DONE anlamına gelmez.

4. `.github/workflows/rc1437-runtime-assets.yml` sertleştirildi.
   - Physical astronomy asset validator sonrası Flutter 3.44.7 kurulur.
   - Synthetic Type-2 evaluator contract testi çalışır.
   - Real packaged DE440s Type-2 runtime testi çalışır.

5. `tools/location/validate_city_catalog_contract.py` düzeltildi.
   - Exact file declaration veya containing-directory Flutter asset declaration kabul edilir.
   - Physical SHA-256, byte-size, 235k+ records, unique stable IDs, coordinates, timezone ve attribution kontrolleri korunur.
   - Önceki City Catalog false-negative kök nedeni kapanır.

## Commit zinciri

- `dda4106a1ff861e19491bb522baefced1e4d9dd8` — SPK Type-2 evaluator
- `91d54d07f437757106954bb5eb12decd868b908b` — deterministic evaluator tests
- `89de69cf6aca929c1bca8a497ecde8d3052d0361` — real packaged DE440s Type-2 runtime test
- `d6dfcb3f31b7b7a965f5f544d3a3162e429a81a6` — dedicated RC-1437 runtime CI execution
- `d9ac37b0a043d82f781fbd1596a3ae326a480f35` — City Catalog directory-asset validator repair

## Kanıt sınırı

- `planetaryEphemeris.proven` değiştirilmedi.
- `requirements/requirement_state.csv` değiştirilmedi.
- Numerical evaluator source + synthetic math + real packaged runtime execution eklendi; fakat independent external golden vectors ve body/center chaining henüz eksik.
- RC-1437 bu nedenle DONE değildir.
- RC-1439, production-signed reproducible artifact, real-device/offline/accessibility/PDF/Play ve final 1,442-RC lifecycle audit açık kalır.

## Sonraki dependency

1. Exact current HEAD CI sonuçlarını oku ve yeni Type-2/runtime/City gate kırmızısı varsa aynı turda düzelt.
2. SPK body/center graph chaining ekle; cycle/missing-center/unsupported-frame durumlarını fail-closed ele al.
3. Independent golden vectors (NAIF/JPL referansı veya bağımsız hesaplama çıktısı) ve RC-1436 tolerance evidence eklemeden `proven=true` yapma.
4. Sonrasında strict RC-1437 release manifesti ve diğer bağımsız blockerları ilerlet.

**FINAL: NO.**
