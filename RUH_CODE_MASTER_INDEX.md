# RUH CODE — MASTER INDEX

**Bağlayıcı toplam kapsam: RC-0001 → RC-1442**

Ruh Code için bağlayıcı şartname iki dosyadan oluşur ve birlikte tek sözleşmedir:

1. [`RUH_CODE_MASTER_SARTNAME.md`](./RUH_CODE_MASTER_SARTNAME.md) — RC-0001 → RC-1420 tam ana şartname.
2. [`RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md`](./RUH_CODE_MASTER_SARTNAME_EK_RC1421_RC1442.md) — RC-1421 → RC-1442 bağlayıcı devam maddeleri.

Bu iki dosyadan herhangi biri tek başına tam şartname değildir. Geliştirme, test, UI, hesaplama, içerik, Free/PRO, offline, backup/restore, PDF, güvenlik ve release kararlarında toplam **1.442 madde** birlikte değerlendirilir.

## Uygulama planı

Bağımlılık sırasına göre ana çalışma planı:

- [`RUH_CODE_MASTER_TODO.md`](./RUH_CODE_MASTER_TODO.md)

## Final kuralı

Bir requirement yalnız kodlandığı için tamamlanmış sayılmaz. İlgili requirement için gereken calculation, interpretation, UI, interaction, TR/EN, offline, Free/PRO, backup, PDF, accessibility, performance, regression ve release doğrulamaları tamamlanmadan `DONE` durumu verilemez.

Bir tek zorunlu RC maddesi dahi açıkken veya kritik final kapılarından biri kırmızıyken Ruh Code veya ilgili modül **FINAL** olarak etiketlenemez.
