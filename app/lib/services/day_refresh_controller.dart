import 'package:flutter/material.dart' show DateUtils;

/// Detects when the local calendar date has rolled over since the app was last
/// active.
///
/// The module notifiers compute "today" once at build time and cache it for the
/// lifetime of the [ProviderScope]. When the app process survives past local
/// midnight (Android warm-resume from background), that cached state is stale.
/// This controller lets the app decide, on resume, whether the day changed and
/// the daily providers must be refreshed.
///
/// The clock is injectable so the day-change logic is unit-testable without any
/// lifecycle plumbing.
class DayRefreshController {
  DayRefreshController({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    _activeDay = DateUtils.dateOnly(_clock());
  }

  final DateTime Function() _clock;
  late DateTime _activeDay;

  /// The local date this controller currently considers "today".
  DateTime get activeDay => _activeDay;

  /// Returns `true` exactly once per day rollover, then re-arms for the next
  /// day. Returns `false` while still on the same local date.
  bool hasDayChanged() {
    final today = DateUtils.dateOnly(_clock());
    if (today != _activeDay) {
      _activeDay = today;
      return true;
    }
    return false;
  }
}
