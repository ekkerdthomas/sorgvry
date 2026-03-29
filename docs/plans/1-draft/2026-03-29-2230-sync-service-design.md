# Sync Service — Queue Flush Implementation

**Date:** 2026-03-29
**Status:** Draft
**Scope:** `app/lib/services/sync_service.dart` and supporting changes

## Problem

All health data is written locally with `synced=false`, but nothing ever flushes it to the Dart Frog backend on the Raspberry Pi. The 60-second timer exists but `_flush()` is a no-op.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Sync strategy | Scan health tables for `synced=false` | Simpler than SyncQueue — the `synced` column IS the queue. No double-write. |
| Auth | Auto-register on first flush | Call `/auth/register` with devDeviceId + 'Amanda', persist JWT in AppLocalDatabase key-value table. Real registration slots in later. |
| Retry policy | Silent retry next cycle | LAN-only app. If Pi is down, try again in 60s. No backoff, no attempt counter. |

## Design

### Data Flow

```
Timer fires (60s)
    ↓
_flush()
    ├── Ensure JWT token (auto-register if missing)
    ├── Query medLogs WHERE synced = false
    │   └── POST /log/meds for each → mark synced = true
    ├── Query bpReadings WHERE synced = false
    │   └── POST /log/bp for each → mark synced = true
    ├── Query waterLogs WHERE synced = false
    │   └── POST /log/water for each → mark synced = true
    └── Query walkLogs WHERE synced = false
        └── POST /log/walk for each → mark synced = true
```

### Token Persistence

Add a `KeyValue` table to `AppLocalDatabase` (schema version bump to 2 with migration):

```dart
class KeyValue extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
```

Store `auth_token` and `device_id` as key-value pairs.

### SyncService Changes

```dart
class SyncService {
  final SorgvryDatabase healthDb;
  final AppLocalDatabase localDb;
  final http.Client _client;
  final String _baseUrl;
  Timer? _timer;
  String? _token;

  void start() {
    _timer = Timer.periodic(Duration(seconds: 60), (_) => _flush());
  }

  Future<void> _flush() async {
    try {
      _token ??= await _loadOrRegisterToken();
    } catch (_) {
      return; // can't auth, skip this cycle
    }

    await _syncTable<MedLog>(
      query: healthDb.select(healthDb.medLogs)
        ..where((t) => t.synced.equals(false)),
      endpoint: '/log/meds',
      toJson: (row) => MedLogRequest(
        deviceId: row.deviceId,
        date: row.date.toIso8601String().substring(0, 10),
        session: row.session,
        taken: row.taken,
        loggedAt: row.loggedAt.toIso8601String(),
      ).toJson(),
      markSynced: (row) => (healthDb.update(healthDb.medLogs)
        ..where((t) => t.id.equals(row.id)))
        .write(MedLogsCompanion(synced: Value(true))),
    );
    // ... repeat for bp, water, walk
  }
}
```

### Files to Modify

| File | Change |
|------|--------|
| `app/lib/services/sync_service.dart` | Implement `_flush()`, add HTTP client, token management |
| `app/lib/database/local_database.dart` | Add `KeyValue` table, bump schema to v2, add migration |
| `app/lib/main.dart` | Start SyncService after DB init, pass base URL from config |
| `app/lib/config.dart` | Ensure `apiBase` is available (already exists) |
| `app/pubspec.yaml` | Add `http` package dependency |

### What We're NOT Doing

- **Removing SyncQueue table** — leave it for now, removing requires a migration
- **Pull sync** — server → device sync is out of scope (spec says device is authoritative for today)
- **Connectivity checks** — unnecessary complexity for LAN-only
- **Retry backoff** — 60s cycle is the backoff

## Verification

1. `flutter analyze` — zero issues
2. `flutter test` — existing tests pass
3. Manual: start backend (`dart run .dart_frog/server.dart`), start app, confirm meds, check backend DB for synced row
