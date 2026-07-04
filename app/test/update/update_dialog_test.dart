import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sorgvry/update/apk_installer.dart';
import 'package:sorgvry/update/app_version_info.dart';
import 'package:sorgvry/update/update_dialog.dart';
import 'package:sorgvry/update/update_provider.dart';

class _FakeInstaller implements ApkInstaller {
  int downloadCalls = 0;
  int cancelCalls = 0;

  @override
  Future<void> downloadAndInstall({
    required String url,
    String? expectedSha256,
    required ProgressCallback onProgress,
    required ErrorCallback onError,
    required void Function() onInstallTriggered,
  }) async {
    downloadCalls++;
    onProgress(0.5);
  }

  @override
  void cancel() => cancelCalls++;
}

UpdateCheckResult _result() => UpdateCheckResult(
  hasUpdate: true,
  isCriticalUpdate: false,
  isCurrentVersionSupported: true,
  currentVersion: '0.8.3+11',
  latestVersion: AppVersionInfo.fromJson({
    'version': '0.8.4',
    'buildNumber': 12,
    'fullVersion': '0.8.4+12',
    'downloadUrl': '/download/sorgvry.apk',
    'fileSizeBytes': 26194515,
    'sha256': 'abc',
  }),
);

Future<void> _pumpDialog(WidgetTester tester, ApkInstaller installer) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [apkInstallerProvider.overrideWithValue(installer)],
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: ElevatedButton(
                onPressed: () => UpdateDialog.show(context, _result()),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders the Afrikaans update prompt', (tester) async {
    await _pumpDialog(tester, _FakeInstaller());

    expect(find.text('Nuwe weergawe beskikbaar'), findsOneWidget);
    expect(find.text('Dateer nou op'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    expect(find.textContaining('0.8.4+12'), findsOneWidget);
  });

  testWidgets('Later dismisses the dialog', (tester) async {
    await _pumpDialog(tester, _FakeInstaller());

    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(find.text('Nuwe weergawe beskikbaar'), findsNothing);
  });

  testWidgets('Dateer nou op starts the download and shows progress', (
    tester,
  ) async {
    final installer = _FakeInstaller();
    await _pumpDialog(tester, installer);

    await tester.tap(find.text('Dateer nou op'));
    await tester.pump();

    expect(installer.downloadCalls, 1);
    expect(find.textContaining('Besig om af te laai'), findsOneWidget);
    expect(find.text('Kanselleer'), findsOneWidget);
  });
}
