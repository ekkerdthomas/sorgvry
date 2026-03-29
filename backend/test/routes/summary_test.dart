import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sorgvry_shared/sorgvry_shared.dart';
import 'package:test/test.dart';

import '../../routes/summary.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  late SorgvryDatabase db;
  const deviceId = 'test-device-001';

  setUp(() {
    db = SorgvryDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  RequestContext buildContext({String? date}) {
    final ctx = _MockRequestContext();
    final request = _MockRequest();

    final queryParams = <String, String>{};
    if (date != null) queryParams['date'] = date;
    final uri = Uri.http('localhost', '/summary', queryParams);

    when(() => request.method).thenReturn(HttpMethod.get);
    when(() => request.uri).thenReturn(uri);
    when(() => ctx.request).thenReturn(request);
    when(() => ctx.read<SorgvryDatabase>()).thenReturn(db);

    return ctx;
  }

  group('GET /summary', () {
    test('defaults to today (UTC) when no date param given', () async {
      final now = DateTime.now().toUtc();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final ctx = buildContext();
      final response = await route.onRequest(ctx);

      expect(response.statusCode, HttpStatus.ok);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;
      expect(body['date'], todayStr);
    });

    test('returns empty data for a date with no records', () async {
      final ctx = buildContext(date: '2026-04-01');
      final response = await route.onRequest(ctx);

      expect(response.statusCode, HttpStatus.ok);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      expect(body['date'], '2026-04-01');
      expect(body['meds']['morning'], {'taken': false, 'at': null});
      expect(body['meds']['night'], {'taken': false, 'at': null});
      expect(body['meds']['b12']['taken'], false);
      expect(body['bp'], isEmpty);
      expect(body['water'], isEmpty);
      expect(body['walk'], isEmpty);
    });

    test('returns meds data when morning and night are logged', () async {
      final date = DateTime.utc(2026, 4);
      await db
          .into(db.medLogs)
          .insert(
            MedLogsCompanion(
              deviceId: const Value(deviceId),
              date: Value(date),
              session: const Value('morning'),
              taken: const Value(true),
              loggedAt: Value(DateTime.utc(2026, 4, 1, 7, 14)),
              synced: const Value(true),
            ),
          );
      await db
          .into(db.medLogs)
          .insert(
            MedLogsCompanion(
              deviceId: const Value(deviceId),
              date: Value(date),
              session: const Value('night'),
              taken: const Value(true),
              loggedAt: Value(DateTime.utc(2026, 4, 1, 20, 30)),
              synced: const Value(true),
            ),
          );

      final ctx = buildContext(date: '2026-04-01');
      final response = await route.onRequest(ctx);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      expect(body['meds']['morning'], {'taken': true, 'at': '07:14'});
      expect(body['meds']['night'], {'taken': true, 'at': '20:30'});
    });

    test('returns BP reading when logged', () async {
      final date = DateTime.utc(2026, 4);
      await db
          .into(db.bpReadings)
          .insert(
            BpReadingsCompanion(
              deviceId: const Value(deviceId),
              date: Value(date),
              systolic: const Value(148),
              diastolic: const Value(88),
              meanArterialPressure: const Value(108),
              loggedAt: Value(DateTime.utc(2026, 4, 1, 8, 32)),
              synced: const Value(true),
            ),
          );

      final ctx = buildContext(date: '2026-04-01');
      final response = await route.onRequest(ctx);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      expect(body['bp']['systolic'], 148);
      expect(body['bp']['diastolic'], 88);
      expect(body['bp']['map'], 108.0);
      expect(body['bp']['at'], '08:32');
    });

    test('returns water and walk data when logged', () async {
      final date = DateTime.utc(2026, 4);
      await db
          .into(db.waterLogs)
          .insert(
            WaterLogsCompanion(
              deviceId: const Value(deviceId),
              date: Value(date),
              glasses: const Value(5),
              loggedAt: Value(date),
              synced: const Value(true),
            ),
          );
      await db
          .into(db.walkLogs)
          .insert(
            WalkLogsCompanion(
              deviceId: const Value(deviceId),
              date: Value(date),
              walked: const Value(true),
              durationMin: const Value(30),
              loggedAt: Value(date),
              synced: const Value(true),
            ),
          );

      final ctx = buildContext(date: '2026-04-01');
      final response = await route.onRequest(ctx);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      expect(body['water'], {'glasses': 5});
      expect(body['walk'], {'walked': true, 'durationMin': 30});
    });

    test('B12 due is true on injection day (start date)', () async {
      // 27 March 2026 is the B12 start date.
      final ctx = buildContext(date: '2026-03-27');
      final response = await route.onRequest(ctx);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      expect(body['meds']['b12']['due'], true);
    });

    test('B12 due is true 14 days after start', () async {
      // 27 March + 14 = 10 April 2026
      final ctx = buildContext(date: '2026-04-10');
      final response = await route.onRequest(ctx);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      expect(body['meds']['b12']['due'], true);
    });

    test('B12 taken is true when logged on injection day', () async {
      final date = DateTime.utc(2026, 3, 27);
      await db
          .into(db.medLogs)
          .insert(
            MedLogsCompanion(
              deviceId: const Value(deviceId),
              date: Value(date),
              session: const Value('b12'),
              taken: const Value(true),
              loggedAt: Value(DateTime.utc(2026, 3, 27, 9)),
              synced: const Value(true),
            ),
          );

      final ctx = buildContext(date: '2026-03-27');
      final response = await route.onRequest(ctx);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      expect(body['meds']['b12']['due'], true);
      expect(body['meds']['b12']['taken'], true);
    });

    test('B12 due is false on non-injection day', () async {
      final ctx = buildContext(date: '2026-04-01');
      final response = await route.onRequest(ctx);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      expect(body['meds']['b12']['due'], false);
    });

    test('returns 400 for invalid date format', () async {
      final ctx = buildContext(date: 'not-a-date');
      final response = await route.onRequest(ctx);

      expect(response.statusCode, HttpStatus.badRequest);
    });

    test('aggregates data across multiple devices', () async {
      final date = DateTime.utc(2026, 4);

      // Device A logs morning meds early.
      await db
          .into(db.medLogs)
          .insert(
            MedLogsCompanion(
              deviceId: const Value('device-a'),
              date: Value(date),
              session: const Value('morning'),
              taken: const Value(true),
              loggedAt: Value(DateTime.utc(2026, 4, 1, 7, 0)),
              synced: const Value(true),
            ),
          );

      // Device B logs morning meds later (should win — latest).
      await db
          .into(db.medLogs)
          .insert(
            MedLogsCompanion(
              deviceId: const Value('device-b'),
              date: Value(date),
              session: const Value('morning'),
              taken: const Value(true),
              loggedAt: Value(DateTime.utc(2026, 4, 1, 7, 30)),
              synced: const Value(true),
            ),
          );

      // Device A logs water = 4, Device B logs water = 6 (highest wins).
      await db
          .into(db.waterLogs)
          .insert(
            WaterLogsCompanion(
              deviceId: const Value('device-a'),
              date: Value(date),
              glasses: const Value(4),
              loggedAt: Value(date),
              synced: const Value(true),
            ),
          );
      await db
          .into(db.waterLogs)
          .insert(
            WaterLogsCompanion(
              deviceId: const Value('device-b'),
              date: Value(date),
              glasses: const Value(6),
              loggedAt: Value(date),
              synced: const Value(true),
            ),
          );

      final ctx = buildContext(date: '2026-04-01');
      final response = await route.onRequest(ctx);
      final body = jsonDecode(await response.body()) as Map<String, dynamic>;

      // Latest meds entry (device-b at 07:30).
      expect(body['meds']['morning'], {'taken': true, 'at': '07:30'});
      // Highest water count.
      expect(body['water'], {'glasses': 6});
    });

    test('rejects non-GET methods', () async {
      final ctx = _MockRequestContext();
      final request = _MockRequest();
      when(() => request.method).thenReturn(HttpMethod.post);
      when(() => ctx.request).thenReturn(request);

      final response = await route.onRequest(ctx);
      expect(response.statusCode, HttpStatus.methodNotAllowed);
    });
  });
}
