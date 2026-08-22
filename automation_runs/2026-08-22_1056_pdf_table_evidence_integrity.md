# Ruh Code Automation Checkpoint — PDF Table / Evidence Integrity

## Gerçek ilerleme

1. `test/pdf/pdf_table_layout_test.dart` genişletildi.
   - 100 body-row fixture 7 satırlık chunk sınırıyla parçalanıyor.
   - Header her chunk'ta aynı kalıyor.
   - Reconstructed body, kaynak body ile birebir aynı sırada olmak zorunda.
   - 100 row ID'sinin tamamı unique; loss/duplication kabul edilmiyor.
   - Chunk içeriği kaynak input row listelerini alias etmiyor; sonradan input mutation render planını değiştiremiyor.
2. `evidence/pdf/report_planning_contract.json` düzeltildi.
   - Eski/olmayan `local_pdf_renderer.dart`, `pdf_font_provider.dart`, `western_chart_geometry.dart` benzeri kanıt yolları gerçek mevcut dosyalara taşındı.
   - `pdf_table_layout.dart` ve gerçek table regression test dosyası evidence kaynaklarına eklendi.
   - Long-table loss/duplication/order ve input-aliasing korumaları açık contract feature oldu.
3. `tools/pdf/validate_pdf_report_contract.py` sertleştirildi.
   - Yeni large-table test isimleri zorunlu token.
   - PDF planning evidence içindeki `sources[]` ve `tests[]` artık non-empty/unique olmak zorunda.
   - Evidence'ın işaret ettiği her source/test path gerçekten repository'de mevcut olmak zorunda; stale/hayali kanıt yolu CI'ı kıracak.

## Validation durumu

Workflow-target son source commit: `1d5fde2a951aa9346f1934187a78534b30e5d5a8`.
GitHub combined-status sorgusu bu exact commit için yine `statuses=[]` döndürdü. Görünür SUCCESS olmadan ilgili PDF requirement'ları DONE'a yükseltilmedi.

## Açık semantic borç

`ui/action_registry.csv` içinde `ACTION-PDF-PREVIEW-CREATE` ve `ACTION-PDF-PREVIEW-SHARE` tarihsel olarak `SCR-PDF-PREVIEW-001` altında tanımlı; runtime builder bunları `SCR-PDF-BUILDER-001` yüzeyinde kullanıyor. `RuhActionIds.pdfCreate/pdfShare` ve `ui/runtime_action_bindings.csv` de aynı legacy isimleri taşıyor. RC-1440 için bu canonical semantic ayrım hâlâ açık; güvenli full-registry update ile builder-specific action ID'lere taşınmalı.

## Sıradaki güvenli işler

1. Full action registry üzerinde PDF preview ile PDF builder create/share action kimliklerini semantic olarak ayır; runtime constants/bindings/entitlement validator ile aynı commit zincirinde güncelle.
2. Font blocker'ından bağımsız PDF page/table/parity regressionlarını genişletmeye devam et.
3. Western persisted calculation için versioned payload schema'yı yalnız mevcut persistence gerçeklerine dayanarak tasarla; olmayan eski şemayı uydurma.
4. Requirement-bearing diğer evidence dosyalarında stale source/test path ve semantic RC ownership taramasını sürdür.
5. Fiziksel ephemeris/EOP/Lahiri/GeoNames, 8.036 editoryal günlük mesaj, APPROVED UI refs, production Unicode PDF fonts ve clean-checkout lockfile blocker'larını açık tut.

**FINAL: NO.**
