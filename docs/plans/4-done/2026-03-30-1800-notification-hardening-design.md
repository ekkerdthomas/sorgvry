# Notification Hardening — Design

**Date**: 2026-03-30
**Status**: Draft
**Trigger**: `/validate-change` surfaced 8 WARN findings across the notification feature (commits #13–#15)

## Problem

The notification implementation works but has gaps:
- Silently fails on Android 13+ (no runtime permission request)
- Notifications lost on device reboot (boot receiver not registered)
- Unused `SCHEDULE_EXACT_ALARM` permission triggers Play Store review
- App crashes if notification plugin fails on startup
- B12 reminder missed if app not opened on injection day
- Notification tap routes not validated
- No test coverage for scheduling logic

## Changes

### 1. Runtime Permission Request (Android 13+)

Add `requestPermission()` to `NotificationService`, call before `reschedule()` in `main.dart`.

**Files**: `notification_service.dart`, `main.dart`

### 2. Boot Receiver Registration

Add `ScheduledNotificationBootReceiver` to `AndroidManifest.xml` so notifications survive reboots.

**Files**: `AndroidManifest.xml`

### 3. Remove SCHEDULE_EXACT_ALARM

Remove unused permission. We use `inexactAllowWhileIdle` which doesn't require it.

**Files**: `AndroidManifest.xml`

### 4. Try/Catch on Startup

Wrap `requestPermission()` + `reschedule()` in try/catch in `main.dart` so notification failure doesn't crash the app.

**Files**: `main.dart`

### 5. B12 Scheduling Fix

Use `nextB12()` from `b12.dart` to always schedule the next B12 notification, not just on B12 days. Add `_nextInstanceOnDate()` helper for date-specific scheduling.

**Files**: `notification_service.dart`

### 6. Route Validation

Validate `pendingRoute` against a whitelist of known routes before redirecting in `router.dart`.

**Files**: `router.dart`

### 7. Unit Tests

Test `_nextInstance()` edge cases (before/after target time) and B12 conditional scheduling. Extract scheduling logic to be testable.

**Files**: `test/services/notification_service_test.dart` (new)

## Files Touched

| File | Change |
|------|--------|
| `app/lib/services/notification_service.dart` | Permission request, B12 fix, extract testable logic |
| `app/lib/main.dart` | Try/catch, call requestPermission() |
| `app/lib/router.dart` | Route whitelist validation |
| `app/android/app/src/main/AndroidManifest.xml` | Boot receiver, remove SCHEDULE_EXACT_ALARM |
| `app/test/services/notification_service_test.dart` | New test file |

## Decisions

| Decision | Choice | Reason |
|----------|--------|--------|
| Permission UX | Ask on first launch | Simple, one-time, app works without notifications |
| B12 scheduling | Always schedule next B12 date | Uses existing `nextB12()`, no missed reminders |
| Boot receiver | Add plugin's receiver | Notifications survive reboot |
| Tests | Include now | Cover scheduling edge cases |
