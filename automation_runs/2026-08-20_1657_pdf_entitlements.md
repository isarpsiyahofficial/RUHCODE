# Ruh Code automation checkpoint — 2026-08-20 16:57

Bu tur iki bağımsız hattı ilerletti: Profesyonel PDF output/table güvenliği ve Faz 21 merkezi entitlement politikası.

## PDF

- `PdfOutputInspector` eklendi. Üretilen byte'ların yalnız `%PDF-` başlığına değil `%%EOF`, Catalog, Pages tree ve en az bir gerçek Page object'e sahip olması zorunlu.
- Truncated/non-PDF output paylaşılmadan önce reddediliyor.
- `PdfTableLayout` eklendi. Uzun logical tablolar bounded chunk'lara ayrılıyor ve logical header sonraki chunk'larda tekrarlanıyor.
- Tutarsız kolon sayısı render öncesinde reddediliyor.
- `PdfLocalRenderer` output inspector ve table layout ile bağlandı.
- PDF evidence ve structural validator yeni sözleşmeleri zorunlu kılıyor.
- Existing validator'ın eski byte-signature tokenına bağlı kalıp CI kırması engellendi.

## Free / PRO / temporary entitlement

- Merkezi `RuhFeatureIds` ve `RuhFeatureCatalog` oluşturuldu.
- Canonical Free/PRO base matrix mevcut.
- Temporary unlock yalnız `temporaryUnlockAllowed=true` feature'larda çalışıyor.
- Unknown feature ID fail-closed.
- PRO snapshot bütün canonical feature'ları açıyor.
- Temporary expiry exact UTC sınırında bitiyor; non-UTC expiry ve non-UTC clock reddediliyor.
- Professional client/preset alanları temporary/ad grant ile açılamıyor.
- Feature policy unit testleri, evidence contract, structural validator ve `Feature Entitlement Contract` CI workflow'u eklendi.
- Async exception testlerindeki yanlış matcher kullanımı aynı turda düzeltildi.

## Commit zinciri

- `86fcc401b59ff6740f99de84e5a4fe24d92cf1e1` PDF output inspector
- `c49924802ab78b219fec52741faf7a4b777922a8` inspector tests
- `b0ce919e619cf8b0d370d2ba491ef8ad08d6e368` renderer inspector integration
- `ceaab74451e059ff28f7c3bce4ce2a5281665b73` long-table layout
- `e5fb515d92538281bf4ea8c9a06d5da35a0521c3` table-layout tests
- `8457ce3dead0cdb17a19e54a9d080539d4e5c970` table renderer integration
- `d541058f50ce327616adedf19475fe6ee727f74d` PDF evidence update
- `a481337fca101aa34a88c95a6c7d4954c6733d4b` PDF structural validator update
- `ca67a8716e5ff917b3f086046850d2629dd90a30` canonical feature catalog
- `26ad0ed6ef03533b6fd1a92986febb23d5651e94` entitlement resolver
- `d6a91789b22f5f3cb3155391f9e7b9c89a29c710` entitlement tests initial
- `3b8819a926b5cc326e96bef8f8ecc08f7197e5c1` async test correction
- `3b65a3058d952765c70be560e78f9c0b1a367648` entitlement evidence
- `7bbfb87ec563296b34aba2c1afc7c7060926b38b` entitlement validator
- `d4af235f14b53813d2e11eab22d642c0b06ce669` entitlement CI gate

## Kanıt durumu

GitHub combined-status son entitlement workflow commit'i için `statuses=[]` döndürdü. Exact workflow SUCCESS görünür olmadığı için PDF ve entitlement RC'leri DONE'a yükseltilmedi.

## Açık sıradaki işler

1. Entitlement snapshot'ını offline ve kalıcı store'a bağla; Free↔PRO değişimlerinin user-data mutation yapmadığını integration test et.
2. Serverless sınırlar içinde temporary access için local rollback-resistant time anchor sözleşmesi oluştur.
3. UI / route / service guard'larını aynı `EntitlementService` kaynağına bağla.
4. Purchase ownership restore / reinstall / device-change akışını Google Play resmi mekanizmasına bağla ve offline cached ownership davranışını test et.
5. PDF approved Unicode font artifact gelmeden font DONE yapma; blocker dışı olarak 5/25/50+ test fixture generator ve full parser/crop/glyph gate altyapısını ilerlet.
6. Production Western vector painter, Vedik adapter ve BaZi/Numeroloji PDF table modellerini ilerlet.
7. Physical astronomy/GeoNames/daily-message/UI-reference blocker dışı görevleri paralelde sürdür.

**FINAL DEĞİL.**
