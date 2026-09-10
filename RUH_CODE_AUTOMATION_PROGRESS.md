# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** `IMPLEMENTED`, `DONE` değildir. `DONE` yalnız requirement-specific kanıt ile; calculation/interpretation/UI/TR-EN/offline/Free-PRO/backup/PDF/security/accessibility/performance/clean-checkout/lifecycle/device ve exact-release kapıları gereken kapsamda yeşil olduğunda verilir. Canonical lifecycle `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; exact kapsam `RC-0001→RC-1442`, toplam **1.442 requirement**.

## Canonical durum özeti

- RC-0271→0305 = TESTED + blocked=YES (`18419e674b4603fecdb050a99e4f268ddc3cb95f`).
- RC-0306→0323 = TESTED + blocked=YES (`cee7256c9166b511c61d4cace9dfa053aa27b4bd`).
- RC-0324→0950 implementation/matrix zincirleri mevcut; global golden/device/PDF/backup blocker'ları nedeniyle DONE değil.
- RC-0951→0964 = IMPLEMENTED + blocked=YES (`5f08942462a0b3784725b9fd7e65de0cc22eb50e`).
- RC-0965→0994 traceability release-mode fail-closed; 1.442 requirement doğrudan evidence ile kapanmış değil.
- RC-0995→1003 authoritative golden contract mevcut; exact AKİLES provenance/independent values eksik.
- RC-1004→1039 = IMPLEMENTED + blocked=YES (`fb71d1b9703f35a4dec499e7d7de33151d57a75e`).
- RC-1040→1058 = IMPLEMENTED + blocked=YES (`d96a3b5c1821d81739b491757795cfced5ba040a`).
- RC-1059→1084 = IMPLEMENTED + blocked=YES (`ed87a5c385425a0c3e7f59f7f884c8dc55cab8f6`).
- RC-1085→1104 = IMPLEMENTED + blocked=YES (`a9c4b832269328935dbf6d4753f603d17fa5b1f7`).
- RC-1105→1130 dependency/offline governance mevcut; `pubspec.lock` fiziksel.
- Stacked PR zinciri #1→#16 mevcut. RC-1304→1344, RC-1345→1361, RC-1375→1404 ve RC-1405→1420 dedicated gate'lerinin doğrulanmış SUCCESS koşuları mevcut.
- RC-1437 Runtime Assets dedicated gate'in doğrulanmış SUCCESS koşusu mevcut; bu tek başına bütün final packaged/legal/release closure kanıtlarının tamamlandığı anlamına gelmez.
- Exact PR #16 HEAD `a2d02ecdfa907b81f173ab7bae26a30dfbc3b1a0` üzerinde Requirements Contract, RC-0166→0184 Numerology Core, RC-0230→0247 Personal Growth, RC-0360→0371 Storage Runtime, RC-0755→0773 Transactional Data Safety, RC-0774→0848 Portable Backup, UI Contracts, Western Natal Aspects, RC-1197→1205 Data Deletion, RC-1206→1221 Professional Search, RC-1249→1272 PDF Export Governance, RC-1273→1285 Design System, RC-1286→1303 Entitlement Transfer, RC-1304→1344 Golden Lifecycle, RC-1345→1361 Release Cleanliness, RC-1375→1404 Final Traceability ve RC-1437 Runtime Assets dahil çok sayıda gate fiziksel SUCCESS verdi. Cancellation hiçbir zaman SUCCESS sayılmıyor.
- `24ff965be4307c30671e6d2faf273c64749807f8` sonrasında workflow'ların büyük bölümü job üretmeden `action_required` durumunda kaldı. Bu durum SUCCESS veya product-test failure sayılmıyor; approval/policy katmanı ile gerçek CI sonucu ayrı tutuluyor.
- RC-1436 için bağımsız ASC/MC oracle zinciri eklendi ve exact `8ea3f07930ce76fc60a9dc0e26d27a5b3d5d3ec1` HEAD üzerinde `RC1436 ASC MC Independent Oracle` run `34443503983` fiziksel SUCCESS verdi. Canonical ASC/MC bütçeleri değiştirilmedi. Global astronomy proof hâlâ `proven=false`; house cusp, sunrise/sunset, planetary-hour boundary, Nakshatra/Pada kanıtları eksik olduğundan RC-1436 DONE değildir.
- Exact `8ea3f079...` HEAD üzerinde kalan Requirements Contract, UI Contracts ve PDF Entitlement kırmızılarının ortak kökü `ACTION-PDF-BUILDER-PREVIEW` action ID'sinin base ve extension registry'de iki kez bulunmasıydı. Professional PDF/Professional PDF Application kırmızısında ayrıca preflight validator'ın eski widget-test başlığını aradığı görüldü. Duplicate registry ve stale validator bu turda düzeltilmiştir; yeni exact-head CI sonucu beklenmektedir.

