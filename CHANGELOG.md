# Changelog

## [v0.4.0] - 2026-03-29

### app
#### Added
- Redesign BP confirmation screen with colour-coded MAP status block (54a9327)
- Add KLAAR button to meds and water screens for consistent navigation (6c78d39)
- Add light blue tint to water card for visual context (1a7007c)

#### Fixed
- Centre BP reading on already-measured view (2d8d315)

### backend
#### Added
- Add CORS middleware for local dev E2E sync (89d66ae)

## [v0.3.1] - 2026-03-29

### app
#### Fixed
- Prevent text overflow on home screen cards (6d003f4)
- Center blood pressure reading on already-measured view (00f94b9)

## [v0.3.0] - 2026-03-29

### app
#### Added
- Photo capture and MinIO media sync for all health modules (9ceea02)
- Enable sync for PWA and replace hardcoded device ID with auto-generated UUID (b048a70)

#### Fixed
- Delay MAP display until 2 diastolic digits and correct thresholds (8eab3be)

#### Changed
- Reduce vertical card padding on home screen to prevent text clipping (0e9f442)

### backend
#### Added
- Photo capture and MinIO media sync with upload/proxy endpoints (9ceea02)
- Enable sync for PWA and replace hardcoded device ID with auto-generated UUID (b048a70)

### sorgvry_shared
#### Added
- MediaAttachments Drift table (schema v2) and MediaUploadFields contract (9ceea02)

## [v0.2.0] - 2026-03-29

### app
#### Added
- Scaffold mono-repo with shared schema, flutter app, and dart frog backend (643a6d2)
- Implement 4 health modules with real DB queries and full UI (3533287)
- Implement sync service with auto-registration and queue flush (bd58e0e)
- Add hosting infrastructure, web deploy, and lean APK build (23aceb9)
- Redesign meds screen with dosage details, session titles, and B12 schedule (d1a3f25)

#### Fixed
- Enable web dev preview and replace stub throws with default returns (5c5dc7d)
- Replace hardcoded Colors.blue with theme colors and add missing back button (f37ff7b)

#### Changed
- Extract SorgvryLogo widget and remove dead branding code (3ddcc19)

### backend
#### Added
- Scaffold mono-repo with shared schema, flutter app, and dart frog backend (643a6d2)
- Add hosting infrastructure, web deploy, and lean APK build (23aceb9)

#### Fixed
- Enable web dev preview and replace stub throws with default returns (5c5dc7d)

### sorgvry_shared
#### Added
- Scaffold mono-repo with shared schema, flutter app, and dart frog backend (643a6d2)
