/// Latest app version advertised by the backend `/version` endpoint, plus the
/// result of comparing it against the installed version.
///
/// Pure Dart (no `dart:io`) so it compiles on web as well as Android.
library;

class AppVersionInfo {
  const AppVersionInfo({
    required this.version,
    required this.buildNumber,
    required this.fullVersion,
    required this.releaseDate,
    required this.downloadUrl,
    required this.fileSizeBytes,
    this.sha256,
    this.isCriticalUpdate = false,
    this.minimumSupportedVersion,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    final version = json['version'] as String;
    final buildNumber = (json['buildNumber'] as num).toInt();
    return AppVersionInfo(
      version: version,
      buildNumber: buildNumber,
      fullVersion: json['fullVersion'] as String? ?? '$version+$buildNumber',
      releaseDate:
          DateTime.tryParse(json['releaseDate'] as String? ?? '') ??
          DateTime.now(),
      downloadUrl: json['downloadUrl'] as String? ?? '/download/sorgvry.apk',
      fileSizeBytes: (json['fileSizeBytes'] as num?)?.toInt() ?? 0,
      sha256: json['sha256'] as String?,
      isCriticalUpdate: json['isCriticalUpdate'] as bool? ?? false,
      minimumSupportedVersion: json['minimumSupportedVersion'] as String?,
    );
  }

  final String version;
  final int buildNumber;
  final String fullVersion;
  final DateTime releaseDate;
  final String downloadUrl;
  final int fileSizeBytes;
  final String? sha256;
  final bool isCriticalUpdate;
  final String? minimumSupportedVersion;

  /// Human-readable size, e.g. "26.2 MB". Afrikaans uses the same MB/KB units.
  String get fileSizeFormatted {
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool isNewerThan(String otherFullVersion) =>
      compareVersions(fullVersion, otherFullVersion) > 0;

  bool isVersionSupported(String currentFullVersion) {
    final min = minimumSupportedVersion;
    if (min == null) return true;
    return compareVersions(currentFullVersion, min) >= 0;
  }

  /// Compares two `x.y.z+b` version strings.
  ///
  /// Returns >0 when [a] is newer, <0 when older, 0 when equal. A pre-release
  /// suffix (`-beta`) is ignored for the numeric comparison; the `+build`
  /// number is the final tie-breaker.
  static int compareVersions(String a, String b) {
    final aParts = a.split('+');
    final bParts = b.split('+');

    final aNums = _numericParts(aParts.first);
    final bNums = _numericParts(bParts.first);

    for (var i = 0; i < 3; i++) {
      final av = i < aNums.length ? aNums[i] : 0;
      final bv = i < bNums.length ? bNums[i] : 0;
      if (av != bv) return av > bv ? 1 : -1;
    }

    final aBuild = aParts.length > 1 ? (int.tryParse(aParts[1]) ?? 0) : 0;
    final bBuild = bParts.length > 1 ? (int.tryParse(bParts[1]) ?? 0) : 0;
    return aBuild.compareTo(bBuild);
  }

  static List<int> _numericParts(String version) => version
      .split('-')
      .first
      .split('.')
      .map((s) => int.tryParse(s) ?? 0)
      .toList();
}

/// Outcome of an update check.
class UpdateCheckResult {
  const UpdateCheckResult({
    required this.hasUpdate,
    required this.isCriticalUpdate,
    required this.isCurrentVersionSupported,
    required this.currentVersion,
    this.latestVersion,
    this.errorMessage,
  });

  factory UpdateCheckResult.noUpdate(String currentVersion) =>
      UpdateCheckResult(
        hasUpdate: false,
        isCriticalUpdate: false,
        isCurrentVersionSupported: true,
        currentVersion: currentVersion,
      );

  factory UpdateCheckResult.error(String currentVersion, String error) =>
      UpdateCheckResult(
        hasUpdate: false,
        isCriticalUpdate: false,
        isCurrentVersionSupported: true,
        currentVersion: currentVersion,
        errorMessage: error,
      );

  final bool hasUpdate;
  final bool isCriticalUpdate;
  final bool isCurrentVersionSupported;
  final String currentVersion;
  final AppVersionInfo? latestVersion;
  final String? errorMessage;
}
