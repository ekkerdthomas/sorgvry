import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:sorgvry_backend/middleware/auth.dart';
import 'package:sorgvry_shared/sorgvry_shared.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<SorgvryDatabase>();
    final deviceId = context.read<AuthenticatedDeviceId>().value;
    final body = await context.request.json() as Map<String, dynamic>;
    final request = MedLogRequest.fromJson(body);

    final entry = MedLogsCompanion(
      deviceId: Value(deviceId),
      date: Value(DateTime.parse(request.date)),
      session: Value(request.session),
      taken: Value(request.taken),
      loggedAt: Value(DateTime.parse(request.loggedAt)),
      synced: const Value(true),
    );

    await db
        .into(db.medLogs)
        .insert(
          entry,
          onConflict: DoUpdate(
            (_) => entry,
            target: [
              db.medLogs.deviceId,
              db.medLogs.date,
              db.medLogs.session,
            ],
          ),
        );

    return Response.json(body: const OkResponse(ok: true).toJson());
  } on FormatException {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{'error': 'Invalid request format'},
    );
  } catch (_) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{'error': 'Bad request'},
    );
  }
}
