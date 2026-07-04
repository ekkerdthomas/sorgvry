import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:sorgvry_backend/services/version_service.dart';

/// GET /version — latest APK version metadata for the in-app update check.
///
/// Public (no auth): the app must be able to check even with an expired token,
/// and no sensitive data is exposed. Returns 404 when no manifest exists yet so
/// the app treats it as "no update available".
FutureOr<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  try {
    final info = await context.read<VersionService>().getAppVersionInfo();
    return Response.json(body: info);
  } catch (e) {
    stderr.writeln('[version] $e');
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: {'error': 'No version information available'},
    );
  }
}
