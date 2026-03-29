_Last updated: 2026-03-29_
Status: active

# Sorgvry — Full Technical Specification

> Afrikaans health companion app for Amanda Thomas.
> Captures daily medication, blood pressure, water intake, and exercise.
> Offline-first Flutter app + Dart Frog backend on Pi.

---

## 1. Project Overview

| Item | Detail |
|---|---|
| App name | **Sorgvry** |
| Platform | Android (Flutter) |
| Language | Afrikaans (UI), Dart (code) |
| Backend | Dart Frog |
| Database | SQLite via Drift (shared schema) |
| Hosting | Raspberry Pi (local network + VPN access) |
| Sync | Offline-first — local queue, push to backend when online |
| Phase 1 focus | Data capture only (no viz/dashboard yet) |

---

## 2. Mono-repo Structure

```
sorgvry/
├── packages/
│   └── sorgvry_shared/        # Drift schema, models, API contracts
│       ├── lib/
│       │   ├── database/
│       │   │   ├── tables.dart
│       │   │   └── database.dart
│       │   ├── models/
│       │   │   └── *.dart
│       │   └── api/
│       │       └── contracts.dart
│       └── pubspec.yaml
├── app/                       # Flutter patient app
│   ├── lib/
│   └── pubspec.yaml
├── backend/                   # Dart Frog API
│   ├── routes/
│   ├── middleware/
│   └── pubspec.yaml
└── melos.yaml                 # Mono-repo tooling
```

Use **Melos** for mono-repo management (bootstrap, run, test across packages).

---

## 3. Database Schema (Drift)

Defined once in `sorgvry_shared`, used by both app and backend.

### 3.1 `med_logs`
```dart
class MedLogs extends Table {
  IntColumn get id        => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  DateTimeColumn get date => dateTime()();         // date only, normalised to midnight
  TextColumn get session  => text()();             // 'morning' | 'night' | 'b12'
  BoolColumn get taken    => boolean()();
  DateTimeColumn get loggedAt => dateTime()();
  BoolColumn get synced   => boolean().withDefault(const Constant(false))();
}
```

### 3.2 `bp_readings`
```dart
class BpReadings extends Table {
  IntColumn get id           => integer().autoIncrement()();
  TextColumn get deviceId    => text()();
  DateTimeColumn get date    => dateTime()();
  IntColumn get systolic     => integer()();
  IntColumn get diastolic    => integer()();
  RealColumn get map         => real()();          // calculated on device: (1/3 * sys) + (2/3 * dia)
  DateTimeColumn get loggedAt => dateTime()();
  BoolColumn get synced      => boolean().withDefault(const Constant(false))();
}
```

### 3.3 `water_logs`
```dart
class WaterLogs extends Table {
  IntColumn get id          => integer().autoIncrement()();
  TextColumn get deviceId   => text()();
  DateTimeColumn get date   => dateTime()();
  IntColumn get glasses     => integer()();        // 0–8, updated throughout day
  DateTimeColumn get loggedAt => dateTime()();
  BoolColumn get synced     => boolean().withDefault(const Constant(false))();
}
```

### 3.4 `walk_logs`
```dart
class WalkLogs extends Table {
  IntColumn get id           => integer().autoIncrement()();
  TextColumn get deviceId    => text()();
  DateTimeColumn get date    => dateTime()();
  BoolColumn get walked      => boolean()();
  IntColumn get durationMin  => integer().nullable()(); // 15 | 30 | 45
  DateTimeColumn get loggedAt => dateTime()();
  BoolColumn get synced      => boolean().withDefault(const Constant(false))();
}
```

### 3.5 `devices`
```dart
class Devices extends Table {
  TextColumn get id          => text()();           // UUID, primary key
  TextColumn get patientName => text()();
  TextColumn get token       => text()();           // JWT
  DateTimeColumn get registeredAt => dateTime()();
  BoolColumn get active      => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
```

### 3.6 `sync_queue` (app-only, not on backend)
```dart
class SyncQueue extends Table {
  IntColumn get id        => integer().autoIncrement()();
  TextColumn get endpoint => text()();             // e.g. '/log/bp'
  TextColumn get payload  => text()();             // JSON string
  DateTimeColumn get queuedAt => dateTime()();
  IntColumn get attempts  => integer().withDefault(const Constant(0))();
}
```

---

## 4. API Contract

Base URL: `http://sorgvry.local:8080` (Pi local) or via Tailscale/VPN remotely.

