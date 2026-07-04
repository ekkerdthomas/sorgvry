import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config.dart';
import 'apk_installer.dart';
import 'app_version_info.dart';
import 'update_provider.dart';

/// Afrikaans, large-tap-target update dialog for Amanda. Offers an in-app
/// download that hands off to the Android installer.
class UpdateDialog extends ConsumerStatefulWidget {
  const UpdateDialog({required this.result, super.key});

  final UpdateCheckResult result;

  /// Shows the dialog. [context] must sit under the app Navigator (the checker
  /// passes the router's navigator context). Non-critical updates are
  /// dismissible; critical/unsupported ones are not.
  static Future<void> show(BuildContext context, UpdateCheckResult result) {
    final dismissible =
        !result.isCriticalUpdate && result.isCurrentVersionSupported;
    return showDialog<void>(
      context: context,
      barrierDismissible: dismissible,
      builder: (_) => UpdateDialog(result: result),
    );
  }

  @override
  ConsumerState<UpdateDialog> createState() => _UpdateDialogState();
}

enum _Phase { idle, downloading, error }

class _UpdateDialogState extends ConsumerState<UpdateDialog> {
  _Phase _phase = _Phase.idle;
  double _progress = 0;
  String? _error;

  // Captured in initState: `ref` must not be used in dispose().
  late final ApkInstaller _installer;

  bool get _isCritical =>
      widget.result.isCriticalUpdate ||
      !widget.result.isCurrentVersionSupported;

  bool get _isDownloading => _phase == _Phase.downloading;

  AppVersionInfo get _latest => widget.result.latestVersion!;

  @override
  void initState() {
    super.initState();
    _installer = ref.read(apkInstallerProvider);
  }

  @override
  void dispose() {
    if (_isDownloading) _installer.cancel();
    super.dispose();
  }

  void _startDownload() {
    setState(() {
      _phase = _Phase.downloading;
      _progress = 0;
      _error = null;
    });

    _installer.downloadAndInstall(
      url: _resolveUrl(_latest.downloadUrl),
      expectedSha256: _latest.sha256,
      onProgress: (p) {
        if (mounted) setState(() => _progress = p);
      },
      onError: (message) {
        if (mounted) {
          setState(() {
            _phase = _Phase.error;
            _error = message;
          });
        }
      },
      onInstallTriggered: () {
        // Installer launched — close the dialog and let Android take over.
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  /// The backend advertises a relative `downloadUrl` (`/download/sorgvry.apk`).
  /// [backendUrl] already ends at `/api`, so concatenation yields
  /// `.../api/download/sorgvry.apk`, which nginx proxies to the backend route.
  String _resolveUrl(String downloadUrl) {
    if (downloadUrl.startsWith('http')) return downloadUrl;
    return '$backendUrl$downloadUrl';
  }

  void _cancel() {
    _installer.cancel();
    setState(() {
      _phase = _Phase.idle;
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: !_isCritical && !_isDownloading,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(
              _isCritical ? Icons.warning_amber_rounded : Icons.system_update,
              color: _isCritical ? theme.colorScheme.error : null,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isCritical
                    ? 'Belangrike opdatering'
                    : 'Nuwe weergawe beskikbaar',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _versionLine('Jou weergawe:', widget.result.currentVersion),
              const SizedBox(height: 8),
              _versionLine(
                'Nuutste weergawe:',
                '${_latest.fullVersion}  (${_latest.fileSizeFormatted})',
                emphasise: true,
              ),
              if (_phase == _Phase.downloading) ...[
                const SizedBox(height: 20),
                _downloadProgress(theme),
              ],
              if (_phase == _Phase.error && _error != null) ...[
                const SizedBox(height: 16),
                _errorBox(theme),
              ],
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: _actions(theme),
      ),
    );
  }

  Widget _versionLine(String label, String value, {bool emphasise = false}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: emphasise ? FontWeight.bold : FontWeight.normal,
            color: emphasise ? theme.colorScheme.primary : null,
          ),
        ),
      ],
    );
  }

  Widget _downloadProgress(ThemeData theme) {
    final indeterminate = _progress < 0;
    final label = indeterminate
        ? 'Besig om af te laai… ${(-_progress / (1024 * 1024)).toStringAsFixed(1)} MB'
        : 'Besig om af te laai… ${(_progress * 100).round()}%';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: indeterminate ? null : _progress,
            minHeight: 12,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Moenie die app toemaak nie.',
          style: theme.textTheme.bodyMedium?.copyWith(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _errorBox(ThemeData theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _error!,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: theme.colorScheme.onErrorContainer,
        ),
      ),
    );
  }

  List<Widget> _actions(ThemeData theme) {
    final laterButton = TextButton(
      onPressed: () => Navigator.of(context).pop(),
      style: TextButton.styleFrom(
        minimumSize: const Size(88, 56),
        textStyle: theme.textTheme.titleMedium,
      ),
      child: const Text('Later'),
    );

    ElevatedButton primary(String label) => ElevatedButton(
      onPressed: _startDownload,
      style: ElevatedButton.styleFrom(minimumSize: const Size(160, 64)),
      child: Text(label, style: theme.textTheme.titleMedium),
    );

    switch (_phase) {
      case _Phase.downloading:
        return [
          TextButton(
            onPressed: _cancel,
            style: TextButton.styleFrom(minimumSize: const Size(88, 56)),
            child: const Text('Kanselleer'),
          ),
        ];
      case _Phase.error:
        return [if (!_isCritical) laterButton, primary('Probeer weer')];
      case _Phase.idle:
        return [if (!_isCritical) laterButton, primary('Dateer nou op')];
    }
  }
}
