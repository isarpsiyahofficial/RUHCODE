# Ruh Code automation checkpoint — guarded PRO surfaces

Date: 2026-08-20

## Implemented in this run

- Extended the production navigation shell beyond basic Tools routes.
- Added an explicit PRO-only `Gelişmiş Batı Analizi` route using canonical `western.advanced`.
- Replaced the Records placeholder with a real records surface containing `Profillerim` and a guarded professional `Danışanlarım` route using `professional.clients`.
- Replaced the Profile placeholder with PDF surfaces: Free `PDF Rapor Önizleme` uses `pdf.sample_preview`; `Profesyonel PDF Raporu` uses guarded `pdf.professional_export`.
- All guarded route entry points use the existing single `FeatureAccessGuard` / `EntitlementService` source rather than local premium booleans.
- Extended widget tests to prove Free users cannot enter advanced Western, professional-clients, or professional-PDF routes; Free sample PDF remains accessible; PRO users can enter professional routes.
- Updated the entitlement evidence contract to record the concrete guarded route surfaces while keeping `done=false` until real-store/device/release evidence exists.
- Expanded `Feature Entitlement Contract` workflow path coverage and test execution so guarded navigation changes execute the entitlement unit suite plus the UI route matrix.

## Commits

- `799c815161cee4b4dd8aa198b476b194fc073f32` — guarded Records/PDF/advanced UI surfaces.
- `354783d9037e535a197a2284c3706b5f8390b252` — Free/PRO UI route matrix tests.
- `f1e4b681df661c91091a93f0a7ee5aa7226cb8d5` — entitlement evidence update.
- `095dcea75b6c43859abd628ed92dfd0bcfae5d5f` — CI coverage for guarded UI routes.

## Evidence status

Source-level implementation advanced. Requirement state must not be promoted to DONE until the exact workflow run is visibly successful and the remaining real-device Play/rewarded/release evidence is obtained.

## Next safe work

1. Inspect the exact entitlement workflow result; fix immediately if red.
2. Bind concrete service operations (professional PDF export and professional-client mutations as their production services are connected) through `FeatureAccessGuard.runService`, not UI-only checks.
3. Replace placeholder feature page bodies with approved production screen references without weakening route guards.
4. Continue independent blockers in parallel: production Unicode PDF font asset/license/hash, PDF painter/glyph/golden tests, physical EOP/ephemeris/GeoNames artifacts, 8,036 editorial Daily Messages, and APPROVED UI reference PNG set.

**FINAL değil.**
