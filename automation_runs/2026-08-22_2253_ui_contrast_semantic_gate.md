# Ruh Code — UI Contrast / Accessibility Checkpoint

Bu tur RC-1441 accessibility hattında ölçülebilir source-level ilerleme yaptı.

## Yapılan gerçek değişiklikler

- `ui/design_tokens.json` 1.1.0 sürümüne yükseltildi.
- Normal metin için minimum kontrast **4.5:1**, büyük metin için **3.0:1** sözleşmeye bağlandı.
- `textPrimary`, `textMuted`, `primary`, `primaryStrong` ve `danger` için canonical light-surface foreground/background çiftleri açıkça tanımlandı.
- `tools/ui/validate_design_tokens.py` artık WCAG sRGB relative-luminance formülüyle kontrast oranını gerçekten hesaplıyor; token adına bakarak erişilebilir varsaymıyor.
- Mevcut palette denetiminde `gold` ve `success` açık zeminlerde normal metin için yeterli kontrast sağlamadığından bunlar `background/surface/surfaceSoft` üzerinde **non-text accent** olarak kilitlendi.
- `ui/accessibility_interaction_contract.json` ölçülen design-token kontrast kapısına bağlandı.
- `evidence/ui/design_token_contrast_contract.json` eklendi ve exact `RC-1441` sahipliğiyle merkezi semantic evidence auditine alındı.
- `Requirements Contract` artık design-token contrast validator ve accessibility/interaction validator’ı doğrudan çalıştırıyor.

## Neden önemli

Daha önce şartname 4.5:1 / 3.0:1 hedefini söylüyordu fakat palette’in gerçek hex değerleri üzerinden otomatik ölçüm yoktu. Bu turdan sonra palette değişikliği normal metin kontrastını bozarsa merkezi requirement CI fail-closed olacak.

## DONE yapılmayan parçalar

- gerçek cihaz screen-reader traversal,
- tüm gerekli ekran state’lerinde 2.0x text-scale overflow/golden kontrolü,
- rendered widget’larda ad-hoc low-contrast color kullanımının tam taraması,
- APPROVED UI reference visual regression,
- exact görünür GitHub Actions SUCCESS.

Bu nedenle `RC-1441` **DONE yapılmadı**.

Workflow-target source commit: `b4c7aad7d13ea3282589567e0da5b481889e7b5f`.

**FINAL: NO.**