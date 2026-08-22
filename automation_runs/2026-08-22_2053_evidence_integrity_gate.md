# Ruh Code automation checkpoint — Evidence integrity gate

## Bu turda yapılan gerçek işler

1. `tools/requirements/validate_evidence_integrity.py` eklendi.
   - `evidence/**/*.json` ağacının tamamını tarar.
   - `requirements` / `requirement_ids` RC tokenlarını `RC-0001..RC-1442` aralığına karşı doğrular.
   - Duplicate RC sahipliğini aynı evidence dosyası içinde reddeder.
   - Her iki RC alanı aynı dosyada varsa birebir aynı set olmak zorundadır.
   - `sources`, `tests`, `validators` listelerinde duplicate, absolute path ve `..` traversal reddedilir.
   - Yerel source/test/validator referanslarının repository içinde gerçek dosyaya çözülmesi zorunludur.
   - `done` alanı varsa boolean olmak zorundadır.
   - `done=true` evidence üzerinde açık `releaseBlockers` kalamaz.
   - Invalid UTF-8 / invalid JSON fail-closed davranır.
2. Merkezi `.github/workflows/requirements-contract.yml` bu genel evidence integrity gate'ini semantic ownership denetiminden önce çalıştıracak şekilde güncellendi.
3. Seçilmiş evidence dosyaları için mevcut exact semantic RC ownership validator korunuyor. Yeni gate onun yerine geçmez; tüm evidence ağacında yapısal bütünlüğü tamamlar.

## Neden gerekliydi

Mevcut `validate_evidence_traceability.py` yalnız açık `EXPECTED` allowlist'ine alınmış evidence sözleşmelerini semantic olarak denetliyordu. Repository büyüdükçe yeni evidence dosyalarının yanlış RC tokenı, kayıp source/test yolu veya path drift'iyle merkezi Requirements Contract'tan kaçma ihtimali vardı. Yeni gate bu açığı kapatır.

## Validation durumu

Workflow-target commit: `ab1956ac0836e042605438fae8cd909e58941001`.

GitHub combined-status sorgusu exact commit için individual status göstermedi (`statuses=[]`). Çalışma container'ı da `github.com` DNS çözümleyemediği için temiz clone üzerinde validator koşusu yapılamadı. Bu nedenle hiçbir RC yalnız bu source-level değişiklik nedeniyle DONE yapılmadı.

## Sonraki güvenli işler

1. Repository-wide evidence integrity gate'in ilk görünür CI sonucunda yakaladığı gerçek path/schema drift'leri varsa aynı turda düzelt.
2. Requirement-bearing fakat semantic allowlist dışında kalan evidence ailelerini kademeli olarak exact MASTER-aware sahiplik denetimine ekle.
3. Approved font gerektirmeyen PDF page/parity ve UI interaction/accessibility regresyonlarını ilerlet.
4. Fiziksel ephemeris/EOP/Lahiri/GeoNames, 8.036 editoryal günlük mesaj, APPROVED UI refs ve production PDF fontlarında sahte artifact/checksum üretme.

**FINAL: NO.**
