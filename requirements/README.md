# Ruh Code Requirement Traceability

Ruh Code için bağlayıcı requirement kapsamı tam olarak `RC-0001 → RC-1442`'dir.

## Dosyalar

- `requirement_state.csv`: yalnız **manuel/explicit state override** gerektiğinde kullanılan sparse ledger.
- `requirement_matrix.csv`: `tools/requirements/build_requirement_matrix.py` tarafından CI sırasında üretilen tam 1.442 satırlık matrix.
- `evidence/**/*.json`: source/test/contract kanıtlarının makine-okunabilir sözleşmeleri.

## Durum semantiği

`requirement_state.csv` dosyasının sparse olması bir hata değildir. Bir RC için explicit satır yoksa matrix builder repository'deki evidence sözleşmelerini tarar:

- ilgili RC'yi sahiplenen `SOURCE_LEVEL_IMPLEMENTED`, `IMPLEMENTED`, `TESTED` veya `VERIFIED` evidence varsa matrix durumu **en fazla `IMPLEMENTED`** olarak otomatik türetilir;
- evidence yoksa durum `NOT_STARTED` olur;
- `TESTED`, `VERIFIED` veya `DONE` hiçbir zaman source evidence'dan otomatik yükseltilmez;
- **`DONE` yalnız `requirement_state.csv` içindeki explicit override ile mümkündür** ve evidence link zorunludur.

Bu konservatif politika, kod/test sözleşmesi yazılmış bir gereksinimin gerçek CI/golden/device/release kanıtı olmadan tamamlandı sayılmasını engeller.

## CI kapıları

`Requirements Contract` workflow'u:

1. MASTER RC sırasını doğrular.
2. Bütün evidence JSON bütünlüğünü kontrol eder.
3. Seçilmiş evidence ailelerinde semantic RC ownership'i MASTER metniyle karşılaştırır.
4. 1.442 satırlık matrix'i üretir.
5. Her non-default state için evidence link zorunluluğunu kontrol eder.
6. `validate_matrix_provenance.py` ile auto-IMPLEMENTED satırın gerçekten o RC'yi sahiplenen evidence'a bağlı olduğunu doğrular.
7. Generated matrix'i `ruh-code-requirement-matrix` Actions artifact'i olarak saklar.

## Final kuralı

Bir requirement'ın matrix'te `IMPLEMENTED` görünmesi **DONE değildir**. Final release için ilgili requirement'ın gerekli TESTED/VERIFIED/DONE kanıtları, bütün global release kapıları ve exact release artifact doğrulaması ayrıca tamamlanmalıdır.
