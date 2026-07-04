# Stale Previous-Day State — Day-Rollover Refresh

**Status:** Draft
**Date:** 2026-07-04
**Author:** Ekkerd Thomas (with Claude)
**Platform in scope:** Android APK (Amanda's daily driver)

## Problem

When Amanda opens the app the following day, every module (meds, BP, water, walk)
still shows the **previous day's** captured details — cards read "Klaar"/logged, the
detail screens show the completed view. Because it looks already-done, she captures
no new data for the new day.

## Root Cause

This is a **stale cached-state bug, not a timezone bug.**

- All four modules expose a **non-`autoDispose` `AsyncNotifierProvider`**. Each
  `build()` calls `repository.todayStatus()`, which computes
  `today = DateUtils.dateOnly(DateTime.now())` — correct, in **local** (SAST) time.
  - `app/lib/providers/meds_providers.dart:22`, `bp_providers.dart:22`,
    `water_providers.dart:22`, `walk_providers.dart:22`
  - `app/lib/repositories/meds_repository.dart:22` (and the sibling repos)
- **`build()` runs only once** — the first time each provider is read. Riverpod then
  caches that state for the entire lifetime of the `ProviderScope`. Nothing re-runs it.
- **Nothing in the app detects a day rollover.** `main.dart` registers no lifecycle
  observer; `router.dart` only handles notification routing; `home_screen.dart` reads
  the cached provider values. There is no `WidgetsBindingObserver`, no
  `ref.invalidate`, no midnight timer.
- The `DateTime.now()` re-evaluated in `home_screen.dart:212/223` on rebuild only
  updates the **greeting text and hour-based card colours**, NOT the done-flags — the
  flags come from the stale cached notifier value. This matches the reported symptom
  exactly.
- Sync is **push-only** (`sync_service.dart` uploads unsynced rows, never pulls), so
  local Drift is the sole display source and is internally consistent in local time.
  A true cold start (`main()` re-runs → fresh `ProviderScope` → `build()` recomputes)
  shows the correct empty state — which is why the bug is **intermittent**: it only
  bites when the process survives past local midnight.

### Trigger on Android
Overnight the app is backgrounded (screen lock → `paused`). Reopening the next morning
fires `AppLifecycleState.resumed` **without re-running `main()`**, so the notifiers keep
yesterday's state. A full kill-and-relaunch would fix it — but an elderly daily user
rarely force-kills the app.

## Chosen Approach — Resume + Day-Change Guard

On `AppLifecycleState.resumed`, if the local calendar date has changed since the app was
last active, invalidate the four daily notifiers so each recomputes today's status.
Smallest change that directly targets the exact Android failure; no background timers.

(Rejected: plain `autoDispose` — the home screen keeps the providers alive continuously,
so it would never fire on resume. Rejected: date-keyed provider families — most code,
and still needs a resume trigger to bump the date. A self-rescheduling midnight timer was
considered for the foreground-across-midnight / Web-PWA-tab-left-open cases; deferred as a
documented future option since Amanda is Android-only and backgrounds the app overnight.)

### Components

**1. `SorgvryApp` → `ConsumerStatefulWidget` + `WidgetsBindingObserver`**
(root widget, lives for the whole session, has `ref`):
- `initState`: `WidgetsBinding.instance.addObserver(this)`; construct the day controller.
- `didChangeAppLifecycleState(state)`: on `resumed`, if `hasDayChanged()` →
  `refreshDailyProviders(ref)`.
- `dispose`: `removeObserver(this)`.

**2. `DayRefreshController`** — clock-injectable, pure, unit-testable in isolation:
```dart
class DayRefreshController {
  DayRefreshController({DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    _activeDay = DateUtils.dateOnly(_clock());
  }
  final DateTime Function() _clock;
  late DateTime _activeDay;

  /// Returns true exactly once per day rollover; re-arms for the next day.
  bool hasDayChanged() {
    final today = DateUtils.dateOnly(_clock());
    if (today != _activeDay) { _activeDay = today; return true; }
    return false;
  }
}
```

**3. `refreshDailyProviders(WidgetRef ref)`** — single source of truth for "what resets
each day"; future daily modules get added here so none is forgotten:
```dart
void refreshDailyProviders(WidgetRef ref) {
  ref.invalidate(medsNotifierProvider);
  ref.invalidate(bpNotifierProvider);
  ref.invalidate(waterNotifierProvider);
  ref.invalidate(walkNotifierProvider);
}
```

### Effect
Reopen next day → `resumed` → date changed → 4 providers invalidated → each `build()`
re-runs `todayStatus()` against the new local date → empty state → home cards show
"Nog nie gedoen", detail screens show the capture UI. The home screen watches these
providers, so it rebuilds and the greeting/hour-colours/B12 card refresh too.

**No flicker:** during the brief `AsyncLoading` after invalidation, the home cards already
fall back to `?? false` / `?? 0`, which equals the correct new-day empty state.

**No data loss:** invalidation only re-reads from Drift; any unsynced local writes persist.
On a new day there is nothing entered yet, so nothing to lose.

## Secondary Safeguard — Visible Date Header (in scope)

Add a live date line under the home-screen greeting, e.g. **"Saterdag, 4 Julie 2026"**.
For an elderly user this anchors "this is today's list" and makes any wrong day obvious at
a glance — defence in depth if a refresh ever fails.

- Recomputed on every home rebuild (`DateTime.now()` in `build()`), so always live.
- **Afrikaans locale wiring required.** `intl 0.20.2` bundles Afrikaans data
  (`.../intl/lib/src/data/dates/symbols/af.json`), but the app currently never calls
  `initializeDateFormatting` and sets no locale, so existing `DateFormat` usage renders
  English month names. Needed:
  - Call `initializeDateFormatting('af', null)` once at startup (in `main()`, from
    `package:intl/date_symbol_data_local.dart`) — must complete before the first
    `'af'`-locale format.
  - Format with an explicit locale: `DateFormat('EEEE, d MMMM yyyy', 'af').format(now)`.
  - **Graceful fallback:** guard the localized format so a locale-init failure degrades to
    the default-locale format rather than crashing the home screen.
- Note: this does **not** require adding `flutter_localizations` — that governs Material
  widgets' own strings; plain `intl` date formatting only needs `initializeDateFormatting`
  plus an explicit locale.

## Testing

Per project conventions (test files mirror source; in-memory SQLite for DB tests):

- **Unit — `DayRefreshController`** with a stubbed clock: same day → `false`; advance the
  clock a day → `true`, then `false` again (re-armed). This is the actual new logic and the
  most regression-prone piece.
- **Integration — invalidation re-queries**: seed a row, read the notifier state, mutate the
  DB directly, call `refreshDailyProviders`, assert the state now reflects the DB — proving
  invalidation re-runs `todayStatus()`.
- **Optional (not required for coverage):** a full clock-controlled end-to-end rollover test
  would require threading an injectable `now()` into the repositories. The controller unit
  test (day detection) + the invalidation test (refresh re-queries) together cover the
  mechanism without faking the system clock inside Drift.
- **Manual on-device check:** log a module; background the app; set the device clock forward
  a day (or wait past midnight); resume — cards should reset to "Nog nie gedoen".

## Files Touched

- `app/lib/main.dart` — convert `SorgvryApp` to `ConsumerStatefulWidget` + observer wiring;
  `initializeDateFormatting('af')` at startup.
- `app/lib/services/day_refresh_controller.dart` — **new**, `DayRefreshController`.
- `app/lib/providers/daily_refresh.dart` (or a shared providers file) — **new**,
  `refreshDailyProviders`.
- `app/lib/screens/home_screen.dart` — add the localized date header under the greeting.
- Tests: `app/test/services/day_refresh_controller_test.dart` (**new**), an invalidation
  integration test.

## Out of Scope — Follow-up Issue

The backend normalizes `/log/*` dates to **UTC midnight** (commit `4cb3c9d`). Because sync is
push-only this **cannot** affect Amanda's on-device display. However, the server-rendered
`/summary`, `/bp/history`, and caregiver dashboard views could show an **off-by-one** for
late-night SAST entries if they interpret the UTC-midnight date in local time. This belongs
in a separate issue; it is not part of this fix.

## Success Criteria

- Reopening the app the day after logging shows a clean slate ("Nog nie gedoen") on all four
  modules, without a force-kill.
- The home screen shows today's date in Afrikaans.
- Same-day background/resume does **not** wipe or reload state unnecessarily (the day-change
  guard makes resume a no-op when the date is unchanged).
