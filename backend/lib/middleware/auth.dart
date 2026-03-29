import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Typed wrapper to avoid bare String collision on RequestContext.
class AuthenticatedDeviceId {
  const AuthenticatedDeviceId(this.value);
  final String value;
}

final _jwtSecret = SecretKey(
  Platform.environment['JWT_SECRET'] ?? 'dev-secret-change-me',
);

Middleware authMiddleware() {
  return (handler) {
    return (context) async {
      final path = context.request.uri.path;
      if (path == '/auth/register' || path == '/') {
        return handler(context);
      }

      final auth = context.request.headers['authorization'];
      if (auth == null || !auth.startsWith('Bearer ')) {
        return Response(statusCode: HttpStatus.unauthorized);
      }

      try {
        final jwt = JWT.verify(auth.substring(7), _jwtSecret);
        final payload = jwt.payload as Map<String, dynamic>;
        final deviceId = payload['deviceId'] as String;
        return handler(
          context.provide<AuthenticatedDeviceId>(
            () => AuthenticatedDeviceId(deviceId),
          ),
        );
      } catch (_) {
        return Response(statusCode: HttpStatus.unauthorized);
      }
    };
  };
}

String generateToken(String deviceId) {
  final jwt = JWT({'deviceId': deviceId});
  return jwt.sign(_jwtSecret, expiresIn: const Duration(days: 365));
}
