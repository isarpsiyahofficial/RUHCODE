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
- `LocalEntitlementSnapshotStore` eklendi; entitlement snapshot ayrı `system_entitlement_state` logical table içinde offline persist ediliyor ve user-domain tablolarına dokunmuyor.
- `LocalRollbackResistantEntitlementClock` eklendi. Installation'ın daha önce gördüğü en ileri UTC anından geriye gidilmiyor; basit device-clock rollback geçici erişimi uzatamıyor.
- Time-anchor korumasının app-data temizleme/reinstall sonrası mutlak güvenlik sağlamadığı açıkça kod/evidence sözleşmesine yazıldı; platform purchase restore hâlâ gerekli.
- Entitlement clock async hale getirilerek persistent time-anchor desteklendi; test double'ları buna uyarlandı.
- Type-promotion belirsizliği olan time-anchor satırı explicit `DateTime` akışına çevrildi; structural validator aynı turda güncellendi.

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
- `8f72fa20dbeaf65412fcf559f7b25745426680de` offline entitlement snapshot store
- `79a0add5ed40eb2f9007420d1e458da5d896dbfc` local snapshot tests
- `853f99944302bb156ea297b5a227c6693e1b8250` entitlement validator local-store extension
- `3d9a42fe29a6b0de2dd378de68dbbe1f8446af1a` local-store evidence
- `9e6a645259673dde3eac43e867f79fde5f351530` async entitlement clock contract
- `db814e84046945e2409270d95be5e3965b132715` async clock test adaptation
- `13f265b3ce1b7f0c322b90a05ab3f26d625324cf` rollback-resistant time anchor
- `40984fe6160d848fcbca38e74a0fcd7b04738ed2` time-anchor tests
- `e6b2dbe44e147095ee5bc04953adc558f8af2ed9` time-anchor validator extension
- `23b98115c8d283a9916a859286cfa08340a8d3c4` time-anchor evidence
- `a5ec32626b6ce8bb2a572d33e50313848f2c795a` explicit DateTime type-flow hardening
- `82b08c12349db7c51272d5c9e38673babb88efd0` validator alignment

## Kanıt durumu

GitHub combined-status entitlement evidence hedef commit'i için yine `statuses=[]` döndürdü. Exact workflow SUCCESS görünür olmadığı için PDF ve entitlement RC'leri DONE'a yükseltilmedi.

## Açık sıradaki işler

1. Production SQLite üzerinde Free↔PRO değişimlerinin profile/client/consultation/note/calculation verisini değiştirmediğini integration test et.
2. UI / route / service guard'larını aynı `EntitlementService` kaynağına bağla.
3. Purchase ownership restore / reinstall / device-change akışını Google Play resmi mekanizmasına bağla ve offline cached ownership davranışını test et.
4. Rewarded-ad success/cancel/failure akışını entitlement snapshot mutation kurallarıyla bağla; hata durumunda state bozulmasın.
5. PDF approved Unicode font artifact gelmeden font DONE yapma; blocker dışı olarak 5/25/50+ test fixture generator ve full parser/crop/glyph gate altyapısını ilerlet.
6. Production Western vector painter, Vedik adapter ve BaZi/Numeroloji PDF table modellerini ilerlet.
7. Physical astronomy/GeoNames/daily-message/UI-reference blocker dışı görevleri paralelde sürdür.

**FINAL DEĞİL.**
