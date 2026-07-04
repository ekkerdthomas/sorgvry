import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../router.dart';
import 'app_version_info.dart';
import 'update_dialog.dart';
import 'update_provider.dart';

/// App-wide wrapper (mounted in `MaterialApp.router`'s builder) that runs the
/// update check and shows [UpdateDialog] when a newer APK is available.
///
/// Android-only: on web the PWA updates itself via the service worker, and the
/// installer flow needs `dart:io`, so the check never runs there.
class UpdateChecker extends ConsumerStatefulWidget {
  const UpdateChecker({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<UpdateChecker> createState() => _UpdateCheckerState();
}

class _UpdateCheckerState extends ConsumerState<UpdateChecker>
    with WidgetsBindingObserver {
  bool _dialogOpen = false;

  /// Version the user tapped "Later" on this session — don't re-nag for it.
  String? _dismissedVersion;

  /// When the last check resolved, to rate-limit resume-driven re-checks.
  DateTime? _lastCheckAt;

  static const _recheckAfter = Duration(minutes: 30);

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  void initState() {
    super.initState();
    if (_supported) WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    if (_supported) WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_supported) return;
    // Re-check on resume when the last check failed / never resolved, or has
    // gone stale. This is what lets a device that was offline at launch (e.g.
    // during a backend redeploy) still eventually see a critical update — the
    // one-shot launch check alone would stay stuck until a full relaunch.
    final result = ref.read(updateCheckProvider).value;
    final failed = result == null || result.errorMessage != null;
    final stale =
        _lastCheckAt == null ||
        DateTime.now().difference(_lastCheckAt!) > _recheckAfter;
    if (failed || stale) ref.invalidate(updateCheckProvider);
  }

  @override
  Widget build(BuildContext context) {
    // Only subscribe on Android — this is what activates the check. On web the
    // provider is never watched, so no network call and no dialog.
    if (_supported) {
      ref.listen<AsyncValue<UpdateCheckResult>>(updateCheckProvider, (_, next) {
        final result = next.value;
        if (result == null) return;
        _lastCheckAt = DateTime.now();
        if (!result.hasUpdate) return;
        // Don't re-nag a version the user already dismissed this session.
        // Critical updates are non-dismissible, so always surface those.
        final version = result.latestVersion?.fullVersion;
        if (!result.isCriticalUpdate && version == _dismissedVersion) return;
        _showDialog(result);
      });
    }
    return widget.child;
  }

  void _showDialog(UpdateCheckResult result) {
    if (_dialogOpen) return;
    _dialogOpen = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Use the router's navigator context so showDialog resolves a Navigator
      // (the builder's own context sits above it).
      final navContext = rootNavigatorKey.currentContext;
      if (navContext == null) {
        _dialogOpen = false;
        return;
      }
      UpdateDialog.show(navContext, result).whenComplete(() {
        _dialogOpen = false;
        // Remember what was dismissed so a resume-driven re-check doesn't
        // immediately re-open the same (non-critical) prompt.
        _dismissedVersion = result.latestVersion?.fullVersion;
      });
    });
  }
}
