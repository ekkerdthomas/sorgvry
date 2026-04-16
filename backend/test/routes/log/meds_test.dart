import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:drift/native.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sorgvry_backend/middleware/auth.dart';
import 'package:sorgvry_shared/sorgvry_shared.dart';
import 'package:test/test.dart';

import '../../../routes/log/meds.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

void main() {
  late SorgvryDatabase db;
  const deviceId = 'test-device-001';

  setUp(() {
    db = SorgvryDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  RequestContext buildContext(Map<String, dynamic> body) {
    final ctx = _MockRequestContext();
    final request = _MockRequest();

    when(() => request.method).thenReturn(HttpMethod.post);
    when(request.json).thenAnswer((_) async => body);
    when(() => ctx.request).thenReturn(request);
    when(() => ctx.read<SorgvryDatabase>()).thenReturn(db);
    when(
      () => ctx.read<AuthenticatedDeviceId>(),
    ).thenReturn(const AuthenticatedDeviceId(deviceId));

    return ctx;
  }

  group('POST /log/meds', () {
    test('normalises date to UTC midnight', () async {
      final ctx = buildContext({
        'deviceId': deviceId,
        'date': '2026-03-30',
        'session': 'night',
        'taken': true,
        'loggedAt': '2026-03-30T20:00:00',
      });

      final response = await route.onRequest(ctx);
      expect(response.statusCode, HttpStatus.ok);

      final rows = await db.select(db.medLogs).get();
      expect(rows, hasLength(1));
      // Drift stores as Unix timestamp; convert back to UTC to verify.
      final storedDate = rows.first.date.toUtc();
      expect(storedDate, DateTime.utc(2026, 3, 30));
    });

    test('upserts by deviceId + date + session', () async {
      // Insert first.
      var ctx = buildContext({
        'deviceId': deviceId,
        'date': '2026-03-30',
        'session': 'morning',
        'taken': false,
        'loggedAt': '2026-03-30T07:00:00',
      });
      await route.onRequest(ctx);

      // Upsert same key with updated value.
      ctx = buildContext({
        'deviceId': deviceId,
        'date': '2026-03-30',
        'session': 'morning',
        'taken': true,
        'loggedAt': '2026-03-30T07:30:00',
      });
      await route.onRequest(ctx);

      final rows = await db.select(db.medLogs).get();
      expect(rows, hasLength(1));
      expect(rows.first.taken, isTrue);
    });

    test('rejects non-POST methods', () async {
      final ctx = _MockRequestContext();
      final request = _MockRequest();
      when(() => request.method).thenReturn(HttpMethod.get);
      when(() => ctx.request).thenReturn(request);

      final response = await route.onRequest(ctx);
      expect(response.statusCode, HttpStatus.methodNotAllowed);
    });

    test('returns 400 for invalid JSON', () async {
      final ctx = _MockRequestContext();
      final request = _MockRequest();
      when(() => request.method).thenReturn(HttpMethod.post);
      when(request.json).thenAnswer(
        (_) async => <String, dynamic>{
          'bad': 'data',
        },
      );
      when(() => ctx.request).thenReturn(request);
      when(() => ctx.read<SorgvryDatabase>()).thenReturn(db);
      when(
        () => ctx.read<AuthenticatedDeviceId>(),
      ).thenReturn(const AuthenticatedDeviceId(deviceId));

      final response = await route.onRequest(ctx);
      expect(response.statusCode, HttpStatus.badRequest);
    });
  });
}
