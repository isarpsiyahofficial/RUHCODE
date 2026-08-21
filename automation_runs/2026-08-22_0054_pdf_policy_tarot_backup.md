# RUH Code automation checkpoint — PDF policy + tarot backup

## Bu turda yapılan gerçek değişiklikler

1. PDF Free/PRO action policy düzeltildi.
   - `ACTION-SETTINGS-PDF` artık Free PDF alanına giriş sağlar.
   - `ACTION-PDF-PREVIEW` açıkça `Örnek PDF Önizle` ve FREE.
   - Gerçek `Profesyonel PDF Oluştur`, PDF üretme/paylaşma ve builder işlemleri PRO kalır.
   - Runtime feature catalog zaten `pdf.sample_preview=FREE` ve `pdf.professional_export=PRO` idi; registry drift giderildi.
   - `tools/ui/validate_pdf_entitlement_policy.py` ve ayrı `PDF Entitlement Contract` workflow'u eklendi.

2. RC-0788 için standalone `tarot_cards.csv` backup şeması eklendi.
   - `id`, `session_id`, `position_index`, `card_id`, `orientation` alanları.
   - `session_id → tarot_sessions.csv.id` foreign key.
   - orientation makine ID'leri yalnız `upright/reversed`.
   - Mevcut `tarot_sessions.card_ids_json` alanı backward compatibility için korunuyor.

3. Schema-v1 geriye uyumluluğu korundu.
   - Yeni writer her zaman `tarot_cards.csv` üretir.
   - Eski schema-v1 package bu dosyayı içermiyorsa reader onu explicit boş tablo olarak materialize eder.
   - Diğer eksik dosyalar yine hata olmaya devam eder.

4. Test/evidence/CI sözleşmeleri genişletildi.
   - schema testinde tarot_cards presence/FK/orientation.
   - package testinde eski schema-v1 without tarot_cards compatibility.
   - all-tables SQLite lifecycle artık 15 non-empty logical table içerir ve gerçek tarot card row'u session'a bağlıdır.
   - schema evidence artık RC-0788'i source-level sahiplenir.
   - semantic evidence traceability validator RC-0788 literal MASTER ownership'ini kontrol eder.
   - backup schema/full-lifecycle structural validator'ları 15-table sözleşmesine güncellendi.

## Kanıt seviyesi

Bu turdaki değişiklikler `SOURCE_LEVEL_IMPLEMENTED` seviyesindedir. GitHub combined-status endpoint son exact commit için individual check sonucu göstermediği sürece RC-0788 veya PDF policy maddeleri DONE yapılmayacak.

## Sonraki güvenli işler

1. Exact workflow sonuçları görünürse PDF entitlement ve Backup CSV contract hatalarını aynı turda düzelt.
2. Free sample PDF hub/preview ile PRO professional builder'ı gerçek Settings runtime UI'a canonical ACTION/Feature IDs ile bağla.
3. `tarot_cards.csv` için non-empty SQLite export/import lifecycle artık test fixture'da var; gerçek workflow SUCCESS görünür olduğunda evidence seviyesini yeniden değerlendir.
4. Remaining evidence family semantic RC drift audit'ini sürdür.
5. Production Unicode PDF font, APPROVED UI refs, physical astronomy/GeoNames ve 8.036 editorial daily-message blocker'larını açık tut.

**FINAL DEĞİL.**
