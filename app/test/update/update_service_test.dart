import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sorgvry/update/update_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Sorgvry',
      packageName: 'ai.phygital.sorgvry',
      version: '0.8.3',
      buildNumber: '11',
      buildSignature: '',
    );
  });

  UpdateService serviceWith(MockClient client) =>
      UpdateService(client: client, baseUrl: 'https://sorgvry.example/api');

  test('hits /version on the configured base URL', () async {
    late Uri requested;
    final client = MockClient((req) async {
      requested = req.url;
      return http.Response('{}', 404);
    });
    await serviceWith(client).check();
    expect(requested.toString(), 'https://sorgvry.example/api/version');
  });

  test(
    'reports an update when the backend advertises a newer version',
    () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'version': '0.8.4',
            'buildNumber': 12,
            'fullVersion': '0.8.4+12',
            'downloadUrl': '/download/sorgvry.apk',
            'fileSizeBytes': 26194515,
            'sha256': 'abc',
          }),
          200,
        );
      });

      final result = await serviceWith(client).check();

      expect(result.currentVersion, '0.8.3+11');
      expect(result.hasUpdate, isTrue);
      expect(result.latestVersion?.fullVersion, '0.8.4+12');
      expect(result.errorMessage, isNull);
    },
  );

  test('no update when the backend reports the installed version', () async {
    final client = MockClient((_) async {
      return http.Response(
        jsonEncode({
          'version': '0.8.3',
          'buildNumber': 11,
          'fullVersion': '0.8.3+11',
          'downloadUrl': '/download/sorgvry.apk',
          'fileSizeBytes': 1,
        }),
        200,
      );
    });

    final result = await serviceWith(client).check();

    expect(result.hasUpdate, isFalse);
    expect(result.errorMessage, isNull);
  });

  test('404 (no manifest yet) folds into no-update, not an error', () async {
    final client = MockClient((_) async => http.Response('{}', 404));
    final result = await serviceWith(client).check();
    expect(result.hasUpdate, isFalse);
    expect(result.errorMessage, isNull);
  });

  test('network failure yields an error result', () async {
    final client = MockClient((_) async => throw Exception('offline'));
    final result = await serviceWith(client).check();
    expect(result.hasUpdate, isFalse);
    expect(result.errorMessage, isNotNull);
  });
}
