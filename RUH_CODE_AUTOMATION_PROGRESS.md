# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- Önceki physical matrix durumları korunur; RC-0002 DONE, RC-0031→0035/0052→0060 ve RC-0063→0081 arasındaki daha önce TESTED olarak kanıtlanmış hatlar geriye düşürülmez.
- **RC-0061 = IMPLEMENTED + blocked=YES**; active house-system name için gerçek product-screen/widget-device evidence açık.
- **RC-0062 = NOT_STARTED**; natal-chart dedicated contract/test/CI mevcut fakat physical promotion unresolved ve atlanmış sayılmıyor.
- **RC-0080→0081 = TESTED + blocked=YES** (`de9260ea79934c4f9cee912d451e746512d96943`). Independent Vedic engine physical matrix promotion doğrulandı.
- **RC-0082→0083:** production seçim mimarisi ve dedicated gate main üzerinde; exact commit `9588f2dbd9b240721cbb9dffd7fc34306f25c8af` için Flutter Quality Analyze ve requirement-validation check'lerinde gerçek failure görüldü. Matrix bu nedenle hâlâ NOT_STARTED; TESTED denmiyor.
- **RC-0084→0085 = IMPLEMENTED + blocked=YES (repository evidence)**. Vedic Lagna ve classical Graha çekirdekleri, compiled regressions, binding contract, fail-closed validator ve dedicated CI gate main üzerinde; physical CI/promotion bekleniyor, matrix henüz yükseltilmedi.

## Bu turdaki gerçek geliştirme

### RC-0082 → RC-0083 — kırmızı CI gerçek blocker olarak kaydedildi

Önceki kayıttaki “workflow görünürlüğü henüz oluşmadı” varsayımı yeniden kontrol edildi. Exact `9588f2db...` commit'i üzerinde Flutter Quality `analyze-and-test` job'ının **Analyze** adımında failure ve requirement validation failure fiziksel olarak görüldü; test adımı analyze başarısızlığı nedeniyle skip oldu. Bu iki madde bu yüzden TESTED'e yükseltilmedi. Sonraki turda exact analyzer/validator diagnostic erişilebildiği anda kök neden düzeltilecek; kırmızı durum saklanmıyor.

### RC-0084 — Vedik Lagna

Bağlayıcı madde: `84. Vedik Lagna hesaplanacak.`

Commit zinciri:
- `a35a670806baf1f1e94c90c3ebb1a4d9031f1138` — `lib/src/calculation_core/vedic/vedic_lagna.dart`
- `4389da5b76c6e5b7500302f5b5e2abac2ce33eeb` — compiled Lagna regressions

Yeni `VedicLagna` Western calculation namespace'ini import/delegate etmiyor. Explicit UT1 + TT + konum tüketiyor, shared sidereal-time primitive'inden yerel mean sidereal time üretiyor, eastern ecliptic/horizon intersection geometrisini kendi Vedic katmanında hesaplıyor ve seçili versioned ayanamsha'yı uygulayarak normalized sidereal Lagna üretiyor. Ayanamsha id/dataVersion sonucu üzerinde korunuyor; invalid longitude/latitude, non-finite time ve invalid ayanamsha fail-closed. Rashi index ve sign içi derece türetiliyor.

Bu çalışma Lagna'nın bağımsız astronomy golden/tolerance doğruluğunu henüz kanıtlamaz; numerical Lahiri doğruluğu, real-world golden cases, product UI/device/release kapıları açık blocker.

### RC-0085 — Graha konumları

Bağlayıcı madde: `85. Graha konumları hesaplanacak.`

Commit zinciri:
- `09bca3f559f555fc54f5825abe589f401b4b4571` — `lib/src/calculation_core/vedic/vedic_grahas.dart`
- `8918043811a98eff5676dc172c8106c06a5e9f35` — compiled Graha regressions

`VedicGrahaSet`, independent `VedicCalculationSnapshot` içinden Sun/Moon/Mercury/Venus/Mars/Jupiter/Saturn classical Graha setini completeness + normalized finite checks ile çıkarıyor ve ephemeris/ayanamsha provenance'ını koruyor. Rahu/Ketu bilerek bu requirement içine gizlice birleştirilmedi; RC-0086/RC-0087 ayrı kalıyor.

### RC-0084 → RC-0085 requirement gate

- `daadfa6a401a557d6cc64f7510540236e9666b21` — binding contract
- `aa0d7c418b6611e228357fa8ed035169a59b68c6` — fail-closed validator
- `9184bf24826c68be3af7ad6bff5925da23e0bde5` — dedicated Flutter CI + matrix-promotion workflow

Dedicated gate Python contract validation + iki compiled Flutter testini çalıştırıyor; yalnız physical green push sonrasında matrix'i TESTED'e promote edecek. Bu tur sonunda workflow checks queued/başlıyor durumdaydı; promotion commit'i fiziksel olarak görülmeden TESTED denmiyor.

## Açık product-facing / global blocker'lar

RC-0042/0044/0046/0048/0049 product-facing açıkları; RC-0061 active house-system UI; RC-0068+ ilgili rendered product UI/interpretation/entitlement kanıtları; independent editorial/astronomy golden evidence; exact AKİLES provenance; signed/reproducible clean-checkout exact release artifact; real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle ve Play release gates açık.

## Sonraki devam noktası

1. `9588f2db...` RC-0082/0083 Flutter Analyze + requirement-validation failure exact diagnostic/kök nedeni çıkarılıp düzeltilecek ve yeniden doğrulanacak.
2. RC-0084/0085 dedicated CI/promotion sonucu okunacak; kırmızıysa aynı şekilde kök neden düzeltilecek.
3. **RC-0062** unresolved natal-chart promotion tekrar incelenecek; atlanmayacak.
4. Dependency sırasıyla **RC-0086 Rahu → RC-0087 Ketu → RC-0088 Nakshatra → RC-0089 Pada** ilerletilecek; astronomik hesap uydurulmayacak.
5. Lahiri/Chitrapaksha numerical doğruluğu için bağımsız provider/golden/tolerance kanıtı ayrı kapı olarak kurulacak.
6. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**
