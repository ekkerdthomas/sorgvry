import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:sorgvry_backend/middleware/auth.dart';
import 'package:sorgvry_shared/sorgvry_shared.dart';

/// B12 injection start date per spec (section 10).
final _b12StartDate = DateTime.utc(2026, 3, 27);

/// Returns true if [date] falls on a B12 injection day (every 14 days).
bool _isB12Day(DateTime date) {
  final diff = date.difference(_b12StartDate).inDays;
  return diff >= 0 && diff % 14 == 0;
}

/// Formats a [DateTime] as "HH:mm" (24-hour, UTC).
String _timeOf(DateTime dt) {
  final u = dt.toUtc();
  return '${u.hour.toString().padLeft(2, '0')}:${u.minute.toString().padLeft(2, '0')}';
}

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<SorgvryDatabase>();
    final deviceId = context.read<AuthenticatedDeviceId>().value;

    // Parse date query parameter, default to today (midnight-normalised).
    final dateParam = context.request.uri.queryParameters['date'];
    final date = dateParam != null
        ? DateTime.parse(dateParam)
        : DateTime.now().toUtc();
    final normalised = DateTime.utc(date.year, date.month, date.day);

    // --- Meds ---
    final medRows =
        await (db.select(db.medLogs)..where(
              (t) => t.deviceId.equals(deviceId) & t.date.equals(normalised),
            ))
            .get();

    final medsMap = <String, Map<String, dynamic>>{};
    for (final session in ['morning', 'night']) {
      final row = medRows.where((r) => r.session == session).firstOrNull;
      medsMap[session] = row != null
          ? {'taken': row.taken, 'at': row.taken ? _timeOf(row.loggedAt) : null}
          : {'taken': false, 'at': null};
    }
    // B12: include due flag, plus taken if logged.
    final b12Row = medRows.where((r) => r.session == 'b12').firstOrNull;
    medsMap['b12'] = {
      'due': _isB12Day(normalised),
      'taken': b12Row?.taken ?? false,
    };

    // --- Blood pressure ---
    final bpRow =
        await (db.select(db.bpReadings)..where(
              (t) => t.deviceId.equals(deviceId) & t.date.equals(normalised),
            ))
            .getSingleOrNull();

    final bpMap = bpRow != null
        ? <String, dynamic>{
            'systolic': bpRow.systolic,
            'diastolic': bpRow.diastolic,
            'map': bpRow.meanArterialPressure,
            'at': _timeOf(bpRow.loggedAt),
          }
        : <String, dynamic>{};

    // --- Water ---
    final waterRow =
        await (db.select(db.waterLogs)..where(
              (t) => t.deviceId.equals(deviceId) & t.date.equals(normalised),
            ))
            .getSingleOrNull();

    final waterMap = waterRow != null
        ? <String, dynamic>{'glasses': waterRow.glasses}
        : <String, dynamic>{};

    // --- Walk ---
    final walkRow =
        await (db.select(db.walkLogs)..where(
              (t) => t.deviceId.equals(deviceId) & t.date.equals(normalised),
            ))
            .getSingleOrNull();

    final walkMap = walkRow != null
        ? <String, dynamic>{
            'walked': walkRow.walked,
            'durationMin': walkRow.durationMin,
          }
        : <String, dynamic>{};

    return Response.json(
      body: <String, dynamic>{
        'date':
            '${normalised.year}-${normalised.month.toString().padLeft(2, '0')}-${normalised.day.toString().padLeft(2, '0')}',
        'meds': medsMap,
        'bp': bpMap,
        'water': waterMap,
        'walk': walkMap,
      },
    );
  } on FormatException {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{'error': 'Invalid date format'},
    );
  } catch (_) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{'error': 'Internal server error'},
    );
  }
}
