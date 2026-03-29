import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:sorgvry_shared/database/database.dart';

class MediaRepository {
  final SorgvryDatabase db;
  final String deviceId;

  MediaRepository({required this.db, required this.deviceId});

  Future<void> savePhoto({
    required String module,
    String? session,
    required String localPath,
  }) async {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    final entry = MediaAttachmentsCompanion.insert(
      deviceId: deviceId,
      date: today,
      module: module,
      session: Value(session ?? 'none'),
      localPath: localPath,
      loggedAt: now,
    );

    await db
        .into(db.mediaAttachments)
        .insert(
          entry,
          onConflict: DoUpdate(
            (_) => MediaAttachmentsCompanion(
              localPath: Value(localPath),
              loggedAt: Value(now),
              synced: const Value(false),
              objectKey: const Value(null),
            ),
            target: [
              db.mediaAttachments.deviceId,
              db.mediaAttachments.date,
              db.mediaAttachments.module,
              db.mediaAttachments.session,
            ],
          ),
        );
  }

  Future<MediaAttachment?> todayPhoto({
    required String module,
    String? session,
  }) async {
    final today = DateUtils.dateOnly(DateTime.now());
    final query = db.select(db.mediaAttachments)
      ..where(
        (t) =>
            t.deviceId.equals(deviceId) &
            t.date.equals(today) &
            t.module.equals(module) &
            t.session.equals(session ?? 'none'),
      );
    return query.getSingleOrNull();
  }
}
