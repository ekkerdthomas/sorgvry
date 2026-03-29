import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:drift/drift.dart';
import 'package:sorgvry_backend/middleware/auth.dart';
import 'package:sorgvry_backend/services/minio_service.dart';
import 'package:sorgvry_shared/sorgvry_shared.dart';

const _validModules = {'bp', 'meds', 'water', 'walk'};

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.post) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final db = context.read<SorgvryDatabase>();
    final minio = context.read<MinioService>();
    final deviceId = context.read<AuthenticatedDeviceId>().value;
    final form = await context.request.formData();

    final fields = form.fields;
    final date = fields['date'];
    final module = fields['module'];
    final session = fields['session'];
    final loggedAt = fields['loggedAt'];

    if (date == null || module == null || loggedAt == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: <String, dynamic>{'error': 'Missing required fields'},
      );
    }

    if (!_validModules.contains(module)) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: <String, dynamic>{'error': 'Invalid module: $module'},
      );
    }

    final file = form.files['file'];
    if (file == null) {
      return Response.json(
        statusCode: HttpStatus.badRequest,
        body: <String, dynamic>{'error': 'Missing file'},
      );
    }

    final bytes = Uint8List.fromList(await file.readAsBytes());

    final effectiveSession = (session == null || session == 'none')
        ? null
        : session;
    final suffix = effectiveSession != null ? '$date-$effectiveSession' : date;
    final objectKey = '$deviceId/$module/$suffix.jpg';

    await minio.uploadObject(objectKey, bytes);

    final entry = MediaAttachmentsCompanion(
      deviceId: Value(deviceId),
      date: Value(DateTime.parse(date)),
      module: Value(module),
      session: Value(session ?? 'none'),
      localPath: const Value(''),
      objectKey: Value(objectKey),
      loggedAt: Value(DateTime.parse(loggedAt)),
      synced: const Value(true),
    );

    await db
        .into(db.mediaAttachments)
        .insert(
          entry,
          onConflict: DoUpdate(
            (_) => entry,
            target: [
              db.mediaAttachments.deviceId,
              db.mediaAttachments.date,
              db.mediaAttachments.module,
              db.mediaAttachments.session,
            ],
          ),
        );

    return Response.json(
      body: <String, dynamic>{'ok': true, 'objectKey': objectKey},
    );
  } on FormatException {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{'error': 'Invalid request format'},
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.internalServerError,
      body: <String, dynamic>{'error': 'Upload failed: $e'},
    );
  }
}
