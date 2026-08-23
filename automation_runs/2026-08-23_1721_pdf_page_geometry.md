# Ruh Code automation checkpoint — PDF page geometry

Bu turda font veya fiziksel astronomi artifact blocker'larına bağlı olmayan profesyonel PDF gereksinimleri ilerletildi.

## Yapılan gerçek değişiklikler

- `PdfPageGeometryInspector` eklendi.
- Serialized PDF `/MediaBox` değerleri parse ediliyor.
- MediaBox bulunmayan, sıfır/negatif geometri taşıyan veya planlanan sayfa ölçüsünden kayan PDF fail-closed reddediliyor.
- `PdfLocalReportService`, renderer döndükten sonra exact `PdfReportPlan.pageSpec` genişlik/yüksekliğini point'e çevirerek serialized PDF geometri kapısını çalıştırıyor.
- A4 fixture kabulü, Letter (`612×792 pt`) drift reddi, missing MediaBox, non-positive geometry ve mixed MediaBox negatif regresyonları eklendi.
- Evidence exact `RC-0878` ve `RC-0879` sahipliğiyle eklendi.
- MASTER-aware structural validator ve ayrı `PDF Page Geometry Contract` GitHub Actions workflow'u eklendi.

## Kanıt sınırı

Bu çalışma source-level `IMPLEMENTED` kanıtıdır; DONE değildir. Approved production Unicode font artifact'iyle gerçek render, exact görünür Actions SUCCESS, visual regression ve gerçek cihaz PDF-open kanıtı halen gereklidir.

Workflow-target commit: `af1a72f6b97e46ce2c95edab826fff457b9518b9`.
GitHub combined-status sorgusunda individual check sonucu görünmedi (`statuses=[]`), bu nedenle SUCCESS/DONE uydurulmadı.

## Sıradaki iş

1. Page-geometry evidence'ını merkezi semantic traceability auditine bağla.
2. Font gerektirmeyen persisted PDF snapshot/data parity regresyonlarını genişlet.
3. Kalan UI/action/accessibility blocker-dışı işleri ilerlet.
4. Fiziksel data/font/UI blocker'larında kanıtsız DONE verme.

**FINAL: NO.**
