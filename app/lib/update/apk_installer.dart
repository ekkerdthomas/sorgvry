import 'apk_installer_stub.dart' if (dart.library.io) 'apk_installer_io.dart';

/// 0.0–1.0 for a determinate download; a negative value carries `-bytesReceived`
/// when the server did not send a Content-Length (indeterminate).
typedef ProgressCallback = void Function(double progress);
typedef ErrorCallback = void Function(String message);

/// Downloads the APK and hands it to the Android package installer.
///
/// Abstracted behind a conditional import so the rest of the app compiles on
/// web, where [createApkInstaller] returns a no-op stub.
abstract class ApkInstaller {
  /// Downloads [url] (absolute), verifies [expectedSha256] when provided, then
  /// launches the system installer. Exactly one terminal callback fires:
  /// [onError] on any failure, or [onInstallTriggered] once the installer opens.
  Future<void> downloadAndInstall({
    required String url,
    String? expectedSha256,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    required void Function() onInstallTriggered,
  });

  /// Aborts an in-flight download.
  void cancel();
}

/// Resolves to the Android installer on `dart:io` platforms, a no-op on web.
ApkInstaller createApkInstaller() => createApkInstallerImpl();
