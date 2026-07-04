import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sorgvry_backend/services/version_service.dart';
import 'package:test/test.dart';

import '../../../routes/download/[file].dart' as route;

class _MockRequestContext extends Mock implements RequestContext {}

class _MockRequest extends Mock implements Request {}

class _MockVersionService extends Mock implements VersionService {}

void main() {
  late Directory dir;
  late _MockVersionService service;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('sorgvry_download_test');
    service = _MockVersionService();
  });

  tearDown(() => dir.deleteSync(recursive: true));

  RequestContext buildContext(HttpMethod method) {
    final ctx = _MockRequestContext();
    final request = _MockRequest();
    when(() => request.method).thenReturn(method);
    when(() => ctx.request).thenReturn(request);
    when(() => ctx.read<VersionService>()).thenReturn(service);
    return ctx;
  }

  test('streams an existing APK with no-store + APK content type', () async {
    final apk = File('${dir.path}/sorgvry-0.8.4-12.apk')
      ..writeAsBytesSync(List.filled(2048, 1));
    when(
      () => service.resolveDownloadFile('sorgvry-0.8.4-12.apk'),
    ).thenReturn(apk);

    final response = await route.onRequest(
      buildContext(HttpMethod.get),
      'sorgvry-0.8.4-12.apk',
    );

    expect(response.statusCode, HttpStatus.ok);
    expect(
      response.headers['Content-Type'],
      'application/vnd.android.package-archive',
    );
    expect(response.headers['Content-Length'], '2048');
    expect(response.headers['Cache-Control'], contains('no-store'));

    // Body is the file bytes.
    final bytes = await response.bytes().expand((chunk) => chunk).toList();
    expect(bytes, hasLength(2048));
  });

  test('returns 404 when the file is missing or unsafe', () async {
    when(() => service.resolveDownloadFile(any())).thenReturn(null);

    final response = await route.onRequest(
      buildContext(HttpMethod.get),
      '../secret',
    );

    expect(response.statusCode, HttpStatus.notFound);
  });

  test('rejects non-GET methods', () async {
    final response = await route.onRequest(
      buildContext(HttpMethod.post),
      'sorgvry.apk',
    );
    expect(response.statusCode, HttpStatus.methodNotAllowed);
  });
}
