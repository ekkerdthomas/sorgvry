import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:drift/native.dart';
import 'package:sorgvry_backend/middleware/auth.dart';
import 'package:sorgvry_shared/database/database.dart';

final _db = SorgvryDatabase(
  NativeDatabase(File(Platform.environment['DB_PATH'] ?? 'sorgvry.db')),
);

Handler middleware(Handler handler) {
  return handler
      .use(authMiddleware())
      .use(provider<SorgvryDatabase>((_) => _db));
}
