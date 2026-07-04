import 'dart:convert';
import 'dart:io';

import 'package:sorgvry_backend/services/version_service.dart';
import 'package:test/test.dart';

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('sorgvry_version_test');
  });

  tearDown(() => dir.deleteSync(recursive: true));

  VersionService service() => VersionService(downloadDir: dir.path);

  void writeManifest(Map<String, dynamic> manifest) =>
      File('${dir.path}/version.json').writeAsStringSync(jsonEncode(manifest));

  void writeApk(int bytes) =>
      File('${dir.path}/sorgvry.apk').writeAsBytesSync(List.filled(bytes, 0));

  group('getAppVersionInfo', () {
    test('returns manifest fields with derived defaults', () async {
      writeManifest({
        'version': '0.8.4',
        'buildNumber': 12,
        'sha256': 'abc123',
      });

      final info = await service().getAppVersionInfo();

      expect(info['version'], '0.8.4');
      expect(info['buildNumber'], 12);
      expect(info['fullVersion'], '0.8.4+12');
      expect(info['sha256'], 'abc123');
      expect(info['downloadUrl'], '/download/sorgvry.apk');
      expect(info['isCriticalUpdate'], false);
      expect(info['minimumSupportedVersion'], '0.1.0+1');
    });

    test('serves the manifest fileSizeBytes as-is', () async {
      // The manifest is deploy-generated and self-consistent (size + sha256 +
      // versioned downloadUrl from the same APK), so it is trusted verbatim.
      writeManifest({
        'version': '0.8.4',
        'buildNumber': 12,
        'fileSizeBytes': 26194515,
        'downloadUrl': '/download/sorgvry-0.8.4-12.apk',
      });
      writeApk(2048);

      final info = await service().getAppVersionInfo();

      expect(info['fileSizeBytes'], 26194515);
      expect(info['downloadUrl'], '/download/sorgvry-0.8.4-12.apk');
    });

    test('throws when no manifest is present', () {
      expect(service().getAppVersionInfo(), throwsStateError);
    });

    test('throws on invalid JSON', () {
      File('${dir.path}/version.json').writeAsStringSync('not json');
      expect(service().getAppVersionInfo(), throwsStateError);
    });

    test('throws when required fields are missing', () {
      writeManifest({'version': '0.8.4'}); // no buildNumber
      expect(service().getAppVersionInfo(), throwsStateError);
    });
  });

  group('resolveDownloadFile', () {
    test('resolves an existing flat filename', () {
      writeApk(1024);
      expect(service().resolveDownloadFile('sorgvry.apk'), isNotNull);
    });

    test('returns null when the file does not exist', () {
      expect(service().resolveDownloadFile('sorgvry.apk'), isNull);
    });

    test('rejects path traversal and nested paths', () {
      writeApk(1024);
      expect(service().resolveDownloadFile('../secret'), isNull);
      expect(service().resolveDownloadFile('a/b'), isNull);
      expect(service().resolveDownloadFile(r'a\b'), isNull);
      expect(service().resolveDownloadFile('.env'), isNull);
      expect(service().resolveDownloadFile(''), isNull);
    });
  });
}
