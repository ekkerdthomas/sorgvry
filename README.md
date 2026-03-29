# Sorgvry

Afrikaans health companion app for tracking daily medication, blood pressure, water intake, and walking. Built for offline-first use on Android and Web, with cloud sync to a self-hosted Raspberry Pi backend.

## Features

- **Medisyne** — Morning/evening medication tracking with B12 injection schedule
- **Bloeddruk** — Blood pressure logging with MAP calculation and history
- **Water** — Daily water glass counter
- **Stap** — Walking log with optional duration
- **Foto's** — Photo attachments per health entry, stored in MinIO
- **Versorger** — PIN-locked caregiver dashboard
- **Data Export** — CSV export of all health data
- **Offline-first** — All data saved locally, synced every 60 seconds

## Tech Stack

| Layer | Technology |
|-------|-----------|
| App | Flutter (Android + Web PWA) |
| State | Riverpod (AsyncNotifier + Repository) |
| Database | SQLite via Drift |
| Backend | Dart Frog |
| Auth | JWT |
| Media | MinIO |
| Mono-repo | Melos |

## Getting Started

### Prerequisites

- Flutter SDK ^3.10.0
- Dart SDK
- Melos (`dart pub global activate melos`)

### Setup

```bash
# Clone and bootstrap
git clone <repo-url>
cd sorgvry
melos bootstrap

# Generate Drift code
melos run build_runner
```

### Local Development

```bash
# Run backend + web app together
./scripts/dev.sh

# Or run separately
cd backend && dart_frog dev
cd app && flutter run
```

### Build

```bash
./scripts/build.sh
```

### Deploy

```bash
./scripts/deploy.sh
```

## Project Structure

```
sorgvry/
  app/                        # Flutter app (Android + Web)
    lib/src/
      screens/                # Home, Meds, BP, Water, Walk, Caregiver
      providers/              # Riverpod AsyncNotifiers
      repositories/           # Data access layer
      services/               # Sync, notifications
      widgets/                # Shared UI components
  backend/                    # Dart Frog API server
    routes/
      auth/register.dart      # Device registration
      log/                    # meds, bp, water, walk, media endpoints
      summary.dart            # Daily health summary
      data-export.dart        # CSV export
  packages/
    sorgvry_shared/           # Drift schema, models, API contracts
  scripts/                    # dev, build, deploy
  docs/                       # Spec and design plans
```

## API

| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/register` | Register device |
| POST | `/log/meds` | Log medication |
| POST | `/log/bp` | Log blood pressure |
| POST | `/log/water` | Log water intake |
| POST | `/log/walk` | Log walking |
| POST | `/log/media` | Upload photo |
| GET | `/media/:key` | Get media file |
| GET | `/summary` | Daily summary |
| GET | `/bp/history` | BP history |
| GET | `/data-export` | CSV export |

## Conventions

- UI language: **Afrikaans**
- Code language: **English**
- Large tap targets (72px+ buttons) for elderly user accessibility
- Offline-first with `synced` column on all health tables
- Upsert by natural keys for idempotent sync

## License

Private project.
