import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:sorgvry_backend/middleware/auth.dart';
import 'package:sorgvry_shared/sorgvry_shared.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final db = context.read<SorgvryDatabase>();
  final body = await context.request.json() as Map<String, dynamic>;
  final request = RegisterRequest.fromJson(body);

  final token = generateToken(request.deviceId);

  await db
      .into(db.devices)
      .insertOnConflictUpdate(
        DevicesCompanion(
          id: Value(request.deviceId),
          patientName: Value(request.patientName),
          token: Value(token),
          registeredAt: Value(DateTime.now()),
        ),
      );

  return Response.json(
    body: RegisterResponse(token: token, deviceId: request.deviceId).toJson(),
  );
}
