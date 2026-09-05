# RUH CODE — OTOMATİK GELİŞTİRME İLERLEMESİ

Bağlayıcı kaynaklar: `RUH_CODE_MASTER_INDEX.md`, `RUH_CODE_MASTER_SARTNAME.md`, `RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`, `RUH_CODE_MASTER_TODO.md`.

**Kural:** IMPLEMENTED, DONE değildir. `DONE` yalnız requirement-specific test/evidence ile birlikte ilgili independent/golden, cihaz ve release kapıları gerçekten kapandığında verilir. Canonical lifecycle: `NOT_STARTED / IMPLEMENTED / TESTED / VERIFIED / DONE`; blocker ayrı `blocked=YES/NO` alanıdır. Exact kapsam `RC-0001 → RC-1442`, toplam **1.442 requirement**.

## Güncel canonical durum

- **RC-0002 = DONE**.
- **RC-0003 = NOT_STARTED** — independent editorial evidence açık.
- **RC-0004 = TESTED + blocked=YES** — independent bilingual editorial review açık.
- **RC-0005 = NOT_STARTED + blocked=YES**, **RC-0006 = TESTED + blocked=YES**, **RC-0007 = NOT_STARTED** — exact AKİLES provenance/comparison blocker'ı açık.
- **RC-0008→RC-0030** için daha önce physical TESTED promotion görmüş satırlar matrix gerçeğine göre korunur; global astronomy/location/UI/release blocker'ları açık kalır.
- **RC-0031→RC-0035** son fiziksel matrix okumasında `NOT_STARTED`; mevcut kod/contract iddiaları physical promotion görülmeden yükseltilmez.
- **RC-0036→RC-0050** için bu turda kritik semantic-drift düzeltmesi başlatıldı. Binding şartnamedeki gerçek anlamlar yeniden okunarak eski ilerleme notlarının RC numaralarıyla kaydığı doğrulandı.

## Kritik semantic reconciliation

Önceki otomasyon turlarında RC-0036 sonrası bazı kanıtlar yanlış requirement numaralarına bağlanmıştı. Örnekler:

- Binding **RC-0036 = Ev yöneticileri hesaplanacak**, fakat eski ilerleme notu cusp/start degree olarak yazılmıştı.
- Binding **RC-0037→RC-0041 = conjunction/opposition/square/trine/sextile**, fakat eski ilerleme notlarında house themes/rulership/aspect numaraları kaymıştı.
- Binding **RC-0045 = element dağılımı**, **RC-0047 = modality dağılımı**, **RC-0050 = exaltation/detriment/fall klasik dignities**; buna karşın matrixte RC-0041→0050 için fiziksel TESTED promotion alan kanıtların bir bölümü farklı anlamlara (ör. applying/separating) bağlıydı.

Bu nedenle yanlış anlamla alınmış TESTED statülerini korumak yasaklandı. `tools/requirements/reconcile_rc0036_rc0050_semantics.py` exact binding metnini kontrol eder ve shifted evidence ile TESTED olmuş **RC-0041→RC-0050** satırlarını konservatif olarak `NOT_STARTED` durumuna geri alır; VERIFIED/DONE satırlarını otomatik düşürmeyi reddeder. Dedicated writer workflow: `.github/workflows/reconcile-rc0036-rc0050-semantics.yml`.

Reconciliation kod commitleri:

- `3ab5fbe49f6585d65d7b5b4e1a4f464f66566546` — semantic reconciliation script.
- `22e127c9843f47f1b47a36b233dcdea4d612312d` — dedicated matrix-writer CI.

Physical bot reconciliation commit'i görülmeden burada matrix sonucu olmuş gibi gösterilmeyecek.

## Doğru numaralara yeniden bağlanan Western kanıtları

Yeni exact contract: `requirements/contracts/rc0036_rc0050_western_binding_contract.json`.

Yeni validator: `tools/requirements/validate_rc0036_rc0050_western_binding.py`.

Yeni dedicated compiled gate: `.github/workflows/rc0036-rc0050-western-binding.yml`.

Gate yalnız gerçekten mevcut runtime + compiled test kanıtıyla şu exact maddeleri TESTED seviyesine kadar promote etmeye izin verir:

- **RC-0036** — actual 12 house cusp üzerinden house ruler hesaplama.
- **RC-0037** — conjunction 0°.
- **RC-0038** — opposition 180°.
- **RC-0039** — square 90°.
- **RC-0040** — trine 120°.
- **RC-0041** — sextile 60°.
- **RC-0043** — yönetilebilir/validated orb policy.
- **RC-0045** — element dağılımı hesabı.
- **RC-0047** — cardinal/fixed/mutable modality dağılımı hesabı.
- **RC-0050** — domicile/exaltation/detriment/fall klasik essential-dignity desteği.

Bu gate için runtime evidence: `rulerships.dart`, `natal_aspects.dart`, `natal_distribution.dart`, `essential_dignities.dart`; compiled tests: `rulerships_test.dart`, `natal_aspects_test.dart`, `natal_distribution_test.dart`, `essential_dignities_test.dart`.

Exact-binding commitleri:

- `0c639ee8207d415e8dd3de7e208ed9a13cacd37d` — binding contract.
- `4d14a23ff800444f145cf29a553936dc8b2efe2f` — fail-closed semantic/runtime validator.
- `74429fbe4f28532d40b66dbd39223d9af189315d` — compiled CI + physical matrix promotion gate.

Aşağıdaki maddeler kasıtlı olarak **promote edilmez**; calculation varlığı ürün şartını tek başına kanıtlamaz:

- **RC-0042** professional minor-aspect settings.
- **RC-0044** professional user-editable orb settings + persistence/entitlement/UI.
- **RC-0046** Fire/Earth/Air/Water yoğunluklarının kullanıcıya gösterimi.
- **RC-0048** retrograde planetlerin kullanıcıya ayrıca belirtilmesi.
- **RC-0049** planetary rulerships'in ürün yüzeyinde gösterilebilmesi.

## Açık global blocker / release kapıları

- RC-0003/0004 independent editorial evidence.
- RC-0005/0006/0007 exact AKİLES provenance/comparison.
- RC-1436/1437 broader official astronomy golden/tolerance coverage.
- RC-1439 physical UI reference evidence.
- Signed/reproducible clean-checkout exact release artifact.
- Real-device offline, Free/PRO, accessibility, performance, backup/restore, PDF, lifecycle and Play release gates.

## Sonraki devam noktası

1. `requirements/requirement_state.csv`, bu progress dosyası ve `automation_runs/LATEST.md` yeniden okunacak.
2. Semantic reconciliation workflow physical commit/result doğrulanacak; kırmızıysa exact job/log okunacak ve kök neden düzeltilecek.
3. Exact RC-0036→0050 Western gate sonucu ve bot promotion fiziksel olarak doğrulanacak; yalnız physical promotion gören satırlar TESTED sayılacak.
4. RC-0031→0035 için gerçek binding gate/promotion durumu ayrıca doğrulanacak.
5. Sonra açık kalan RC-0042/0044/0046/0048/0049 ürün/UI şartları gerçekten uygulanacak; ardından dependency sırası RC-0051+ ile devam edecek.
6. 1.442 RC tamamı DONE ve bütün final release kapıları green olmadan FINAL denmeyecek.

**FINAL: NO.**
