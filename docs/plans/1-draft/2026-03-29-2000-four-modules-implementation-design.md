# Four Modules Implementation Design

**Date:** 2026-03-29
**Status:** Draft
**Scope:** Implement all 4 health modules (meds, BP, water, walk) end-to-end with live home screen card state.

---

## Goal

Replace all stub/placeholder code with working implementations so the app captures real health data, stores it in SQLite, and reflects live status on the home screen cards.

## Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Scope | All 4 modules in one pass | Same pattern repeats — batch is efficient |
| Home cards | Wired to real DB queries | Spec-compliant dynamic state (green/grey/orange/red) |
| BP input | Custom numeric keypad | Large tap targets for elderly user, matches spec exactly |
| Water icons | Simple filled/unfilled circles | Clean, fast to build, spec-compliant behaviour |

## Module Pattern (repeated 4×)

Each module follows: **Repository (DB read/write) → AsyncNotifier (state) → Screen (UI)**

### 1. Repository
- `todayStatus()` — query today's row from SQLite, return typed state
- `save*(...)` — upsert to SQLite with `synced: false`, add to SyncQueue

### 2. AsyncNotifier
- `build()` calls `todayStatus()`
- Action methods call repo, then refresh state

### 3. Screen
- Watches notifier provider
- Renders based on `AsyncValue` (loading/data/error)

---

## Implementation Order

Dependencies flow top-down — each step builds on the previous.

### Step 1: Repositories (all 4)

**Meds** (`meds_repository.dart`):
- `todayStatus()` — query med_logs for today, all sessions. Return `MedsState` with morning/night/b12 booleans + timestamps.
- `confirmMeds(session, taken)` — upsert med_logs row (deviceId + date + session), set `synced: false`.
- `undoMeds(session)` — delete the row if `loggedAt` was within last 30 minutes.
- B12 logic: `isB12Day()` already exists in home_screen.dart — move to a shared util.

**BP** (`bp_repository.dart`):
- `todayStatus()` — query bp_readings for today. Return `BpState`.
- `saveReading(systolic, diastolic)` — calculate MAP = (sys + 2*dia) / 3, upsert, set `synced: false`.

**Water** (`water_repository.dart`):
- `todayStatus()` — query water_logs for today. Return `WaterState`.
- `setGlasses(count)` — upsert with new count, set `synced: false`.

**Walk** (`walk_repository.dart`):
- `todayStatus()` — query walk_logs for today. Return `WalkState`.
- `saveWalk(walked, durationMin)` — upsert, set `synced: false`.

All repos share a helper: `DateTime _today() => DateUtils.dateOnly(DateTime.now())`.

### Step 2: Update notifiers

Wire the existing `AsyncNotifier` classes to call the real repository methods. Add undo support for meds.

### Step 3: Screens

**Meds screen** (spec 5.4):
- Show decorative pill icons for morning (Zetomax, Lansoloc, Clopiwin), night session list, or B12 injection icon.
- Big green button: "JA, EK HET HULLE GEVAT"
- After confirm: green checkmark + "Klaar om [time]", small grey "Maak oop" undo link (30 min window).

**BP screen** (spec 5.5):
- Two display areas: "BOONSTE GETAL" and "ONDERSTE GETAL" showing digits.
- Custom `NumericKeypad` widget: 4×3 grid (1-9, DEL, 0, OK).
- Active field highlighted, tap OK to move to next / submit.
- After both entered: show MAP result card with colour + message.
- "STOOR" button saves and navigates back.

**Water screen** (spec 5.6):
- 8 circles in 2 rows of 4.
- Tap unfilled → fill (blue). Tap filled → unfill.
- Counter: "5 van 8 glase". Progress bar below.
- Auto-saves on every tap.

**Walk screen** (spec 5.7):
- "Het jy vandag gestap?" with JA / NOG NIE buttons.
- If JA: "Hoe lank?" with 15/30/45+ min buttons.
- Selection saves and navigates back to home.

### Step 4: Home screen card wiring

Replace static card data with provider watches:
- Watch `medsNotifierProvider` → card title "Môre Medisyne", subtitle "Klaar" or "Nog nie gedoen", colour green/grey/orange.
- Watch `bpNotifierProvider` → subtitle "108 MAP" or "Nog nie gedoen", colour based on MAP threshold.
- Watch `waterNotifierProvider` → subtitle "5/8 glase", colour green if ≥8, grey otherwise.
- Watch `walkNotifierProvider` → subtitle "30 min" or "Nog nie gedoen", colour green/grey.
- B12 card: watches meds provider, only shows on `isB12Day()`.

**Card colour rules (from spec):**
| State | Colour |
|-------|--------|
| Not done | Grey (`cardPending`) |
| Done | Green (`cardDone`) |
| Past reminder time, not done | Orange (`cardLate`) |
| BP MAP > 110 | Red (`cardAlert`) |

### Step 5: Shared utilities

- Move `isB12Day()` from home_screen.dart to `lib/utils/b12.dart`.
- Add `deviceId` provider (for now, generate UUID on first launch and store in SharedPreferences).

---

## Files Touched

| File | Action |
|------|--------|
| `lib/utils/b12.dart` | New — B12 schedule logic |
| `lib/utils/device_id.dart` | New — device UUID provider |
| `lib/models/meds_state.dart` | Update — add `canUndo` helper |
| `lib/repositories/meds_repository.dart` | Implement — real DB queries |
| `lib/repositories/bp_repository.dart` | Implement — real DB queries |
| `lib/repositories/water_repository.dart` | Implement — real DB queries |
| `lib/repositories/walk_repository.dart` | Implement — real DB queries |
| `lib/providers/meds_providers.dart` | Update — add undo action |
| `lib/screens/meds_screen.dart` | Rewrite — full UI per spec |
| `lib/screens/bp_screen.dart` | Rewrite — custom keypad + MAP display |
| `lib/screens/water_screen.dart` | Rewrite — 8 tappable circles |
| `lib/screens/walk_screen.dart` | Rewrite — JA/NOG NIE + duration |
| `lib/screens/home_screen.dart` | Update — wire to providers, dynamic card state |
| `lib/widgets/numeric_keypad.dart` | New — reusable keypad widget |

---

## Out of Scope

- Sync service (separate design)
- Notifications (separate design)
- Caregiver dashboard
- Device registration / auth flow
- Backend implementation beyond current stubs

---

## Verification

1. `melos run analyze` — 0 issues
2. `flutter test` — existing test passes
3. Web preview: all 4 screens render and respond to taps
4. Home screen cards update dynamically after logging data
5. Data persists in SQLite across app restarts (Android) / session (web)
