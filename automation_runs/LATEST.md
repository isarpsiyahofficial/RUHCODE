# Ruh Code — Latest Automation Checkpoint

Latest source-level checkpoint:

`automation_runs/2026-08-22_1453_western_atomic_persistence_sections.md`

## Bu turda ilerleyen ana bloklar

1. **Western atomic calculation persistence**
   - `CalculationManifest` + `western.natal` calculation aynı LocalDatabase transaction içinde yazılıyor
   - persisted snapshot canonical SHA-256 ile yazmadan önce mühürleniyor
   - engine/algorithm/data/house/zodiac parity save boundary'de fail-closed
   - calculation ikinci yazısı başarısız olursa manifest rollback ediliyor
   - existing calculation/manifest ID collision overwrite edilmiyor
2. **Persisted Western PDF sections**
   - placements / houses / aspects yalnız persisted snapshot üzerinden projekte ediliyor
   - historical ephemeris/natal/house recalculation yok
   - section rows aynı snapshot digest'i taşıyor
   - lokalize label eksikse fail-closed
3. **Evidence / CI contract**
   - persistence ve section source/test dosyaları evidence'a eklendi
   - Western PDF RC ownership yanlışlığı aynı turda düzeltildi
   - structural validator yeni atomiklik/no-recalculation sözleşmesini doğruluyor
   - dedicated Actions workflow yeni testleri kapsıyor

## Validation limitation

- Exact Flutter/Actions SUCCESS latest commit için görünür değil (`statuses=[]`); SUCCESS çıkarımı yapılmadı.
- Astronomical accuracy fiziksel ephemeris/EOP + independent golden comparison gerektiriyor.
- Final PDF visual quality approved glyph/vector assets + production Unicode font + visual regression gerektiriyor.

## Next safe work

- persisted Western evidence'ı merkezi semantic traceability validator'a exact RC setiyle dahil et
- atomic persistence service'i gerçek Western save application boundary'sine bağla
- persisted Western sections'i production calculation-type PDF handler'a bağla
- persisted CalculationManifest teknik PDF section'ı ekle; tekrar hesaplama yapma
- blocker-independent PDF/UI/backup/evidence auditlerine devam et
- physical ephemeris/EOP/Lahiri/GeoNames, 8.036 editorial daily messages, APPROVED UI refs, production PDF fonts and clean-checkout lockfile remain open blockers

**FINAL: NO.**
