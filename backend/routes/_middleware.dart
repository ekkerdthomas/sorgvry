import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:drift/native.dart';
import 'package:sorgvry_backend/middleware/auth.dart';
import 'package:sorgvry_backend/services/minio_service.dart';
import 'package:sorgvry_shared/database/database.dart';

final _db = SorgvryDatabase(
  NativeDatabase(File(Platform.environment['DB_PATH'] ?? 'sorgvry.db')),
);

final _minio = MinioService();

Handler middleware(Handler handler) {
  return handler
      .use(authMiddleware())
      .use(provider<MinioService>((_) => _minio))
      .use(provider<SorgvryDatabase>((_) => _db))
      .use(_cors);
}

Middleware get _cors => (handler) {
  return (context) async {
    const headers = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Authorization, Content-Type',
      'Access-Control-Max-Age': '86400',
    };

    if (context.request.method == HttpMethod.options) {
      return Response(headers: headers);
    }

    final response = await handler(context);
    return response.copyWith(headers: headers);
  };
};