## RC-1421→1442 — bağlayıcı son ek / final release closure

Branch: `agent/rc1421-rc1442-release-closure`, stacked PR #16.

`lib/src/application/daily/today_temporal_contract.dart`, regression, exact RC-1421→1442 evidence contract, fail-closed release validator ve dedicated CI mevcut. Günlük stok mesaj ile kişisel hesaplanmış etkiler ayrı tiplerdir; Gregorian/leap-year/date-range ve explicit timezone/location sınırları testlidir. Release modu açık blocker'lar varken başarısız olmak zorundadır; TESTED/VERIFIED/DONE otomatik verilmez.

### Kapatılan gerçek kırmızı kök nedenler

1. **Flutter Quality analyzer:** eski koşuda kalan 6 ihlal doğrudan kaynakta temizlendi. Gereksiz backup importları, `clamp` cast'i, Varga non-null assertion'ı ve iki PDF testindeki gereksiz `dart:async` importları kaldırıldı. Commit zinciri: `1132b33756340bbcabe5dd47bb8c862d5293c7ef`, `fa7108a1d75a90af7648e58504bdb5e578aaca05`, `c326fe0f310ccfaf5387db2e45f1f8011c4eb861`, `61925bbab7407e9a9d9878076be94fdb36ad3d64`, `5987cdd01fa79dc4fe7a9ad3f52a277b6bc3b3b7`, `02ddc42e4f92caab0f7bb4e81143b4d6b4552b54`.

