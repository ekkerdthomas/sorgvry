import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../utils/b12.dart';

/// Callback for handling notification taps. Must be a top-level function.
@pragma('vm:entry-point')
void onNotificationTap(NotificationResponse response) {
  final payload = response.payload;
  if (payload != null && payload.isNotEmpty) {
    NotificationService.pendingRoute = payload;
  }
}

class NotificationService {
  /// Route to navigate to when a notification is tapped.
  /// Checked and cleared by the router on app launch / resume.
  static String? pendingRoute;

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialised = false;

  Future<void> _init() async {
    if (_initialised) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
    );

    _initialised = true;
  }

  Future<void> reschedule() async {
    if (kIsWeb) return;

    await _init();
    await _plugin.cancelAll();

    final sast = tz.getLocation('Africa/Johannesburg');

    // Fixed daily notifications
    final schedules = <_Schedule>[
      _Schedule(
        id: 1,
        hour: 7,
        minute: 0,
        title: 'Sorgvry',
        body: 'Tyd vir jou oggend pille',
        payload: '/medisyne?session=morning',
      ),
      _Schedule(
        id: 2,
        hour: 8,
        minute: 0,
        title: 'Sorgvry',
        body: 'Tyd om bloeddruk te meet',
        payload: '/bloeddruk',
      ),
      _Schedule(
        id: 3,
        hour: 10,
        minute: 0,
        title: 'Sorgvry',
        body: 'Onthou om water te drink',
        payload: '/water',
      ),
      _Schedule(
        id: 4,
        hour: 13,
        minute: 0,
        title: 'Sorgvry',
        body: 'Onthou om water te drink',
        payload: '/water',
      ),
      _Schedule(
        id: 5,
        hour: 18,
        minute: 0,
        title: 'Sorgvry',
        body: 'Het jy vandag gestap?',
        payload: '/stap',
      ),
      _Schedule(
        id: 6,
        hour: 20,
        minute: 0,
        title: 'Sorgvry',
        body: 'Tyd vir jou aand pille',
        payload: '/medisyne?session=night',
      ),
    ];

    const androidDetails = AndroidNotificationDetails(
      'daily_reminders',
      'Daaglikse Herinneringe',
      channelDescription: 'Daaglikse gesondheid herinneringe',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);

    for (final s in schedules) {
      await _plugin.zonedSchedule(
        s.id,
        s.title,
        s.body,
        _nextInstance(s.hour, s.minute, sast),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: s.payload,
      );
    }

    // B12 notification — only if today is a B12 day
    final now = DateTime.now();
    if (isB12Day(now)) {
      await _plugin.zonedSchedule(
        7,
        'Sorgvry',
        'Jou B12 inspuiting is vandag',
        _nextInstance(7, 0, sast),
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: '/medisyne?session=b12',
      );
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _init();
    await _plugin.cancelAll();
  }

  /// Returns the next occurrence of [hour]:[minute] in [location].
  tz.TZDateTime _nextInstance(int hour, int minute, tz.Location location) {
    final now = tz.TZDateTime.now(location);
    var scheduled = tz.TZDateTime(location, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

class _Schedule {
  final int id;
  final int hour;
  final int minute;
  final String title;
  final String body;
  final String payload;

  const _Schedule({
    required this.id,
    required this.hour,
    required this.minute,
    required this.title,
    required this.body,
    required this.payload,
  });
}
