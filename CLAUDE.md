# Sorgvry

Afrikaans health companion app for Amanda Thomas. Offline-first Flutter app + Dart Frog backend on Raspberry Pi.

## Project Structure

Melos mono-repo:
- `packages/sorgvry_shared/` — Drift database schema, models, API contracts (shared by app and backend)
- `app/` — Flutter Android app (Riverpod + GoRouter)
- `backend/` — Dart Frog API server

## Tech Stack

| Layer | Technology |
|-------|-----------|
| App framework | Flutter (Android only) |
| State management | Riverpod (AsyncNotifier + Repository pattern) |
| Navigation | GoRouter |
| Database | SQLite via Drift (shared schema in sorgvry_shared) |
| Backend | Dart Frog |
| Auth | JWT (dart_jsonwebtoken) |
| Mono-repo | Melos |

## Architecture Decisions

See `docs/plans/1-draft/2026-03-29-1800-architecture-decisions-design.md` for full details.

Key decisions:
- **Shared DB class**: Single `SorgvryDatabase` in `sorgvry_shared`, instantiated with platform-specific executor
- **SyncQueue isolation**: Separate `AppLocalDatabase` in app for sync metadata
- **Idempotency**: Upsert by natural keys (deviceId+date+session for meds, deviceId+date for others)
- **Sync**: Timer.periodic(60s) in main isolate
- **Backend DI**: Dart Frog middleware `provider<SorgvryDatabase>()`
- **Auth**: JWT bearer token, deviceId in payload, `/auth/register` excluded
- **Providers**: Repository + AsyncNotifier per module (meds, bp, water, walk)
- **Notifications**: Cancel-and-reschedule on every app launch

## Commands

```bash
# Local dev (backend + app together)
./scripts/dev.sh

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
- Route paths use Afrikaans names: `/medisyne`, `/bloeddruk`, `/water`, `/stap`, `/versorger`
- Large tap targets (min 72px button height) — designed for an elderly user
- All health data has a `synced` boolean column for offline-first tracking
- Drift tables use unique constraints on natural keys for upsert support
- Each health module (meds, bp, water, walk) follows the same pattern: Table → Repository → AsyncNotifier → Screen

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
