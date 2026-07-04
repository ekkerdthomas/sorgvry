import 'package:flutter_test/flutter_test.dart';
import 'package:sorgvry/update/app_version_info.dart';

void main() {
  group('compareVersions', () {
    test('newer patch is greater', () {
      expect(
        AppVersionInfo.compareVersions('0.8.4+12', '0.8.3+11'),
        greaterThan(0),
      );
    });

    test('older version is lesser', () {
      expect(
        AppVersionInfo.compareVersions('0.8.2+9', '0.8.3+11'),
        lessThan(0),
      );
    });

    test('identical versions are equal', () {
      expect(AppVersionInfo.compareVersions('0.8.3+11', '0.8.3+11'), 0);
    });

    test('build number breaks ties on equal semver', () {
      expect(
        AppVersionInfo.compareVersions('0.8.3+12', '0.8.3+11'),
        greaterThan(0),
      );
    });

    test('semver dominates the build number', () {
      expect(
        AppVersionInfo.compareVersions('1.0.0+1', '0.9.9+99'),
        greaterThan(0),
      );
    });

    test('missing build number sorts before an explicit one', () {
      expect(AppVersionInfo.compareVersions('0.8.3', '0.8.3+1'), lessThan(0));
    });

    test('pre-release suffix is ignored for the numeric compare', () {
      expect(AppVersionInfo.compareVersions('0.8.3-beta+11', '0.8.3+11'), 0);
    });

    test('non-numeric current version sorts as oldest', () {
      // 'unknown' → [0,0,0], so any real release is newer.
      expect(
        AppVersionInfo.compareVersions('0.0.1+1', 'unknown'),
        greaterThan(0),
      );
    });
  });

  group('AppVersionInfo', () {
    final info = AppVersionInfo.fromJson({
      'version': '0.8.4',
      'buildNumber': 12,
      'fullVersion': '0.8.4+12',
      'downloadUrl': '/download/sorgvry.apk',
      'fileSizeBytes': 26194515,
      'sha256': 'abc',
      'minimumSupportedVersion': '0.5.0+1',
    });

    test('isNewerThan the installed version', () {
      expect(info.isNewerThan('0.8.3+11'), isTrue);
      expect(info.isNewerThan('0.8.4+12'), isFalse);
      expect(info.isNewerThan('0.9.0+1'), isFalse);
    });

    test('isVersionSupported enforces the minimum', () {
      expect(info.isVersionSupported('0.4.0+1'), isFalse);
      expect(info.isVersionSupported('0.8.3+11'), isTrue);
    });

    test('no minimum means always supported', () {
      final noMin = AppVersionInfo.fromJson({
        'version': '1.0.0',
        'buildNumber': 1,
        'fullVersion': '1.0.0+1',
        'downloadUrl': '/download/sorgvry.apk',
        'fileSizeBytes': 1,
      });
      expect(noMin.isVersionSupported('0.0.1+1'), isTrue);
    });

    test('fileSizeFormatted renders MB', () {
      expect(info.fileSizeFormatted, '25.0 MB');
    });

    test('fromJson tolerates a numeric buildNumber as double', () {
      final parsed = AppVersionInfo.fromJson({
        'version': '0.8.4',
        'buildNumber': 12.0,
        'downloadUrl': '/download/sorgvry.apk',
        'fileSizeBytes': 10,
      });
      expect(parsed.buildNumber, 12);
      expect(parsed.fullVersion, '0.8.4+12');
    });
  });

  group('UpdateCheckResult factories', () {
    test('noUpdate has no update and keeps the current version', () {
      final r = UpdateCheckResult.noUpdate('0.8.3+11');
      expect(r.hasUpdate, isFalse);
      expect(r.currentVersion, '0.8.3+11');
      expect(r.errorMessage, isNull);
    });

    test('error carries the message and offers no update', () {
      final r = UpdateCheckResult.error('0.8.3+11', 'boom');
      expect(r.hasUpdate, isFalse);
      expect(r.errorMessage, 'boom');
    });
  });
}
