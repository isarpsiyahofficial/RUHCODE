# Ruh Code automation checkpoint — Western write boundary + semantic evidence audit

## Gerçek ilerleme

1. `tools/astronomy/validate_western_natal_write_boundary.py` eklendi.
   - `RuhCodeRuntime` production SQLite üzerinde `WesternNatalPersistenceService` compose etmek zorunda.
   - `CoreRepositories` generic/public `calculations` repository expose edemez.
   - Western persistence boundary CalculationManifest + sealed snapshot'ı tek transaction içinde yazmak zorunda.
   - Production source taraması `calculations` tablosuna açık write yapan dosyaları allowlist dışında reddeder.
   - Backup restore, doğrulanmış portable package restore yolu olduğu için kontrollü istisnadır.

2. Persisted-Western semantic RC audit genişletildi.
   - `persisted_western_natal_snapshot.json`
   - `persisted_manifest_section.json`
   - `persisted_western_pdf_service.json`
   artık aynı MASTER-aware validator tarafından exact RC setleri ve semantic keyword sahipliğiyle doğrulanıyor.

3. CI wiring genişletildi.
   - `Persisted Western Natal PDF Contract` write-boundary validator'ını çalıştırıyor.
   - Merkezi `Requirements Contract` persisted-Western semantic validator ve write-boundary validator'ını da çalıştırıyor.

## Kanıt durumu

Workflow-target commit: `4868358f8cac5ea45b6f8aedd42b86aa901f1ded`

GitHub combined status sorgusunda individual status görünmedi (`statuses=[]`). Bu nedenle hiçbir ilgili RC yalnız source-level çalışma nedeniyle DONE yapılmadı.

## Açık blocker'lar

- production Unicode PDF font binary + license/hash
- APPROVED UI reference/hash set
- physical/versioned ephemeris + IERS EOP + Lahiri + GeoNames artifacts
- 8.036 gerçek editoryal daily-message kaydı
- exact visible workflow SUCCESS / clean-checkout release proof
- Play/rewarded-ad gerçek cihaz kanıtları

## Next safe work

1. Approved font gerektirmeyen PDF structural/page/parity regression kapsamını genişlet.
2. Requirement-bearing kalan evidence dosyalarını semantic RC drift açısından audit et ve merkezi requirement gate'e bağla.
3. Western write-path auditinin test/backup istisnasını dar tut; yeni direct writer girerse CI kırılmalı.
4. UI interaction/accessibility ve backup blocker-independent açıkları ilerlet.
5. Fiziksel artifact blocker'larında sahte veri/checksum üretme.

**FINAL: NO.**
