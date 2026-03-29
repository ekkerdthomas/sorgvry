# Media Attachments Design

**Date**: 2026-03-29
**Status**: Draft
**Scope**: All four health modules (BP, Meds, Water, Walk)

## Problem

Amanda needs to capture photos alongside health log entries (e.g. BP monitor screen, pill box, B12 injection site). Photos serve as both caregiver verification and a persistent visual audit trail.

## Decisions

| Decision | Choice | Why |
|----------|--------|-----|
| Storage backend | MinIO (S3-compatible) on Pi | Already running on the server; proper object storage without DB bloat |
| DB tracking | New shared `MediaAttachments` Drift table | Follows existing pattern; enables offline-first sync |
| Upload path | App → Backend (multipart) → MinIO | Keeps MinIO credentials server-side; reuses JWT auth |
| Photos per entry | Exactly one | Simplest UX for elderly user; retake replaces previous |
| UX trigger | Post-save optional prompt | Keeps input screen uncluttered; photo is not required |
| Image format | JPEG, compressed to ~800px wide | Good quality/size balance; ~100-200KB per photo |
| Scope | All 4 health modules | Consistent experience across the app |

## Architecture

### New Drift Table (sorgvry_shared)

```dart
class MediaAttachments extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get module => text()(); // bp, meds, water, walk
  TextColumn get session => text().nullable()(); // morning, evening, b12 (meds only)
  TextColumn get localPath => text()(); // app-local file path
  TextColumn get objectKey => text().nullable()(); // MinIO key, null until synced
  DateTimeColumn get loggedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {deviceId, date, module, session},
  ];
}
```

Schema version bump: shared DB 1 → 2 (add `mediaAttachments` table).

### MinIO Object Key Pattern

```
{deviceId}/{module}/{YYYY-MM-DD}.jpg
{deviceId}/{module}/{YYYY-MM-DD}-{session}.jpg   # meds only
```

Examples:
- `abc123/bp/2026-03-29.jpg`
- `abc123/meds/2026-03-29-morning.jpg`

### Backend: New Endpoint

**POST /log/media** (multipart/form-data)
- Auth: JWT Bearer token (existing middleware)
- Fields: `deviceId`, `date`, `module`, `session` (optional), `loggedAt`
- File: `photo` (JPEG)
- Action: Upload to MinIO bucket `sorgvry-media`, upsert `MediaAttachments` row with `objectKey`, `synced=true`
- Response: `{ "objectKey": "abc123/bp/2026-03-29.jpg" }`

**GET /media/:objectKey** (proxy)
- Auth: JWT Bearer token
- Action: Stream file from MinIO to client
- Use case: Caregiver dashboard viewing photos

### Backend: MinIO Client

Add `minio_new` (or `aws_s3_api`) Dart package to backend. Configure via environment variables:

```yaml
# docker-compose.yml additions
environment:
  MINIO_ENDPOINT: http://localhost:9000
  MINIO_ACCESS_KEY: ${MINIO_ACCESS_KEY}
  MINIO_SECRET_KEY: ${MINIO_SECRET_KEY}
  MINIO_BUCKET: sorgvry-media
```

### App: Capture Flow

**Post-save success state** (same pattern for all modules):

1. After successful save, screen transitions to success state
2. Success state shows result summary + large "NEEM FOTO" button (camera icon, 72px+ height)
3. Tap opens device camera via `image_picker` package
4. After capture: show preview with "GEBRUIK" (use) / "WEER" (retake)
5. On "GEBRUIK": compress to ~800px JPEG, save to app cache dir, insert `MediaAttachments` row
6. Navigate home (with or without photo — it's optional)

**New dependency**: `image_picker` in app/pubspec.yaml

### App: Sync Extension

Extend existing `SyncService` to handle media uploads:

1. Query `MediaAttachments` where `synced = false`
2. For each: read local file, send multipart POST to `/log/media`
3. On success: update row with `objectKey` from response, set `synced = true`
4. On failure: skip (retry next cycle, same as existing health data sync)

Media sync runs after health data sync in the 60s timer cycle.

### App: Media Repository

New `MediaRepository` in `app/lib/repositories/media_repository.dart`:
- `savePhoto(module, date, session?, filePath)` → insert into `MediaAttachments`
- `getPhoto(module, date, session?)` → query for display
- `unsyncedMedia()` → for sync service

New `mediaRepoProvider` in `app/lib/providers/media_providers.dart`.

### Caregiver Dashboard

Add photo thumbnails to the caregiver view. When a `MediaAttachment` exists for a log entry, show a thumbnail that opens a full-screen viewer on tap. Loads via `GET /media/:objectKey`.

## Files Touched

### New Files
| File | Purpose |
|------|---------|
| `app/lib/repositories/media_repository.dart` | Media DB operations |
| `app/lib/providers/media_providers.dart` | Riverpod providers |
| `app/lib/widgets/photo_capture_button.dart` | Reusable "NEEM FOTO" widget |
| `backend/routes/log/media.dart` | POST /log/media endpoint |
| `backend/routes/media/[key].dart` | GET /media/:key proxy |
| `backend/lib/services/minio_service.dart` | MinIO client wrapper |

### Modified Files
| File | Change |
|------|--------|
| `packages/sorgvry_shared/lib/database/tables.dart` | Add `MediaAttachments` table |
| `packages/sorgvry_shared/lib/database/database.dart` | Add to `@DriftDatabase(tables: [...])`, bump schema version, add migration |
| `packages/sorgvry_shared/lib/api/contracts.dart` | Add `MediaUploadResponse` |
| `app/pubspec.yaml` | Add `image_picker` dependency |
| `app/lib/screens/bp_screen.dart` | Add post-save photo prompt |
| `app/lib/screens/meds_screen.dart` | Add post-save photo prompt |
| `app/lib/screens/water_screen.dart` | Add post-save photo prompt |
| `app/lib/screens/walk_screen.dart` | Add post-save photo prompt |
| `app/lib/services/sync_service.dart` | Add media upload step |
| `backend/pubspec.yaml` | Add MinIO client dependency |
| `backend/Dockerfile` | No change expected (Dart deps auto-included) |
| `docker-compose.yml` | Add MINIO_* env vars |

## Implementation Order

1. Shared schema: `MediaAttachments` table + migration
2. Backend: MinIO service + `/log/media` endpoint + `/media/:key` proxy
3. App: `image_picker` + `MediaRepository` + `PhotoCaptureButton` widget
4. App: Wire photo button into all 4 module screens (post-save state)
5. App: Extend sync service for media uploads
6. Caregiver dashboard: photo thumbnails
