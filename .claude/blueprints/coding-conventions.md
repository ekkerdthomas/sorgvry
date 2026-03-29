# Coding Conventions — Sorgvry

> Single source of truth for naming, limits, patterns, and banned practices.

## Naming Conventions

### Classes & Types

| Category | Convention | Example |
|----------|-----------|---------|
| Drift Table | `<Entity>s` (plural) | `MedLogs`, `BpReadings`, `WaterLogs` |
| Repository | `<Module>Repository` | `MedsRepository`, `BpRepository` |
| Notifier | `<Module>Notifier` | `MedsNotifier`, `WaterNotifier` |
| State | `<Module>State` | `MedsState`, `BpState` |
| Screen | `<Feature>Screen` | `HomeScreen`, `MedsScreen`, `BpScreen` |
| Service | `<Domain>Service` | `SyncService`, `NotificationService` |
| Database | `SorgvryDatabase` (shared), `AppLocalDatabase` (app-only) | — |

### Variables & Functions

| Category | Convention | Good | Bad |
|----------|-----------|------|-----|
| Boolean | `is<State>`, `has<Thing>` | `isSynced`, `hasTaken` | `synced`, `taken` (as var name) |
| Callback | `on<Event>` | `onConfirm`, `onTap` | `handleConfirm` |
| Provider | `<module><Type>Provider` | `medsRepoProvider`, `medsNotifierProvider` | `getMeds`, `medsProvider` |
| Private | `_` prefix | `_flush()`, `_timer` | — |

### Files

| Category | Convention | Example |
|----------|-----------|---------|
| Dart source | `snake_case.dart` | `meds_repository.dart`, `bp_screen.dart` |
| Test | `<source>_test.dart` | `meds_repository_test.dart` |
| Drift table | `tables.dart` (all in one file) | `packages/sorgvry_shared/lib/database/tables.dart` |
| Generated | `*.g.dart` (never edit) | `database.g.dart` |

## File Size Limits

| File Type | Soft Limit | Hard Limit | Action at Soft | Action at Hard |
|-----------|-----------|------------|----------------|----------------|
| Repository | 200 lines | 350 lines | Review scope | Split by query type |
| Notifier | 150 lines | 250 lines | Review complexity | Extract helpers |
| Screen | 300 lines | 500 lines | Extract widgets | Must extract |
| Service | 200 lines | 400 lines | Review scope | Split responsibilities |
| Test file | 400 lines | 700 lines | Group by concern | Split test file |

## Function Length

- **Target**: < 30 lines per function/method
- **Warning**: 30-50 lines — consider extraction
- **Hard limit**: > 50 lines — must extract

## Import Ordering

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter framework
import 'package:flutter/material.dart';

// 3. Third-party packages
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart';

// 4. Project packages (shared first, then local)
import 'package:sorgvry_shared/database/database.dart';
import 'package:sorgvry_shared/models/med_log.dart';

// 5. Relative imports (same package)
import '../repositories/meds_repository.dart';
import '../providers/db_providers.dart';
```

## Layer Boundaries

| Layer (top→bottom) | May import | Must NOT import |
|--------------------|-----------|-----------------|
| Screen / Widget | Notifier (via provider) | Repository, Database |
| Notifier | Repository | Screen, Database directly |
| Repository | Database, Models | Screen, Notifier |
| Database / Model | (none — leaf layer) | Any higher layer |
| Service (Sync, Notifications) | Repository, Database | Screen |

## Drift-Specific Patterns

### Table Definitions

```dart
// All tables in packages/sorgvry_shared/lib/database/tables.dart
class MedLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  DateTimeColumn get date => dateTime()();
  // ... columns
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  // Unique constraint for upsert support
  @override
  List<Set<Column>> get uniqueKeys => [{deviceId, date, session}];
}
```

### DAOs

Define DAOs in `sorgvry_shared` for reusable query logic:

```dart
@DriftAccessor(tables: [MedLogs])
class MedLogsDao extends DatabaseAccessor<SorgvryDatabase> with _$MedLogsDaoMixin {
  MedLogsDao(SorgvryDatabase db) : super(db);

  Future<List<MedLog>> forDate(String deviceId, DateTime date) { ... }
  Future<void> upsert(MedLogsCompanion entry) { ... }
}
```

## Riverpod Patterns

### Provider Declaration

```dart
// DB providers (top-level, global)
final healthDbProvider = Provider<SorgvryDatabase>((ref) => throw UnimplementedError());
final localDbProvider = Provider<AppLocalDatabase>((ref) => throw UnimplementedError());

// Repository provider
final medsRepoProvider = Provider<MedsRepository>((ref) {
  return MedsRepository(
    db: ref.watch(healthDbProvider),
    localDb: ref.watch(localDbProvider),
  );
});

// Notifier provider
final medsNotifierProvider = AsyncNotifierProvider<MedsNotifier, MedsState>(
  MedsNotifier.new,
);
```

### Override DB Providers at App Root

```dart
// main.dart
void main() {
  final healthDb = SorgvryDatabase(NativeDatabase.createInBackground(...));
  final localDb = AppLocalDatabase(NativeDatabase.createInBackground(...));

  runApp(ProviderScope(
    overrides: [
      healthDbProvider.overrideWithValue(healthDb),
      localDbProvider.overrideWithValue(localDb),
    ],
    child: const SorgvryApp(),
  ));
}
```

## UI Conventions

- All user-facing text in **Afrikaans**
- Minimum tap target: **72px** button height
- Card border radius: **16px**, button border radius: **12px**
- Card padding: **24px**, grid gap: **12px**
- Minimum body text: **18px**
- Use design tokens from spec section 9 (colors, typography, spacing)
- No drawer, no bottom nav — single-stack navigation

## Dart Frog Backend Patterns

### Route Handler

```dart
// backend/routes/log/meds.dart
Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.post => _onPost(context),
    _ => Future.value(Response(statusCode: HttpStatus.methodNotAllowed)),
  };
}

Future<Response> _onPost(RequestContext context) async {
  final db = context.read<SorgvryDatabase>();
  final deviceId = context.read<String>(); // from auth middleware
  final body = await context.request.json() as Map<String, dynamic>;
  // ... validate and upsert
  return Response.json(body: {'ok': true});
}
```

## Banned Patterns

| Pattern | Reason | Alternative |
|---------|--------|-------------|
| Hardcoded device IDs | Testing artifact leaking to prod | Use UUID generation |
| `print()` for logging | No structured logging | Use `dart:developer` log or a logger |
| `// TODO: fix later` | Untracked deferred work | Create an issue or fix now |
| Hardcoded secrets/URLs | Security risk | Use env vars / compile-time defines |
| `dynamic` type | Type safety bypass | Define proper types |
| `catch (e) {}` (empty catch) | Hides real bugs | Handle or rethrow |
| Direct DB access from Screen | Layer violation | Go through Repository → Notifier |

## YAGNI

- Don't add multi-patient support yet (Phase 2)
- Don't add web dashboard yet (Phase 2)
- Don't add WhatsApp/Telegram alerts yet (Phase 2)
- Don't abstract for multiple DB backends — it's SQLite everywhere
- Don't add i18n framework — Afrikaans only, hardcoded strings are fine
