# Testing Patterns — Sorgvry

> Test organization, patterns, mocks, and fixtures for the Sorgvry mono-repo.

## Test Organization

### Where Tests Live

| Package | Test Location | Runner | Command |
|---------|--------------|--------|---------|
| sorgvry_shared | `packages/sorgvry_shared/test/` | `dart test` | `melos run test:shared` |
| app | `app/test/` | `flutter test` | `melos run test:app` |
| backend | `backend/test/` | `dart test` | `melos run test:backend` |

### File Naming

Test files mirror source files:

```
packages/sorgvry_shared/
  lib/database/tables.dart
  test/database/tables_test.dart

app/
  lib/repositories/meds_repository.dart
  test/repositories/meds_repository_test.dart

  lib/screens/meds_screen.dart
  test/screens/meds_screen_test.dart

backend/
  routes/log/meds.dart
  test/routes/log/meds_test.dart
```

## TDD Cycle

```
RED:      Write a failing test that describes the desired behavior
GREEN:    Write the minimum code to make the test pass
REFACTOR: Improve the code while keeping tests green
```

### When to Use TDD

| Scenario | TDD Approach |
|----------|-------------|
| New Drift table/query | Write query test → define table → implement DAO method |
| New API endpoint | Define expected request/response → test route handler → implement |
| New repository method | Test expected DB interactions → implement method |
| Bug fix | Reproduce bug in test → fix → verify |
| Sync logic | Test queue/flush behavior → implement SyncService |

## Per-Layer Test Patterns

### Drift Database Tests (sorgvry_shared)

Use in-memory SQLite for fast, isolated tests:

```dart
void main() {
  late SorgvryDatabase db;

  setUp(() {
    db = SorgvryDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('should upsert med log by deviceId, date, session', () async {
    // Arrange
    final entry = MedLogsCompanion(
      deviceId: const Value('device-1'),
      date: Value(DateTime(2026, 4, 1)),
      session: const Value('morning'),
      taken: const Value(true),
      loggedAt: Value(DateTime.now()),
    );

    // Act — insert twice
    await db.into(db.medLogs).insertOnConflictUpdate(entry);
    await db.into(db.medLogs).insertOnConflictUpdate(
      entry.copyWith(taken: const Value(false)),
    );

    // Assert — only one row, with updated value
    final rows = await db.select(db.medLogs).get();
    expect(rows, hasLength(1));
    expect(rows.first.taken, isFalse);
  });
}
```

### Repository Tests (app)

Mock the database, test repository logic:

```dart
void main() {
  late SorgvryDatabase db;
  late AppLocalDatabase localDb;
  late MedsRepository repo;

  setUp(() {
    db = SorgvryDatabase(NativeDatabase.memory());
    localDb = AppLocalDatabase(NativeDatabase.memory());
    repo = MedsRepository(db: db, localDb: localDb);
  });

  tearDown(() async {
    await db.close();
    await localDb.close();
  });

  test('should return today morning status as not taken when no log exists', () async {
    final status = await repo.todayStatus();
    expect(status.morningTaken, isFalse);
  });

  test('should add to sync queue when confirming medication', () async {
    await repo.confirmMeds(session: 'morning', taken: true);

    final queue = await localDb.select(localDb.syncQueue).get();
    expect(queue, hasLength(1));
    expect(queue.first.endpoint, '/log/meds');
  });
}
```

### Notifier Tests (app)

Use ProviderContainer for isolated Riverpod testing:

```dart
void main() {
  test('should load today status on build', () async {
    final db = SorgvryDatabase(NativeDatabase.memory());
    final localDb = AppLocalDatabase(NativeDatabase.memory());

    final container = ProviderContainer(overrides: [
      healthDbProvider.overrideWithValue(db),
      localDbProvider.overrideWithValue(localDb),
    ]);

    // Wait for async build
    await container.read(medsNotifierProvider.future);

    final state = container.read(medsNotifierProvider).value!;
    expect(state.morningTaken, isFalse);
    expect(state.nightTaken, isFalse);

    container.dispose();
    await db.close();
    await localDb.close();
  });
}
```

### Widget Tests (app)

Test screens with mocked providers:

```dart
void main() {
  testWidgets('should show confirm button when meds not taken', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          medsNotifierProvider.overrideWith(() => FakeMedsNotifier(
            MedsState(morningTaken: false, nightTaken: false),
          )),
        ],
        child: const MaterialApp(home: MedsScreen(session: 'morning')),
      ),
    );

    expect(find.text('JA, EK HET HULLE GEVAT'), findsOneWidget);
  });
}
```

### Backend Route Tests

Use Dart Frog's `RequestContext` testing utilities:

```dart
void main() {
  late SorgvryDatabase db;

  setUp(() {
    db = SorgvryDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('POST /log/meds should return ok', () async {
    final context = _MockRequestContext();
    when(() => context.read<SorgvryDatabase>()).thenReturn(db);
    when(() => context.read<String>()).thenReturn('device-1'); // deviceId
    when(() => context.request).thenReturn(
      Request.post(Uri.parse('/log/meds'), body: jsonEncode({
        'deviceId': 'device-1',
        'date': '2026-04-01',
        'session': 'morning',
        'taken': true,
        'loggedAt': '2026-04-01T07:14:00Z',
      })),
    );

    final response = await route.onRequest(context);
    expect(response.statusCode, equals(200));

    final body = jsonDecode(await response.body());
    expect(body['ok'], isTrue);
  });
}
```

## Mock Patterns

### When to Mock

| Mock | Don't Mock |
|------|-----------|
| HTTP client (for sync tests) | Drift queries (use in-memory DB) |
| Notification plugin | Pure date/time calculations |
| flutter_secure_storage | B12 schedule logic |
| Timer (for sync service) | MAP calculation |

### Mocktail for Dart Frog

```dart
import 'package:mocktail/mocktail.dart';

class _MockRequestContext extends Mock implements RequestContext {}
```

## Test Data

### Fixtures

```dart
// test/fixtures/test_data.dart

const testDeviceId = 'test-device-001';
final testDate = DateTime(2026, 4, 1);

MedLogsCompanion testMedLog({
  String session = 'morning',
  bool taken = true,
}) => MedLogsCompanion(
  deviceId: const Value(testDeviceId),
  date: Value(testDate),
  session: Value(session),
  taken: Value(taken),
  loggedAt: Value(DateTime.now()),
);
```

### Guidelines

- Use `testDeviceId` constant across all tests
- Use fixed dates (not `DateTime.now()`) for reproducibility in assertions
- Use `NativeDatabase.memory()` for all DB tests — fast and isolated
- Clean up: always call `db.close()` in `tearDown`

## Coverage Categories Per Module

| Module | Happy Path | Edge Case | Error |
|--------|-----------|-----------|-------|
| Meds | Confirm morning/night/B12 | Undo within 30 min, undo after 30 min blocked | — |
| BP | Save valid reading, MAP calculation | Boundary MAP values (89/90/110/111) | Invalid input (0, negative, >300) |
| Water | Increment/decrement glasses | 0 glasses, 8 glasses (max) | — |
| Walk | Confirm walk with duration | No walk logged | — |
| Sync | Flush queue, mark synced | Offline (queue grows), retry on failure | Network error, 401 expired token |
| Auth | Register device, store token | Already registered device | Invalid/expired JWT |

## Running Tests

```bash
# All packages
melos run test

# Single package
cd packages/sorgvry_shared && dart test
cd app && flutter test
cd backend && dart test

# Single test file
dart test test/database/tables_test.dart

# With coverage
flutter test --coverage
```
