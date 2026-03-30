import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:sorgvry/services/notification_service.dart';
import 'package:sorgvry/utils/b12.dart';

void main() {
  late tz.Location sast;

  setUpAll(() {
    tz.initializeTimeZones();
    sast = tz.getLocation('Africa/Johannesburg');
  });

  group('nextInstance', () {
    test('returns correct hour and minute in SAST', () {
      final result = NotificationService.nextInstance(7, 0, sast);

      expect(result.hour, 7);
      expect(result.minute, 0);
      expect(result.timeZone.abbreviation, isNotEmpty);
    });

    test('returns a time at the correct hour and minute', () {
      final result = NotificationService.nextInstance(20, 30, sast);

      expect(result.hour, 20);
      expect(result.minute, 30);
    });

    test('result is never in the past', () {
      final result = NotificationService.nextInstance(0, 0, sast);
      final now = tz.TZDateTime.now(sast);

      expect(result.isAfter(now) || result.isAtSameMomentAs(now), isTrue);
    });
  });

  group('nextInstanceOnDate', () {
    test('returns correct date and time', () {
      final date = DateTime(2026, 4, 10);
      final result = NotificationService.nextInstanceOnDate(date, 7, 0, sast);

      expect(result.year, 2026);
      expect(result.month, 4);
      expect(result.day, 10);
      expect(result.hour, 7);
      expect(result.minute, 0);
    });

    test('preserves timezone', () {
      final date = DateTime(2026, 4, 10);
      final result = NotificationService.nextInstanceOnDate(date, 7, 0, sast);

      expect(result.location, sast);
    });
  });

  group('B12 scheduling integration', () {
    test('schedules 07:00 SAST on the next B12 date', () {
      // 2026-03-28 is one day after B12 start (2026-03-27), so next B12
      // is 2026-04-10 (14 days after start).
      final from = DateTime(2026, 3, 28);
      final b12Date = nextB12(from);
      final result = NotificationService.nextInstanceOnDate(
        b12Date,
        7,
        0,
        sast,
      );

      expect(result.year, 2026);
      expect(result.month, 4);
      expect(result.day, 10);
      expect(result.hour, 7);
      expect(result.minute, 0);
    });

    test('schedules today at 07:00 when today is a B12 day', () {
      // B12 start date itself is a B12 day.
      final from = DateTime(2026, 3, 27);
      final b12Date = nextB12(from);
      final result = NotificationService.nextInstanceOnDate(
        b12Date,
        7,
        0,
        sast,
      );

      expect(result.year, 2026);
      expect(result.month, 3);
      expect(result.day, 27);
      expect(result.hour, 7);
    });
  });
}
