---
title: Sorgvry Architecture Decisions
date: 2026-03-29
status: draft
---

# Sorgvry Architecture Decisions

Decisions made during brainstorm session covering Drift schema sharing, sync strategy, Dart Frog backend, and app architecture.

## 1. Drift Schema Sharing

**Decision:** Single shared `SorgvryDatabase` class in `sorgvry_shared`.

- One `@DriftDatabase` class with all shared tables (MedLogs, BpReadings, WaterLogs, WalkLogs, Devices)
- Both app and backend instantiate it with their own `QueryExecutor`
  - App: `NativeDatabase` via `sqlite3_flutter_libs`
  - Backend: `NativeDatabase` via `sqlite3`
- Code generation runs in `sorgvry_shared`

**SyncQueue isolation:** App uses a separate `AppLocalDatabase` (defined in `app/`) for the `SyncQueue` table. Two DB files on device — health data and sync metadata stay cleanly separated.

## 2. Unique Constraints & Idempotency

Backend uses upsert (INSERT OR REPLACE) keyed on natural keys:

| Table | Unique constraint |
|-------|------------------|
| `med_logs` | `(deviceId, date, session)` |
| `bp_readings` | `(deviceId, date)` |
| `water_logs` | `(deviceId, date)` |
| `walk_logs` | `(deviceId, date)` |

Re-posting the same log overwrites. No client-generated UUIDs needed. Last-write-wins by `loggedAt`.

## 3. Sync Strategy

**Runner:** `Timer.periodic(60s)` in the main isolate. No background isolate or WorkManager.

- On each tick: read pending items from `SyncQueue`, POST to backend, mark synced on success
- On failure: increment attempts counter, retry next cycle
- Sufficient because Amanda will have the app open when logging

**Flow:**
1. User action -> write to local `SorgvryDatabase` (immediate)
2. Add entry to `AppLocalDatabase.syncQueue`
3. Timer fires -> flush queue -> POST to backend -> mark `synced=true` in both DBs

## 4. Dart Frog Backend

### Dependency Injection
Middleware `provider<SorgvryDatabase>()` attaches the DB to `RequestContext`. Routes access via `ctx.read<SorgvryDatabase>()`.

### JWT Auth
- Root middleware extracts `Bearer` token, verifies JWT signature against `JWT_SECRET`
- On success: attaches `deviceId` (from JWT payload) to context via `ctx.provide<String>()`
- `/auth/register` excluded from auth check
- Registration creates a new device record and returns a signed JWT

### Daily Summary Email
- In-process cron via `cron` package, started at server boot
- Fires at `0 19 * * *` (19:00 UTC = 21:00 SAST)
- Queries today's summary from DB, builds email, sends via `mailer` package
- Recipients from `SUMMARY_EMAIL_TO` env var

## 5. App Architecture

### State Management (Riverpod)
Three-layer provider structure per health module:

1. **DB providers** (global): `healthDbProvider`, `localDbProvider`
2. **Repository per module**: `MedsRepository`, `BpRepository`, `WaterRepository`, `WalkRepository`
   - Handles all DB reads/writes + sync queue insertion
3. **AsyncNotifier per module**: `MedsNotifier`, `BpNotifier`, `WaterNotifier`, `WalkNotifier`
   - Holds today's state, exposes action methods (confirm, save, etc.)
   - `build()` loads today's status from repository

### Navigation (GoRouter)
Single stack, named routes as per spec. No drawer or bottom nav.

### Notifications
- Cancel all pending notifications on every app launch
- Reschedule based on current state (skip notifications for already-completed items)
- Uses `flutter_local_notifications` for scheduling
- Tapping notification deep-links to relevant screen via GoRouter

## 6. File Structure (Expected)

```
sorgvry/
├── packages/
│   └── sorgvry_shared/
│       └── lib/
│           ├── database/
│           │   ├── tables.dart          # All table definitions
│           │   └── database.dart        # SorgvryDatabase class
│           │   └── database.g.dart      # Generated
│           ├── models/                  # Shared data models
│           └── api/
│               └── contracts.dart       # Request/response types
├── app/
│   └── lib/
│       ├── database/
│       │   └── local_database.dart      # AppLocalDatabase (SyncQueue)
│       ├── repositories/
│       │   ├── meds_repository.dart
│       │   ├── bp_repository.dart
│       │   ├── water_repository.dart
│       │   └── walk_repository.dart
│       ├── providers/
│       │   ├── db_providers.dart
│       │   ├── meds_providers.dart
│       │   ├── bp_providers.dart
│       │   ├── water_providers.dart
│       │   └── walk_providers.dart
│       ├── screens/
│       │   ├── home_screen.dart
│       │   ├── meds_screen.dart
│       │   ├── bp_screen.dart
│       │   ├── water_screen.dart
│       │   ├── walk_screen.dart
│       │   └── caregiver/
│       ├── services/
│       │   ├── sync_service.dart
│       │   └── notification_service.dart
│       ├── router.dart
│       └── main.dart
├── backend/
│   ├── routes/
│   │   ├── _middleware.dart             # DB provider + JWT auth
│   │   ├── auth/
│   │   │   └── register.dart
│   │   ├── log/
│   │   │   ├── meds.dart
│   │   │   ├── bp.dart
│   │   │   ├── water.dart
│   │   │   └── walk.dart
│   │   ├── summary.dart
│   │   ├── bp/
│   │   │   └── history.dart
│   │   └── export.dart
│   ├── lib/
│   │   ├── cron/
│   │   │   └── daily_summary.dart
│   │   └── middleware/
│   │       └── auth.dart
│   └── pubspec.yaml
└── melos.yaml
```