All requests require header: `Authorization: Bearer <token>`

### 4.1 Device Registration
```
POST /auth/register

Request:
{
  "deviceId": "uuid-v4",
  "patientName": "Amanda Thomas"
}

Response 200:
{
  "token": "jwt-string",
  "deviceId": "uuid-v4"
}
```
Called once on first app launch. Token stored in `flutter_secure_storage`.

---

### 4.2 Medication Log
```
POST /log/meds

Request:
{
  "deviceId": "string",
  "date": "2026-04-01",
  "session": "morning" | "night" | "b12",
  "taken": true,
  "loggedAt": "2026-04-01T07:14:00Z"
}

Response 200:
{ "ok": true }
```

---

### 4.3 Blood Pressure
```
POST /log/bp

Request:
{
  "deviceId": "string",
  "date": "2026-04-01",
  "systolic": 148,
  "diastolic": 88,
  "map": 108.0,
  "loggedAt": "2026-04-01T08:32:00Z"
}

Response 200:
{ "ok": true }
```

---

### 4.4 Water
```
POST /log/water

Request:
{
  "deviceId": "string",
  "date": "2026-04-01",
  "glasses": 5,
  "loggedAt": "2026-04-01T14:10:00Z"
}

Response 200:
{ "ok": true }
```
Replace the day's water log (upsert by deviceId + date).

---

### 4.5 Walk
```
POST /log/walk

Request:
{
  "deviceId": "string",
  "date": "2026-04-01",
  "walked": true,
  "durationMin": 30,
  "loggedAt": "2026-04-01T09:45:00Z"
}

Response 200:
{ "ok": true }
```

---

### 4.6 Daily Summary (caregiver read)
```
GET /summary?date=2026-04-01&deviceId=xxx

Response 200:
{
  "date": "2026-04-01",
  "meds": {
    "morning": { "taken": true, "at": "07:14" },
    "night":   { "taken": false, "at": null },
    "b12":     { "due": false }
  },
  "bp": {
    "systolic": 148,
    "diastolic": 88,
    "map": 108.0,
    "at": "08:32"
  },
  "water": { "glasses": 5 },
  "walk":  { "walked": true, "durationMin": 30 }
}
```

---

### 4.7 BP History
```
GET /bp/history?deviceId=xxx&from=2026-04-01&to=2026-06-30

Response 200:
{
  "readings": [
    { "date": "2026-04-01", "systolic": 148, "diastolic": 88, "map": 108.0 },
    ...
  ]
}
```

---

### 4.8 Export
```
GET /export?deviceId=xxx&from=2026-04-01&to=2026-06-30&format=csv

Response 200: text/csv
date,session,taken,systolic,diastolic,map,glasses,walked,duration_min
...
```

---

## 5. Flutter App

### 5.1 State Management
**Riverpod** — clean, testable, no boilerplate. One provider per module.

### 5.2 Navigation
**Single stack, no drawer, no bottom nav.** Go router for named routes.

```
/           → HomeScreen
/medisyne   → MedsScreen (session passed as param: morning|night|b12)
/bloeddruk  → BpScreen
/water      → WaterScreen
/stap       → WalkScreen
/versorger  → CaregiverUnlockScreen (PIN entry)
/versorger/dashboard → CaregiverDashboard
```

---

### 5.3 Home Screen

```
AppBar: "Sorgvry" (no back button, no menu)
Body:
  Greeting text (time-based):
    06:00–12:00 → "Goeie môre, Amanda"
    12:00–18:00 → "Goeie middag, Amanda"
    18:00+      → "Goeie naand, Amanda"

  4 large cards (GridView 2x2, each ~40% screen height):

  ┌──────────────┬──────────────┐
  │  Môre        │  Bloeddruk   │
  │  Medisyne    │              │
  │              │              │
  │  [icon]      │  [icon]      │
  │  ✓ Klaar     │  108 MAP     │
  └──────────────┴──────────────┘
  ┌──────────────┬──────────────┐
  │  Water       │  Stap        │
  │              │              │
  │  [icon]      │  [icon]      │
  │  5/8 glase   │  30 min      │
  └──────────────┴──────────────┘

  B12 card: only visible on injection days (floating full-width below grid)

Card states:
  Grey   → nog nie gedoen
  Green  → klaar
  Orange → laat (past reminder time, not done)
  Red    → BP MAP > 110
```

