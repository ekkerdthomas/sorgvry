import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'apk_installer.dart';
import 'app_version_info.dart';
import 'update_service.dart';

final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());

/// The Android APK installer (no-op stub on web).
final apkInstallerProvider = Provider<ApkInstaller>(
  (ref) => createApkInstaller(),
);

/// Runs the update check on first watch and exposes a manual re-check.
///
/// [UpdateService.check] never throws, so the async state resolves to data
/// holding an [UpdateCheckResult] (which itself may carry an `errorMessage`).
final updateCheckProvider =
    AsyncNotifierProvider<UpdateCheckNotifier, UpdateCheckResult>(
      UpdateCheckNotifier.new,
    );

class UpdateCheckNotifier extends AsyncNotifier<UpdateCheckResult> {
  @override
  Future<UpdateCheckResult> build() {
    return ref.watch(updateServiceProvider).check();
  }

  Future<void> recheck() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(updateServiceProvider).check(),
    );
  }
}
