import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bp_providers.dart';
import 'meds_providers.dart';
import 'walk_providers.dart';
import 'water_providers.dart';

/// Invalidates every notifier whose state is scoped to "today", forcing each to
/// re-run its `build()` and recompute the current day's status from the local
/// database.
///
/// This is the single source of truth for "what resets each day" — any future
/// daily module should add its notifier here so the day-rollover refresh stays
/// complete.
void refreshDailyProviders(WidgetRef ref) {
  ref.invalidate(medsNotifierProvider);
  ref.invalidate(bpNotifierProvider);
  ref.invalidate(waterNotifierProvider);
  ref.invalidate(walkNotifierProvider);
}
