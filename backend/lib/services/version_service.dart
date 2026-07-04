import 'dart:convert';
import 'dart:io';

/// Reads app version metadata for the OTA update check.
///
/// The deploy script writes `version.json` and the APK into the download
/// directory, which is mounted read-only into the container at `/app/download`.
/// The manifest is generated at deploy time and already carries the SHA-256 and
/// byte size, so this service is a thin, dependency-free reader.
class VersionService {
  VersionService({String? downloadDir})
    : _downloadDir =
          downloadDir ??
          Platform.environment['DOWNLOAD_DIR'] ??
          '/app/download';

  final String _downloadDir;

  static const _apkName = 'sorgvry.apk';
  static const _manifestName = 'version.json';

  /// Returns the version manifest for the update endpoint.
  ///
  /// The manifest is written at deploy time with `fileSizeBytes`, `sha256`, and
  /// a versioned `downloadUrl` computed from the same APK, so it is internally
  /// consistent and served as-is (no on-disk override, which could pair a new
  /// binary with an old manifest's hash mid-deploy).
  ///
  /// Throws [StateError] when no valid manifest is present (e.g. before the
  /// first APK deploy) so the endpoint can answer 404 and the app can treat it
  /// as "no update available".
  Future<Map<String, dynamic>> getAppVersionInfo() async {
    final manifest = await _readManifest();
    if (manifest == null) {
      throw StateError(
        'No $_manifestName manifest found at $_downloadDir/$_manifestName',
      );
    }

    return {
      'version': manifest['version'],
      'buildNumber': manifest['buildNumber'],
      'fullVersion':
          manifest['fullVersion'] ??
          '${manifest['version']}+${manifest['buildNumber']}',
      'releaseDate':
          manifest['releaseDate'] ?? DateTime.now().toUtc().toIso8601String(),
      'downloadUrl': manifest['downloadUrl'] ?? '/download/$_apkName',
      'fileSizeBytes': manifest['fileSizeBytes'] ?? 0,
      'sha256': manifest['sha256'],
      'isCriticalUpdate': manifest['isCriticalUpdate'] ?? false,
      'minimumSupportedVersion':
          manifest['minimumSupportedVersion'] ?? '0.1.0+1',
    };
  }

  /// Resolves a flat filename inside the download directory for serving.
  ///
  /// Returns `null` when the name is unsafe (path traversal) or the file does
  /// not exist. Only simple filenames are permitted — no directory separators,
  /// no `..`, no dotfiles.
  File? resolveDownloadFile(String name) {
    if (name.isEmpty ||
        name.startsWith('.') ||
        name.contains('/') ||
        name.contains(r'\') ||
        name.contains('..')) {
      return null;
    }
    final file = File('$_downloadDir/$name');
    return file.existsSync() ? file : null;
  }

  Future<Map<String, dynamic>?> _readManifest() async {
    final file = File('$_downloadDir/$_manifestName');
    if (!file.existsSync()) return null;
    try {
      final data = jsonDecode(await file.readAsString());
      if (data is! Map<String, dynamic>) return null;
      if (data['version'] == null || data['buildNumber'] == null) return null;
      return data;
    } catch (_) {
      return null;
    }
  }
}
