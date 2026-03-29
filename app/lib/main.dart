import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sorgvry_shared/database/database.dart';

import 'database/local_database.dart';
import 'database/web_database.dart'
    if (dart.library.io) 'database/native_database.dart';
import 'providers/db_providers.dart';
import 'router.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final healthDb = SorgvryDatabase(openDatabase('sorgvry'));
  final localDb = AppLocalDatabase(openDatabase('sorgvry_local'));

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
