import 'package:flutter_test/flutter_test.dart';
import 'package:sorgvry/services/day_refresh_controller.dart';

void main() {
  group('DayRefreshController.hasDayChanged', () {
    test('returns false while the local date is unchanged', () {
      var now = DateTime(2026, 7, 4, 8, 45);
      final controller = DayRefreshController(clock: () => now);

      // Same day, later in the morning.
      now = DateTime(2026, 7, 4, 11, 0);
      expect(controller.hasDayChanged(), isFalse);

      // Same day, late at night.
      now = DateTime(2026, 7, 4, 23, 59);
      expect(controller.hasDayChanged(), isFalse);
    });

    test('returns true once when the day rolls over, then re-arms', () {
      var now = DateTime(2026, 7, 4, 22, 0);
      final controller = DayRefreshController(clock: () => now);

      // Cross local midnight.
      now = DateTime(2026, 7, 5, 6, 30);
      expect(controller.hasDayChanged(), isTrue);

      // Still the new day — no further rollover reported.
      now = DateTime(2026, 7, 5, 9, 0);
      expect(controller.hasDayChanged(), isFalse);

      // Next day rolls over again.
      now = DateTime(2026, 7, 6, 7, 0);
      expect(controller.hasDayChanged(), isTrue);
    });

    test('detects a rollover across a month boundary', () {
      var now = DateTime(2026, 7, 31, 20, 0);
      final controller = DayRefreshController(clock: () => now);

      now = DateTime(2026, 8, 1, 8, 0);
      expect(controller.hasDayChanged(), isTrue);
    });

    test('exposes the current active day', () {
      var now = DateTime(2026, 7, 4, 8, 45);
      final controller = DayRefreshController(clock: () => now);

      expect(controller.activeDay, DateTime(2026, 7, 4));

      now = DateTime(2026, 7, 5, 1, 0);
      controller.hasDayChanged();
      expect(controller.activeDay, DateTime(2026, 7, 5));
    });
  });
}