Tap anywhere on card → navigate to module.

Hidden gesture: tap app title 5× → PIN prompt → caregiver mode.

---

### 5.4 Meds Screen

```
Title: "Môre Medisyne" / "Aand Medisyne" / "B12 Inspuiting"

Body (morning example):
  Visual pill icons for each med (not interactive, just decorative)
  Zetomax · Lansoloc · Clopiwin

  Big green button (full width, 80px height):
  "JA, EK HET HULLE GEVAT"

  If already confirmed:
  Green checkmark + "Klaar om [time]"
  Small grey "Maak oop" link to undo (last 30 min only)
```

B12 screen shows injection icon + date + confirm button.

---

### 5.5 BP Screen

```
Title: "Bloeddruk"

Two large input areas (not TextField — custom numeric pad):

  BOONSTE GETAL    [ 1 4 8 ]
  ONDERSTE GETAL   [ 8 8  ]

Custom keypad (large buttons, no keyboard popup):
  [ 1 ][ 2 ][ 3 ]
  [ 4 ][ 5 ][ 6 ]
  [ 7 ][ 8 ][ 9 ]
  [DEL][ 0 ][OK]

After both fields filled, show result immediately:

  ┌──────────────────────────┐
  │  MAP: 108                │
  │  ● Hou dop               │   ← orange
  │  Doelwit is onder 110    │
  └──────────────────────────┘

  [STOOR]  (big green button)

MAP thresholds:
  < 90     → green  → "Goed so!"
  90–110   → orange → "Hou dop"
  > 110    → red    → "Sê vir jou versorger"
```

---

### 5.6 Water Screen

```
Title: "Water"

8 large glass icons in a row (or 2 rows of 4 on small screens)
Unfilled = grey outline
Filled = blue

Tap any unfilled glass → fills it + updates count
Tap filled glass → unfills (undo)

Counter text: "5 van 8 glase"

Progress bar below glasses.

Auto-saves on every tap (no save button needed).
```

---

### 5.7 Walk Screen

```
Title: "Stap"

"Het jy vandag gestap?"

  [JA]     [NOG NIE]    ← big buttons, full width

If JA:
  "Hoe lank?"

  [15 min]  [30 min]  [45 min+]   ← 3 equal buttons

Selection highlights in green, auto-saves, navigates back to home.

If NOG NIE: saves walked=false, navigates back.
```

---

## 6. Sync Strategy

**Offline-first.** Every write goes to local SQLite first, then queues for backend sync.

```
User action
    │
    ▼
Write to local SQLite (immediate)
    │
    ▼
Add to sync_queue table
    │
    ▼
SyncService (background isolate, runs every 60s)
    │
    ├── Online? → flush queue → POST to backend → mark synced
    └── Offline? → keep in queue, retry next cycle
```

Conflict resolution: last-write-wins by `loggedAt` timestamp. Server is source of truth for history; device is source of truth for today.

---

## 7. Notifications

Use `flutter_local_notifications` + `android_alarm_manager_plus`.

```dart
// Scheduled notifications (configurable times, defaults below)
07:00  → MorningMedsReminder   "Tyd vir jou môre pille"
09:00  → BpReminder            "Tyd om bloeddruk te meet"
12:00  → WaterReminder         "Onthou om water te drink"  (if glasses < 3)
15:00  → WalkReminder          "Het jy vandag gestap?"     (if not logged)
18:00  → WaterReminder         "Onthou om water te drink"  (if glasses < 6)
20:00  → NightMedsReminder     "Tyd vir jou aand pille"

// B12 injection days (calculated from start date: 25 Mar 2026, every 14 days)
07:00  → B12Reminder           "Jou B12 inspuiting is vandag"
```

Tapping any notification opens directly to the relevant screen.

---

## 8. Caregiver Mode

Unlocked by: tap app title 5× → enter 4-digit PIN.

PIN stored in `flutter_secure_storage`, set on first unlock.

```
Caregiver dashboard screens (Phase 1):

TODAY tab:
  Checklist view of today's status
  Same data as home, but with timestamps

THIS WEEK tab:
  7-day grid
  Each cell: coloured dot per module (green/orange/red/grey)

BP tab:
  Chronological list of all readings
  Date | Systolic | Diastolic | MAP | colour indicator

SETTINGS tab:
  Reminder times (editable)
  Patient name
  Change PIN
  Export data (opens Android share sheet with CSV)
  B12 start date (for injection reminders)
  Backend URL
```

