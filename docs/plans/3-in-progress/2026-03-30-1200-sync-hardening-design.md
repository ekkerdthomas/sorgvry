# Sync Hardening: Error Tracking & Debug Visibility

**Status**: Draft
**Issue**: #17 — Sync: APK not syncing today's data to backend
**Date**: 2026-03-30

## Problem

SyncService silently swallows all errors in a double try-catch. When sync fails (wrong URL, expired JWT, network down), there is zero visibility — no logs, no UI indicator, no way to know sync is broken without checking the backend DB directly.

Amanda's APK has been silently failing to sync since 2026-03-30 despite capturing data locally.

## Approach: In-Memory SyncStatus + ValueNotifier

Track sync state in a `SyncStatus` value object inside `SyncService`, exposed via a `ValueNotifier`. No DB schema changes needed. The debug dialog (5-tap on version number) reads the notifier to show detailed sync diagnostics.

## Design

### 1. SyncStatus Value Object

New file: `app/lib/services/sync_status.dart`

```dart
class SyncStatus {
  final DateTime? lastSuccessfulSync;
  final String? lastError;
  final int consecutiveErrors;
  final Map<String, int> unsyncedCounts;

  const SyncStatus({
    this.lastSuccessfulSync,
    this.lastError,
    this.consecutiveErrors = 0,
    this.unsyncedCounts = const {},
  });

  bool get isHealthy => consecutiveErrors == 0 && lastError == null;
}
```

### 2. SyncService Changes

- Add `final ValueNotifier<SyncStatus> statusNotifier = ValueNotifier(const SyncStatus());`
- After successful `_flush()`: update `lastSuccessfulSync`, reset `consecutiveErrors` and `lastError`
- On `_flush()` catch: increment `consecutiveErrors`, set `lastError` to exception message
- Before each flush: query unsynced counts per table and update `unsyncedCounts`

```dart
// In _flush():
try {
  _token ??= await _loadOrRegisterToken();
  final unsynced = await _countUnsynced();
  statusNotifier.value = SyncStatus(
    lastSuccessfulSync: statusNotifier.value.lastSuccessfulSync,
    unsyncedCounts: unsynced,
  );
  await _syncMeds();
  await _syncBp();
  await _syncWater();
  await _syncWalk();
  await _syncMedia();
  statusNotifier.value = SyncStatus(
    lastSuccessfulSync: DateTime.now(),
    consecutiveErrors: 0,
    unsyncedCounts: await _countUnsynced(),
  );
} catch (e) {
  statusNotifier.value = SyncStatus(
    lastSuccessfulSync: statusNotifier.value.lastSuccessfulSync,
    lastError: e.toString(),
    consecutiveErrors: statusNotifier.value.consecutiveErrors + 1,
    unsyncedCounts: statusNotifier.value.unsyncedCounts,
  );
}
```

New helper:

```dart
Future<Map<String, int>> _countUnsynced() async {
  return {
    'meds': (await (healthDb.select(healthDb.medLogs)..where((t) => t.synced.equals(false))).get()).length,
    'bp': (await (healthDb.select(healthDb.bpReadings)..where((t) => t.synced.equals(false))).get()).length,
    'water': (await (healthDb.select(healthDb.waterLogs)..where((t) => t.synced.equals(false))).get()).length,
    'walk': (await (healthDb.select(healthDb.walkLogs)..where((t) => t.synced.equals(false))).get()).length,
    'media': (await (healthDb.select(healthDb.mediaAttachments)..where((t) => t.synced.equals(false))).get()).length,
  };
}
```

### 3. Riverpod Provider

In `app/lib/providers/db_providers.dart` (or new `sync_providers.dart`):

```dart
final syncStatusProvider = Provider<ValueNotifier<SyncStatus>>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
```

Override in `main.dart` alongside existing providers:

```dart
syncStatusProvider.overrideWithValue(_syncService!.statusNotifier),
```

### 4. Debug Dialog Enhancement

Add sync status rows to `_showDebugDialog()` in `home_screen.dart`:

```dart
ValueListenableBuilder<SyncStatus>(
  valueListenable: ref.read(syncStatusProvider),
  builder: (context, status, _) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Divider(),
      const Text('Sinkronisasie', style: TextStyle(fontWeight: FontWeight.bold)),
      _debugRow('Laaste sukses', status.lastSuccessfulSync?.toLocal().toString() ?? 'Nog nooit'),
      _debugRow('Status', status.isHealthy ? 'Gesond' : 'Fout (${status.consecutiveErrors}x)'),
      if (status.lastError != null)
        _debugRow('Laaste fout', status.lastError!),
      _debugRow('Ongesinkroniseer', status.unsyncedCounts.entries
        .where((e) => e.value > 0)
        .map((e) => '${e.key}: ${e.value}')
        .join(', ')
        .ifEmpty('Geen')),
    ],
  ),
)
```

### 5. Rebuild & Deploy APK

After code changes, run `scripts/build.sh` + `scripts/deploy.sh` to:
1. Build APK with correct `BACKEND_URL=https://sorgvry.phygital-tech.ai/api`
2. Deploy to Pi so Amanda downloads the new version

## Files Touched

| File | Change |
|------|--------|
| `app/lib/services/sync_status.dart` | **NEW** — SyncStatus value object |
| `app/lib/services/sync_service.dart` | Add statusNotifier, update on flush success/failure, add `_countUnsynced()` |
| `app/lib/providers/db_providers.dart` | Add `syncStatusProvider` |
| `app/lib/main.dart` | Override `syncStatusProvider` with `_syncService!.statusNotifier` |
| `app/lib/screens/home_screen.dart` | Expand debug dialog with sync status section |

## What This Does NOT Do

- No retry backoff (still retries every 60s — acceptable for this use case)
- No persistent sync history across app restarts (in-memory only)
- No home screen banner for Amanda (keeps her UI simple)
- No caregiver dashboard integration (future enhancement if needed)
