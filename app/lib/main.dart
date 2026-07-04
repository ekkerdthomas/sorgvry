import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:sorgvry_shared/database/database.dart';

import 'config.dart';
import 'database/local_database.dart';
import 'database/web_database.dart'
    if (dart.library.io) 'database/native_database.dart';
import 'http/http_client.dart'
    if (dart.library.io) 'http/native_http_client.dart';
import 'providers/daily_refresh.dart';
import 'providers/db_providers.dart';
import 'router.dart';
import 'services/day_refresh_controller.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'theme.dart';
import 'utils/device_id.dart';

SyncService? _syncService;
final notificationService = NotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load Afrikaans date-formatting data so the home-screen date header renders
  // localized weekday/month names. Non-fatal: fall back to the default locale.
  try {
    await initializeDateFormatting('af', null);
  } catch (e) {
    debugPrint('Afrikaans date formatting init failed: $e');
  }

  final healthDb = SorgvryDatabase(openDatabase('sorgvry'));
  final localDb = AppLocalDatabase(openDatabase('sorgvry_local'));

  final deviceId = await getOrCreateDeviceId(localDb);

  try {
    await notificationService.requestPermission();
    await notificationService.reschedule();
  } catch (e) {
    debugPrint('Notification init failed: $e');
  }

  final httpClient = createHttpClient();

  _syncService?.stop();
  _syncService = SyncService(
    healthDb: healthDb,
    localDb: localDb,
    baseUrl: backendUrl,
    deviceId: deviceId,
    client: httpClient,
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

class SorgvryApp extends ConsumerStatefulWidget {
  const SorgvryApp({super.key, this.clock});

  /// Injectable clock for the day-rollover controller (tests only).
  final DateTime Function()? clock;

  @override
  ConsumerState<SorgvryApp> createState() => _SorgvryAppState();
}

class _SorgvryAppState extends ConsumerState<SorgvryApp>
    with WidgetsBindingObserver {
  late final DayRefreshController _dayController;

  @override
  void initState() {
    super.initState();
    _dayController = DayRefreshController(clock: widget.clock);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // On the first resume of a new local day, drop the cached "today" state so
    // every module recomputes against the new date. Same-day resumes are no-ops.
    if (state == AppLifecycleState.resumed && _dayController.hasDayChanged()) {
      refreshDailyProviders(ref);
    }
  }

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
