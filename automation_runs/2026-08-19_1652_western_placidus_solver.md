# Ruh Code automation checkpoint — Western Placidus solver

## Bu turda yapılan gerçek işler

- Placidus artık yalnız tanım/contract değil; `lib/src/calculation_core/western/placidus_houses.dart` altında source-level solver olarak uygulanmıştır.
- İlk genel fixed-point yaklaşımı nihai kabul edilmemiştir. Resmî Placidus referans davranışı yeniden incelenmiş ve solver, semidiurnal/seminocturnal tanımın kullandığı pole-height iterasyonuna göre bağımsız biçimde yeniden yazılmıştır.
- Solver `maxIterations = 100` sınırına sahiptir; convergence olmadan cusp üretmez.
- Polar-circle dışı/gerçek-domain dışı geometri `UNAVAILABLE` döndürür; uydurma cusp yoktur.
- Porphyry fallback yalnız `PlacidusFallbackPolicy.explicitPorphyry` ile çağrılır ve `requestedSystem=PLACIDUS`, `effectiveSystem=PORPHYRY` metadata’sında görünür. Sessiz fallback yoktur.
- 12 cusp, angular cusplar ve karşıt cusp invariants ile üretilir; non-monotonic ecliptic geometry kabul edilmez.
- Normal enlem, exact-cusp house assignment, polar unavailable, explicit Porphyry fallback ve invalid-latitude testleri eklendi.
- Evidence manifest `SOURCE_LEVEL_IMPLEMENTED` durumuna yükseltildi; `done=false` korunuyor.
- Structural validator artık gerçek solver/test dosyalarını, 100-iteration ceiling’i, pole-height solver tokenlarını ve açık DONE blocker’larını doğruluyor.
- CI workflow artık validator yanında gerçek Flutter Placidus test dosyasını da çalıştıracak şekilde genişletildi.

## Referans ilkeleri

Resmî Swiss Ephemeris house-system dokümantasyonu Placidus 11/12/2/3 cusplarını semidiurnal/seminocturnal arc fractions ile tanımlar; resmî kaynak/Programmer’s Manual yüksek enlem convergence/polar sınırını ve 100 iteration ceiling davranışını gösterir. Ruh Code bunları doğrulama referansı olarak kullanır; Swiss Ephemeris runtime dependency değildir ve kaynak kodu doğrudan kopyalanmamıştır.

Referanslar:
- https://www.astro.com/swisseph/swisseph.htm
- https://www.astro.com/swisseph/swephprg.htm
- https://github.com/aloistr/swisseph

## Commit zinciri

- `ed8f7cd6353f2c7ccacbdecf6b5cc0d385a6678a` — ilk strict solver iskeleti
- `7d1cb7273fb91b6abc605a06176f3b0f56c759f8` — convergence/fallback testleri
- `73716d339fbb05371257683f059eab7d2fee43b4` — evidence source-level state
- `dde64670c9ec241a97030e2c7e69ff3e3160775f` — validator
- `15c02933719085e7b575f2e785759026856f3a52` — Flutter CI test gate
- `5648eb059508e2dcb0ab2bce4298dc421cc3d7ea` — Dart typing/convergence hardening
- `131ac77a2689ec81e934871c838258ba1a41ccdc` — pole-height iteration correction
- `e890edb92e9056ab452d85da17ce57c62197acb4` — validator correction

## DONE olmayanlar / açık kanıtlar

- Independent ASC/MC + Placidus golden reference dataset henüz yok; 0.05° budget kanıtlanmadı.
- Fiziksel/versioned IERS EOP + time-scale provenance eksik.
- Exact latest Flutter/GitHub Actions SUCCESS görünür değil; combined status endpoint yine individual status göstermiyor.
- Bu nedenle `RC-0054`, `RC-0265` ve ilişkili accuracy requirement’ları DONE yapılmadı.

## Sonraki güvenli sıra

1. Placidus/ASC/MC için bağımsız golden dataset ingest formatını gerçek house-cusp vakalarıyla doldur.
2. Fiziksel IERS EOP artifact/checksum/provenance hattını ilerlet.
3. Offline ephemeris physical artifact ve real planet-state cross-check hattını ilerlet.
4. GeoNames physical catalog + SHA/IANA bulk integrity.
5. 8.036 gerçek editoryal Günün Mesajı.
6. APPROVED UI PNG reference seti + SCREEN-ID/hash manifesti.

**FINAL DEĞİL.**
