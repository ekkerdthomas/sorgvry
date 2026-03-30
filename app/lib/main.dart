import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorgvry_shared/database/database.dart';

import 'config.dart';
import 'database/local_database.dart';
import 'database/web_database.dart'
    if (dart.library.io) 'database/native_database.dart';
import 'providers/db_providers.dart';
import 'router.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'theme.dart';
import 'utils/device_id.dart';

SyncService? _syncService;
final notificationService = NotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final healthDb = SorgvryDatabase(openDatabase('sorgvry'));
  final localDb = AppLocalDatabase(openDatabase('sorgvry_local'));

  final deviceId = await getOrCreateDeviceId(localDb);

  try {
    await notificationService.requestPermission();
    await notificationService.reschedule();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }

  _syncService?.stop();
  _syncService = SyncService(
    healthDb: healthDb,
    localDb: localDb,
    baseUrl: backendUrl,
    deviceId: deviceId,
  )..start();

  runApp(
    ProviderScope(
      overrides: [
        healthDbProvider.overrideWithValue(healthDb),
        localDbProvider.overrideWithValue(localDb),
        deviceIdProvider.overrideWithValue(deviceId),
        syncStatusProvider.overrideWithValue(_syncService!.statusNotifier),
      ],
      child: const SorgvryApp(),
    ),
  );
}

class SorgvryApp extends StatelessWidget {
  const SorgvryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sorgvry',
      theme: sorgvryTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
