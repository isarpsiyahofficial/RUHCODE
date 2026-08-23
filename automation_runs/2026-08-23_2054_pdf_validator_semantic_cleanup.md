# Ruh Code — Automation Checkpoint — 2026-08-23 20:54

## Bu turda yapılan gerçek çalışma

### 1. Professional PDF validator drift düzeltildi

`tools/pdf/validate_professional_pdf_application.py` güncel runtime sözleşmesiyle çelişiyordu:

- eski `ACTION-PDF-PREVIEW-CREATE` / `ACTION-PDF-PREVIEW-SHARE` kimliklerini zorunlu tutuyordu,
- evidence dosyasında özellikle açık bırakılmış olmasına rağmen `RC-0952` requirement'ını sahiplenmeye zorluyordu.

Validator artık canonical builder action'larını doğruluyor:

- `ACTION-PDF-BUILDER-PREVIEW`
- `ACTION-PDF-BUILDER-CREATE`
- `ACTION-PDF-BUILDER-SHARE`

Ayrıca `RC-0952 — oluşan PDF'nin gerçekten açılabildiği otomatik kontrol` bağımsız full-parser/device-open kanıtı gelene kadar ownership kümesinin dışında ve explicit blocker olarak kalmak zorunda.

Commit: `b81aa699c30a0b5c08f2e5bd42ebb7546a0dad4b`

### 2. Combined PDF requirement overclaim temizlendi

`evidence/pdf/report_planning_contract.json` yalnız `PdfReportKind.combined` enum değerinin bulunmasına dayanarak `RC-0903 — kombine danışmanlık raporu birden fazla sistemi kapsayabilecek` requirement'ını sahipleniyordu.

Bu yeterli production kanıtı değildir. Gerçek bir combined report için birden fazla persisted calculation type'ın tek production handler/rapor içinde compose edilip render edilmesi gerekir.

Bu nedenle:

- `RC-0903` report-planning evidence ownership'ından çıkarıldı,
- release blocker olarak açıkça kaydedildi,
- semantic validator `RC-0903` tekrar yanlışlıkla ownership'e eklenirse fail-closed olacak şekilde güncellendi.

Commits:
- `75a5cf3ae9648b5d0aab99ba2475bd6f0a985cb9`
- `b04fb6fa4dd701f64d822e72a3c67cb19946fcb4`

## DONE / FINAL durumu

Hiçbir requirement yalnız bu source-level düzeltmeler nedeniyle DONE yapılmadı.

Açık kritik kanıtlar devam ediyor:

- RC-0952 full PDF parser/open proof,
- RC-0903 gerçek multi-system combined report composition,
- production Unicode PDF font + lisans/hash,
- APPROVED UI reference/hash seti,
- fiziksel ephemeris/EOP/Lahiri/GeoNames artifact kanıtları,
- 8.036 gerçek editoryal Günün Mesajı,
- Play/rewarded gerçek cihaz kanıtı,
- clean-checkout reproducible release APK ve final lifecycle.

## Next safe work

1. Professional PDF validator/evidence semantic sahipliğini merkezi Requirements Contract ile çaprazlamayı genişlet.
2. Kalan PDF evidence dosyalarında RC ownership overclaim taramasını sürdür.
3. Font gerektirmeyen persisted snapshot/data parity ve UI/action/accessibility regressionlarını ilerlet.
4. Blocker'larda kanıtsız DONE verme.

**FINAL: NO.**
