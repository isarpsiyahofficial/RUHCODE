# PDF font provenance

This directory is the release asset boundary for the combined PDF renderer.

- Family: `Noto Sans`
- License: `SIL Open Font License 1.1` (`OFL-1.1`)
- Canonical upstream: `https://github.com/notofonts/notofonts.github.io`
- Pinned upstream commit: `66c4b351c58f99ace5a6265d329080d74b057909`
- Upstream family path: `fonts/NotoSans/hinted/ttf`
- Regular upstream Git blob SHA-1: `f27f4ff59562d58480f1cb94194393484b8da9e9`
- Bold upstream Git blob SHA-1: `aae7546dc1905b228aff70cde8c818b82f3a2bc4`
- License upstream Git blob SHA-1: `9651ea7d51c39a7778cc327a423fb200350aa948`

`NotoSans-Regular.ttf`, `NotoSans-Bold.ttf` and `OFL.txt` are materialized only from the pinned commit. The materializer first recomputes each Git blob SHA-1 from the downloaded bytes. It then computes SHA-256 for the exact TTF binaries and writes those digests into `PdfFontReleaseManifest`. Production PDF byte rendering remains fail-closed until both distinct TTF binaries exist and the exact SHA-256 values are pinned.

Do not replace these files with system fonts, generated placeholders, a variable-font duplicate, or an unpinned network download.
