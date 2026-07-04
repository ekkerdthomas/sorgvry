import 'dart:async';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:sorgvry_backend/services/version_service.dart';

/// GET /download/<file> — streams a file from the download directory.
///
/// Serves the APK (and any other release artifact) with `no-store` so the CDN
/// never caches a stale binary — this is what keeps the in-app updater from
/// downloading an old APK after a new deploy. Public (no auth): the download is
/// initiated by the Android installer / browser, which sends no bearer token.
FutureOr<Response> onRequest(RequestContext context, String file) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final resolved = context.read<VersionService>().resolveDownloadFile(file);
  if (resolved == null) {
    return Response(statusCode: HttpStatus.notFound);
  }

  final length = resolved.lengthSync();
  final isApk = file.endsWith('.apk');

  return Response.stream(
    body: resolved.openRead(),
    headers: {
      'Content-Type': isApk
          ? 'application/vnd.android.package-archive'
          : 'application/octet-stream',
      'Content-Length': '$length',
      'Content-Disposition': 'attachment; filename="$file"',
      'Cache-Control': 'no-store, no-cache, must-revalidate',
      'Accept-Ranges': 'none',
    },
  );
}