2. **Requirements Contract / design tokens:** eski validator yalnız altı core spacing değerine izin verdiği için RC-1273+ semantic spacing tokenlarını yanlışlıkla `spacing grid drift` sayıyordu. Validator artık exact core grid (`4,8,12,16,24,32`) ile semantic spacing (`paragraph`, `section`, card/screen/PDF padding ve chart legend gap'leri) ayrı fail-closed doğruluyor. Düzeltme `de480d49af696b19141c2043a35e4982d4399605`. Sonraki exact-head koşusu SUCCESS verdi.

3. **RC-0859→0869 PDF Release Boundary:** testlerin 11/12'si yeşildi; tek hata filename sanitizer'ın yasak karakterlerden sonra subject sonunda `_` bırakıp build separator'ıyla `__` üretmesiydi. Boundary separator'ları temizleyen düzeltme `80068c44413d5e50b50cb3213d32d88aceb47fb3`. Türkçe harfler korunuyor. Sonraki exact-head koşusu SUCCESS verdi.

4. **RC-0360→0371 Storage Runtime:** production entitlement guard doğru `EntitlementService` kullanıyor fakat validator eski comment'in exact `here` kelimesini arıyordu. Validator comment cümlesine değil `FeatureAccessGuard` + `EntitlementService` + local-premium-bypass yasağının semantic tokenlarına bağlandı. Düzeltme `24bacfabaf7beda45a716a70994baec718ad60de`. Sonraki exact-head koşusu SUCCESS verdi.

5. **RC-0755→0773 Transactional Data Safety:** üç snapshot/recovery testi `Map.unmodifiable` generic inference nedeniyle runtime'da `UnmodifiableMapView<dynamic,dynamic>` cast hatası veriyordu. Nested snapshot tabloları artık her seviyede explicit typed immutable map olarak oluşturuluyor. Düzeltme `20f2d0b0f30f6eccac68517add4e36b5574c7a71`. Sonraki exact-head koşusu SUCCESS verdi.

6. **RC-0166→0184 Numerology Core:** dedicated kırmızı production hesap motorundan değil validator'ın API deklarasyonunu yanlış string biçiminde aramasından geliyordu. Production gerçek API `static NumerologyAlphabet pythagorean(...)` ve `static NumerologyAlphabet chaldean(...)`; validator bunları declaration seviyesinde doğrulayacak şekilde düzeltildi. Life Path/Birthday/name/maturity/karmic debt/personal year-month-day/periods/Türkçe normalizasyon ve ayrı Chaldean tablo kontrolleri korunuyor. Sonraki exact-head koşusu SUCCESS verdi.

7. **RC-0230→0247 Personal Growth:** eski `CheckInKind.morning` kırmızısında validator enum üyelerini production'da kullanım ifadesi olarak arıyordu. Yalnız validator düzeltilmedi: production'a `checkInsForDate`, inclusive tarih aralığı özetleri, `GrowthPeriodMetrics`, `GrowthPeriodComparison` ve deterministic tarihsel dönem karşılaştırması eklendi. Regression Ağustos/Eylül dönemlerinde journal/check-in sayıları ile mood/energy ortalama ve delta'larını, sabah/akşam check-in sorgularını ve ters tarih aralığında fail-closed davranışı doğruluyor. Exact RC-0245 historical comparison gerçek kod/test yüzeyine sahip. Sonraki exact-head koşusu SUCCESS verdi.

8. **UI runtime theme contract:** `Design tokens` gate'i core + semantic spacing'i doğru şekilde yeşil doğrularken ayrı runtime-theme validator semantic `paragraph=12` değerini eski `spacingParagraph` ismine zorladığı için UI Contracts kırılıyordu. Validator core ve semantic runtime isimlerini ayrı exact map ile doğrulayacak şekilde düzeltildi (`9a98fd58bafc07cec2ed38c4adca2b407bebbf6b`). Aynı düzeltmede dark palette de canonical JSON'a byte-for-byte bağlandı; denetim gevşetilmedi. Sonraki exact-head UI Contracts koşusu SUCCESS verdi.

9. **RC-0158→0165 System Boundaries:** validator RC-0158…RC-0165'in her birini regression dosyasında literal requirement ID ile bağlamakta haklıydı; test ise RC-0161→0164'ü tek toplu başlıkla yazdığı için RC-0162/0163/0164 literal ID'leri yoktu. Davranış veya requirement gevşetilmedi; regression adı dört requirement ID'yi ayrı ayrı taşıyacak şekilde düzeltildi. Commit `f301b23addc6984122137cd85ad98df2ddc7cb75`.

10. **Backup CSV / RC-0774→0848 verified restore:** 150 backup/data/UI testi geçerken tek test, asynchronous `verified.apply(...)` Future'ını beklemeden snapshot/rollback sayaçlarını kontrol ettiği için sahte negatif veriyordu. Exception path'leri `await expectLater(...)` ile gerçekten tamamlanana kadar bekleniyor; invalid-preview async assertion da aynı şekilde düzeltildi. Commit `7435b87f72aa9fe7a125c32339731c79850d3fc0`. Sonraki exact-head RC-0774→0848 Portable Backup koşusu SUCCESS verdi.

11. **Professional PDF locale contract:** production PDF locale policy `tr`, `tr-*`, `en`, `en-*` değerlerini bilinçli destekliyor ve diğer locale'leri fail-closed reddediyor; eski validator yalnız eski `request.localeTag != 'tr' && request.localeTag != 'en'` source stringini arıyordu. Validator güncel production semantiğine bağlandı; demo/user origin, snapshot parity, A4, xref, page-count, font SHA ve diğer fail-closed kontroller korunuyor. Commit `c478e03f6d733ab2cf186b79605d8ab3d5397750`.

12. **Western Natal Aspects Contract:** production `MajorAspect` altı aspect içeriyor ve `AspectOrbPolicy` her desteklenen aspect için finite orb zorunlu tutuyor. Custom chart-assembly fixture yalnız quincunx orb'unu unutmuştu ve bu nedenle production'ın doğru fail-closed validasyonuna takılıyordu. Fixture'a `MajorAspect.quincunx: 1` eklendi; production kuralı gevşetilmedi. Commit `e9e050661a2c8ed92b1286bb5d15c3bcc6ca6188`. Sonraki exact-head koşusu SUCCESS verdi.

13. **Professional PDF preflight runtime registry:** önceki yaklaşım preview action'ını extension registry'ye de eklediği için base registry'deki aynı canonical ID ile duplicate oluştu. Exact `8ea3f079...` CI bunu Requirements/UI/PDF Entitlement gate'lerinde fail-closed yakaladı. `54c695f23af32c04ab966c053e62c857d8c04ca0` ile extension'daki duplicate row kaldırıldı; base registry canonical owner olarak kaldı. `17c7bb087f6c9b8d86de1596b07481b47b9b7b0f` ile PDF preflight validator base+extension registries'i birlikte okuyup `ACTION-PDF-BUILDER-PREVIEW` için exact-one uniqueness zorunlu tutuyor. Böylece validator belirli bir dosya konumuna değil canonical birleşik registry semantiğine bağlı.

14. **RC-0511→0526 Professional Timeline validator:** production `TimelinePlanet` enum'u `saturn` üyesini, topic enum'u relationship/career üyelerini ve gerçek filter regression'ları zaten taşıyor. Eski validator production source içinde call-site biçiminde `TimelinePlanet.saturn` aradığı için enum declaration'ını yanlış negatif sayıyordu. Validator enum declaration'larını semantik parse ediyor ve regression dosyasında Saturn/relationship/career/high-importance filtrelerinin gerçekten kullanıldığını ayrıca zorunlu tutuyor. Commit `eb7120cf79a2d7357ad2c048fcaaf932fde08db1`. Matrix RC-0511→0526 hâlâ NOT_STARTED/blocked; dedicated exact-head SUCCESS olmadan yükseltilmez.

15. **RC-0870→0877 PDF Vector Rendering gerçek runtime bug:** validator yeşildi fakat gerçek `pw.Document.save()` testi Western chart içindeki `☉`, `☽`, `♄` SVG `<text>` glyph'lerini built-in Helvetica/Latin-1 ile encode edemediği için çöküyordu. Vektör/raster kuralı gevşetilmedi. Production SVG builder standard planetary glyph'leri deterministic ASCII abbreviations (`Su/Mo/Me/Ve/Ma/Ju/Sa/Ur/Ne/Pl/No/So`) olarak PDF-safe SVG text'e dönüştürüyor; kalan Latin-1 dışı label'lar fail-closed `FormatException` veriyor. Commit `fac4b9840ba24268368723cf22b73b1e8bcf5488`. Exact `8ea3f079...` HEAD üzerinde `RC0870-RC0877 PDF Vector Rendering` SUCCESS verdi.

16. **RC-1436 ASC/MC independent accuracy proof:** canonical `ascendantLongitudeMaxAbsErrorDegrees=0.05` ve `mcLongitudeMaxAbsErrorDegrees=0.05` toleransları değiştirilmeden, production `WesternAscMc.calculate` bağımsız Swiss Ephemeris/pyswisseph oracle'ına bağlandı. Beş vaka 1900/2000/2026/2050/2100 tarihlerini; kuzey/güney ve doğu/batı boylamlarını; >60° enlem vakasını kapsıyor. Evidence materializer `b9ff49452f6cad0f1fca56701459fac6d03b2a6e`, checked-in evidence `81bb8c6fb9598b1b7194bbf91be25898a4f6d9cb`, production regression `76cf55b9d8feecf01926fd5a236b18b7215fa630`, fail-closed regeneration verifier `e908ca751366b39ab0540bd229e3857e4326d28e` ve pinned `pyswisseph==2.10.3.2` dedicated workflow `337cc52cbb344dd060d653efe28c356398d28bc3` olarak eklendi. Oracle evidence `providerVersion=2.10.03` ve provider binary SHA-256 provenance taşıyor. Exact `8ea3f079...` HEAD üzerinde dedicated run `34443503983` fiziksel SUCCESS verdi. Bu yalnız ASC/MC accuracy alt-kanıtını kapatır; global RC-1436 proof diğer accuracy sınıfları nedeniyle açıktır.

17. **Professional PDF preflight stale widget assertion:** exact `8ea3f079...` Professional PDF gate'i structural planning'i geçip eski test adı `numerology preview and build use handler-supported canonical sections only` beklentisinde kırılıyordu. Gerçek widget regression artık `builder invokes application actions with typed selected record and section order` adıyla numerology için `PdfSectionIds.numerology` + `PdfSectionIds.technicalManifest`, Western için yalnız persisted-handler sectionlarını ve stale-preview invalidation'ı doğruluyor. `17c7bb087f6c9b8d86de1596b07481b47b9b7b0f` validator'ı bu gerçek davranış tokenlarına bağladı; requirement gevşetilmedi.

### Fiziksel blocker doğrulamaları

- Günlük mesaj manifesti 2026-01-01→2036-12-31, 4.018 gün / 8.036 TR+EN kayıt taşıyor; strict release audit hâlâ DONE öncesi zorunlu. RC-1425/1426/1433/1434 release-DONE değildir.
- `astronomy_accuracy_budgets.json` ölçülebilir toleransları tanımlıyor ancak `proven=false`. ASC/MC independent workflow artık fiziksel SUCCESS; house cusp, sunrise/sunset, planetary-hour boundary, Nakshatra ve Pada precision kanıtları hâlâ eksik. RC-1436 DONE değildir.
- `requirements/reference_manifests/rc1439_reference_images.json` status `NOT_PROVEN`, `images=[]`. RC-1431/1439 ve reference-dependent final UI gate'leri açık.
- RC-1437 specialist runtime-assets gate yeşil olsa da exact packaged/version/checksum/offline/legal release zincirinin final closure kanıtı ayrıca gereklidir.
- RC-1442 exact clean-checkout artifact, tested commit SHA ve artifact SHA eşleşmesi tüm 1.442 RC DONE/unblocked olmadan kapanamaz.
- Çok sayıda calculation/Vedic workflow branch push/concurrency nedeniyle `cancelled`; cancellation SUCCESS sayılmıyor.
- Yeni exact HEAD `17c7bb087f6c9b8d86de1596b07481b47b9b7b0f` üzerinde Professional PDF, Professional PDF Application, Requirements Contract, UI Contracts ve ilgili downstream workflow'lar yeniden queued/pending durumundadır; fiziksel SUCCESS görülmeden lifecycle promotion yok.

## Açık kritik blocker'lar

Exact AKİLES provenance; remaining independent authoritative calculation goldens (özellikle house cusp, sunrise/sunset, planetary-hour boundaries, Nakshatra/Pada); Panchanga/Vedic ve Dasha/Varga/Gochara/BaZi providers; historical timezone/DST/polar goldens; rendered TR/EN UI/PDF; günlük mesaj exact release audit; physical UI reference images; approved static visual-source inventory; final EOP/DE440s/package license evidence; encrypted persistence/key management/migrations; real ad/rewarded/PRO verifier; full airplane-mode production instrumentation; security/accessibility/performance; branch/review governance; kalan kırmızı/cancelled calculation ve lifecycle workflow'ları; clean-checkout/lifecycle; exact final release artifact.

## Sonraki devam noktası

1. Exact PR #16 HEAD `17c7bb087f6c9b8d86de1596b07481b47b9b7b0f` üzerinde Requirements Contract, UI Contracts, PDF Entitlement, Professional PDF Contract ve Professional PDF Application sonuçlarını fiziksel doğrula; duplicate/preflight düzeltmeleri SUCCESS olmadan promotion yapma.
2. RC-1436 için sıradaki bağımsız accuracy sınıfı olarak house cusp ve sunrise/sunset kanıt zincirini canonical `0.05°` / `60 s` bütçelerine bağla; toleransları test geçsin diye gevşetme.
3. RC-1362→1374 airplane-mode release/device koşusunu policy-level launch'tan gerçek production capability instrumentation'a genişlet.
4. Günlük mesaj strict release audit, RC-1439 physical reference images ve final packaged dataset/license zincirlerini bağımsız ilerlet.
5. Cancelled Vedic/calculation workflow'larını SUCCESS kabul etme; final exact-head üzerinde zorunlu kritik workflow seti fiziksel çalışmadan lifecycle yükseltme.
6. Yalnız dedicated exact-head SUCCESS ve requirement-specific evidence mevcutsa matrix lifecycle state'ini yükselt; global blocker mevcutken DONE verme.
7. RC-0001→RC-1442 tamamı DONE, bütün release kapıları green ve exact release artifact doğrulanmış olmadan FINAL deme.

**FINAL: NO.**
