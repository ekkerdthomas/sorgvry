# Sorgvry

Afrikaans health companion app for Amanda Thomas. Offline-first Flutter app (Android + Web PWA) with Dart Frog backend on Raspberry Pi.

## Project Structure

Melos mono-repo:
- `packages/sorgvry_shared/` — Drift database schema, models, API contracts (shared by app and backend)
- `app/` — Flutter app (Android + Web PWA, Riverpod + GoRouter)
- `backend/` — Dart Frog API server
- `scripts/` — Build, deploy, and local dev scripts
- `docs/` — Spec and design plans

## Tech Stack

| Layer | Technology |
|-------|-----------|
| App framework | Flutter (Android + Web PWA) |
| State management | Riverpod (AsyncNotifier + Repository pattern) |
| Navigation | GoRouter |
| Database | SQLite via Drift (shared schema in sorgvry_shared) |
| Backend | Dart Frog |
| Auth | JWT (dart_jsonwebtoken) |
| Media storage | MinIO (S3-compatible, on Pi) |
| Email | Mailer + Cron (daily summaries) |
| Mono-repo | Melos |

## Architecture Decisions

See `docs/plans/4-done/2026-03-29-1800-architecture-decisions-design.md` for full details.

Key decisions:
- **Shared DB class**: Single `SorgvryDatabase` in `sorgvry_shared`, instantiated with platform-specific executor
- **SyncQueue isolation**: Separate `AppLocalDatabase` in app for sync metadata
- **Idempotency**: Upsert by natural keys (deviceId+date+session for meds, deviceId+date for others)
- **Sync**: Timer.periodic(60s) in main isolate
- **Backend DI**: Dart Frog middleware `provider<SorgvryDatabase>()`
- **Auth**: JWT bearer token, deviceId in payload, `/auth/register` excluded
- **Providers**: Repository + AsyncNotifier per module (meds, bp, water, walk, media)
- **Notifications**: Cancel-and-reschedule on every app launch
- **Media**: Photo capture via image_picker, uploaded to MinIO, proxied through backend
- **Web support**: Platform-specific SQLite executors (native for Android, WASM for web)

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/` | Health check |
| GET | `/health` | Health status |
| POST | `/auth/register` | Device registration (no auth) |
| POST | `/log/meds` | Log medication |
| POST | `/log/bp` | Log blood pressure |
| POST | `/log/water` | Log water intake |
| POST | `/log/walk` | Log walking |
| POST | `/log/media` | Upload photo (multipart) |
| GET | `/media/:key` | Proxy MinIO media file |
| POST | `/media/index` | List uploaded media |
| GET | `/summary` | Daily health summary |
| GET | `/bp/history` | Blood pressure history |
| GET | `/data-export` | CSV export of all data |

## Commands

```bash
# Local dev (backend + app together in Chrome)
./scripts/dev.sh

# Build web + APK
./scripts/build.sh

# Deploy to Pi (backend Docker, web, APK)
./scripts/deploy.sh

# Bootstrap mono-repo
melos bootstrap

# Run code generation (Drift)
melos run build_runner

# Run all tests
melos run test

# Run Flutter app
cd app && flutter run

# Run Dart Frog backend
cd backend && dart_frog dev

# Dart analyze
melos run analyze

# Dart format
melos run format
```

## Conventions

- UI language is **Afrikaans** — all user-facing strings in Afrikaans
- Code language is **English** — variable names, comments, docs in English
- Route paths use Afrikaans names: `/medisyne`, `/bloeddruk`, `/water`, `/stap`, `/versorger`, `/versorger/dashboard`
- Large tap targets (min 72px button height) — designed for an elderly user
- All health data has a `synced` boolean column for offline-first tracking
- Drift tables use unique constraints on natural keys for upsert support
- Each health module (meds, bp, water, walk) follows the same pattern: Table → Repository → AsyncNotifier → Screen
- Backend URL configured via `--dart-define BACKEND_URL` (defaults to localhost:8080, prod uses `/api`)

## Deployment

- **Host**: Raspberry Pi (`raspi-webserver`) at `/opt/sorgvry`
- **Backend**: Docker container, port 8600 → 8080, volume at `/app/data`
- **Web**: `https://sorgvry.phygital-tech.ai/`
- **APK**: `https://sorgvry.phygital-tech.ai/download/sorgvry.apk`
- **API**: `https://sorgvry.phygital-tech.ai/api/`
- **Env vars**: `DB_PATH`, `JWT_SECRET`, `MINIO_ENDPOINT`, `MINIO_ACCESS_KEY`, `MINIO_SECRET_KEY`, `MINIO_BUCKET`

## Testing

```bash
# Run tests per package
cd packages/sorgvry_shared && dart test
cd app && flutter test
cd backend && dart test
```

- Test files mirror source: `test/<path>/<name>_test.dart`
- Use in-memory SQLite for DB tests
- Mock HTTP for sync/API tests
- Integration tests for Drift queries against real SQLite

## Spec

Full specification at `docs/sorgvry-spec.md` — covers all screens, API contracts, notification schedule, B12 injection logic, and caregiver mode.
