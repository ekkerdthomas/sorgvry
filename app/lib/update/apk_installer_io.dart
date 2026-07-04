import 'dart:io';

import 'package:crypto/crypto.dart' as crypto;
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'apk_installer.dart';

ApkInstaller createApkInstallerImpl() => AndroidApkInstaller();

/// Streams the APK to a temp file (with progress), verifies its SHA-256, and
/// launches the Android package installer via `open_filex`.
class AndroidApkInstaller implements ApkInstaller {
  static const _minPlausibleApkBytes = 1024 * 1024; // 1 MB

  http.Client? _client;
  bool _cancelled = false;

  @override
  Future<void> downloadAndInstall({
    required String url,
    String? expectedSha256,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    required void Function() onInstallTriggered,
  }) async {
    _cancelled = false;
    final client = http.Client();
    _client = client;
    File? apkFile;
    var installed = false;

    try {
      final tempDir = await getTemporaryDirectory();
      final apkDir = Directory(p.join(tempDir.path, 'apk_updates'));
      await apkDir.create(recursive: true);
      apkFile = File(p.join(apkDir.path, 'sorgvry-update.apk'));
      if (await apkFile.exists()) await apkFile.delete();

      final response = await client.send(http.Request('GET', Uri.parse(url)));
      if (response.statusCode != 200) {
        onError('Bediener het ${response.statusCode} teruggestuur.');
        return;
      }

      final total = response.contentLength ?? 0;
      final sink = apkFile.openWrite();
      var received = 0;
      try {
        await for (final chunk in response.stream) {
          if (_cancelled) return;
          sink.add(chunk);
          received += chunk.length;
          onProgress(total > 0 ? received / total : -received.toDouble());
        }
      } finally {
        await sink.close();
      }

      if (_cancelled) return;

      // Guard against a truncated/redirect-to-HTML download.
      final size = await apkFile.length();
      if (size < _minPlausibleApkBytes) {
        onError(
          'Aflaai onvolledig (${(size / 1024).toStringAsFixed(0)} KB). '
          'Probeer asseblief weer.',
        );
        return;
      }

      // Fail closed: every served APK must carry a hash to install. The deploy
      // always writes one, so a missing/empty hash means a malformed or
      // tampered manifest — refuse rather than install unverified.
      if (expectedSha256 == null || expectedSha256.isEmpty) {
        onError(
          'Kon nie die aflaai verifieer nie (geen kontrolesom). '
          'Probeer asseblief later weer.',
        );
        return;
      }
      final digest = await crypto.sha256.bind(apkFile.openRead()).first;
      if (digest.toString() != expectedSha256) {
        onError(
          'Die aflaai is beskadig (kontrolesom stem nie ooreen nie). '
          'Probeer asseblief weer.',
        );
        return;
      }

      final result = await OpenFilex.open(
        apkFile.path,
        type: 'application/vnd.android.package-archive',
      );

      if (result.type == ResultType.done) {
        installed = true;
        onInstallTriggered();
      } else if (result.type == ResultType.permissionDenied ||
          result.message.toLowerCase().contains('permission') ||
          result.message.toLowerCase().contains('not allowed')) {
        onError(
          'Jou toestel benodig toestemming om die app te installeer.\n\n'
          'Gaan na: Instellings > Programme > Spesiale toegang > '
          'Installeer onbekende programme, skakel dit aan vir Sorgvry, '
          'en probeer weer.',
        );
      } else {
        onError('Kon nie die installeerder oopmaak nie: ${result.message}');
      }
    } catch (e) {
      if (!_cancelled) onError('Aflaai het misluk: $e');
    } finally {
      // Remove the partial/unused download on any non-install exit (cancel,
      // network error, integrity failure). The file is kept only once it has
      // been handed to the installer.
      if (!installed && apkFile != null) await _safeDelete(apkFile);
      client.close();
      _client = null;
    }
  }

  Future<void> _safeDelete(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  @override
  void cancel() {
    _cancelled = true;
    _client?.close();
  }
}
