import 'apk_installer.dart';

/// Web fallback — in-app APK install is Android-only. Never actually reached
/// because [UpdateChecker] only runs the flow on Android, but it keeps the app
/// compiling for the web PWA (which updates itself via the service worker).
ApkInstaller createApkInstallerImpl() => _UnsupportedApkInstaller();

class _UnsupportedApkInstaller implements ApkInstaller {
  @override
  Future<void> downloadAndInstall({
    required String url,
    String? expectedSha256,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    required void Function() onInstallTriggered,
  }) async {
    onError('In-app opdaterings word nie op hierdie platform ondersteun nie.');
  }

  @override
  void cancel() {}
}
