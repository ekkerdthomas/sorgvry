import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorgvry_shared/database/database.dart';

import 'config.dart';
import 'database/local_database.dart';
import 'database/web_database.dart'
    if (dart.library.io) 'database/native_database.dart';
import 'providers/db_providers.dart';
import 'router.dart';
import 'services/sync_service.dart';
import 'theme.dart';
import 'utils/device_id.dart';

SyncService? _syncService;

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final healthDb = SorgvryDatabase(openDatabase('sorgvry'));
  final localDb = AppLocalDatabase(openDatabase('sorgvry_local'));

  // Start background sync (skip on web — no backend in dev preview)
  if (!kIsWeb) {
    _syncService?.stop();
    _syncService = SyncService(
      healthDb: healthDb,
      localDb: localDb,
      baseUrl: backendUrl,
      deviceId: devDeviceId,
    )..start();
  }

  runApp(
    ProviderScope(
      overrides: [
        healthDbProvider.overrideWithValue(healthDb),
        localDbProvider.overrideWithValue(localDb),
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
