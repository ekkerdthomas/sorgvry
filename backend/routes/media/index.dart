import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:sorgvry_backend/services/minio_service.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method != HttpMethod.get) {
    return Response(statusCode: HttpStatus.methodNotAllowed);
  }

  final key = context.request.uri.queryParameters['key'];
  if (key == null || key.isEmpty) {
    return Response.json(
      statusCode: HttpStatus.badRequest,
      body: <String, dynamic>{'error': 'Missing key parameter'},
    );
  }

  try {
    final minio = context.read<MinioService>();
    final stream = await minio.getObject(key);

    return Response.stream(
      headers: {
        HttpHeaders.contentTypeHeader: 'image/jpeg',
        if (stream.contentLength != null)
          HttpHeaders.contentLengthHeader: '${stream.contentLength}',
      },
      body: stream,
    );
  } catch (e) {
    return Response.json(
      statusCode: HttpStatus.notFound,
      body: <String, dynamic>{'error': 'Object not found'},
    );
  }
}