---

## 9. UI Design Tokens

```dart
// Colours
primary:        #C0392B  (red — brand)
onPrimary:      #FFFFFF
cardDone:       #27AE60  (green)
cardPending:    #95A5A6  (grey)
cardLate:       #E67E22  (orange)
cardAlert:      #C0392B  (red)
background:     #F5F5F5
surface:        #FFFFFF

// Typography (large for readability)
headlineLarge:  28px bold   (greeting)
headlineMedium: 22px bold   (screen titles)
bodyLarge:      18px        (body text, min size)
labelLarge:     16px bold   (button labels)

// Spacing
cardPadding:    24px
buttonHeight:   72px        (big tap targets)
gridGap:        12px

// Border radius
card:           16px
button:         12px
```

---

## 10. B12 Injection Schedule

Start date: **25 March 2026**
Frequency: every **14 days**
Total: **40 injections** (~20 months)

```dart
DateTime b12StartDate = DateTime(2026, 3, 25);

bool isB12Day(DateTime date) {
  final diff = date.difference(b12StartDate).inDays;
  return diff >= 0 && diff % 14 == 0;
}

DateTime nextB12(DateTime from) {
  int days = 14 - (from.difference(b12StartDate).inDays % 14);
  return from.add(Duration(days: days));
}
```

---

## 11. Daily Summary Email (Backend Cron)

Dart Frog cron job, fires at **21:00 SAST (19:00 UTC)** daily.

```
Subject: Sorgvry — Amanda se daaglikse opsomming [date]

Môre medisyne:    ✓ Gevat (07:14)
Aand medisyne:    ✗ Nie gevat nie
Bloeddruk:        148/88 → MAP 108  ⚠
Water:            5 van 8 glase
Stap:             ✓ 30 minute

B12 volgende:     8 April 2026
```

Recipients: configurable list in backend `.env`.

---

## 12. Environment Config

### Backend `.env`
```
PORT=8080
DB_PATH=/data/sorgvry.db
JWT_SECRET=<strong-random>
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=...
SMTP_PASS=...
SUMMARY_EMAIL_TO=ekkerd@...,caregiver@...
SUMMARY_TIME_UTC=19:00
```

### App config (compile-time)
```dart
// lib/config.dart
const backendUrl = String.fromEnvironment('BACKEND_URL',
    defaultValue: 'http://sorgvry.local:8080');
```

Build with: `flutter build apk --dart-define=BACKEND_URL=http://192.168.x.x:8080`

---

## 13. Dependencies

### sorgvry_shared
```yaml
dependencies:
  drift: ^2.x
  sqlite3: ^2.x
```

### app
```yaml
dependencies:
  sorgvry_shared:
    path: ../packages/sorgvry_shared
  flutter_riverpod: ^2.x
  go_router: ^13.x
  flutter_local_notifications: ^17.x
  android_alarm_manager_plus: ^3.x
  flutter_secure_storage: ^9.x
  http: ^1.x
  intl: ^0.19.x
  drift: ^2.x
  sqlite3_flutter_libs: ^0.5.x
```

### backend
```yaml
dependencies:
  sorgvry_shared:
    path: ../packages/sorgvry_shared
  dart_frog: ^1.x
  drift: ^2.x
  sqlite3: ^2.x
  dart_jsonwebtoken: ^2.x
  mailer: ^6.x
  cron: ^0.5.x
```

---

## 14. Build & Deploy

### Backend (Pi)
```bash
# Build
dart compile exe backend/bin/server.dart -o sorgvry_server

# Systemd service: /etc/systemd/system/sorgvry.service
[Unit]
Description=Sorgvry Backend

[Service]
ExecStart=/home/pi/sorgvry/sorgvry_server
WorkingDirectory=/home/pi/sorgvry
EnvironmentFile=/home/pi/sorgvry/.env
Restart=always

[Install]
WantedBy=multi-user.target
```

### App (Android)
```bash
flutter build apk --release \
  --dart-define=BACKEND_URL=http://sorgvry.local:8080

# Install via ADB or share APK directly
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## 15. Phase 2 (later — not now)

- Web dashboard (Flutter web) for Ekkerd/caregiver
- BP trend chart
- Medication adherence score
- WhatsApp/Telegram alert if meds missed 2 days running
- Multi-patient support

---

_Spec written 29 March 2026. Build phase pending._
