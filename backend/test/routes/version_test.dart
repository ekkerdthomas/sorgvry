import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sorgvry_backend/services/version_service.dart';
import 'package:test/test.dart';

import '../../routes/version.dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

class _MockVersionService extends Mock implements VersionService {}

void main() {
  late _MockVersionService service;

  setUp(() => service = _MockVersionService());

  RequestContext buildContext(HttpMethod method) {
    final ctx = _MockRequestContext();
    final request = _MockRequest();
    when(() => request.method).thenReturn(method);
    when(() => ctx.request).thenReturn(request);
    when(() => ctx.read<VersionService>()).thenReturn(service);
    return ctx;
  }

  group('GET /version', () {
    test('returns the manifest as JSON', () async {
      when(service.getAppVersionInfo).thenAnswer(
        (_) async => {
          'version': '0.8.4',
          'buildNumber': 12,
          'fullVersion': '0.8.4+12',
          'downloadUrl': '/download/sorgvry-0.8.4-12.apk',
          'fileSizeBytes': 26194515,
          'sha256': 'abc',
        },
      );

      final response = await route.onRequest(buildContext(HttpMethod.get));

      expect(response.statusCode, HttpStatus.ok);
      final body = await response.json() as Map<String, dynamic>;
      expect(body['fullVersion'], '0.8.4+12');
      expect(body['downloadUrl'], '/download/sorgvry-0.8.4-12.apk');
    });

    test('returns 404 when no manifest is available', () async {
      when(service.getAppVersionInfo).thenThrow(StateError('no manifest'));

      final response = await route.onRequest(buildContext(HttpMethod.get));

      expect(response.statusCode, HttpStatus.notFound);
    });

    test('rejects non-GET methods', () async {
      final response = await route.onRequest(buildContext(HttpMethod.post));
      expect(response.statusCode, HttpStatus.methodNotAllowed);
    });
  });
}
