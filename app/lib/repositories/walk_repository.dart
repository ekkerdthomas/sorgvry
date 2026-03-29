import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';
import '../models/walk_state.dart';
import '../utils/device_id.dart';

export '../models/walk_state.dart';

class WalkRepository {
  final SorgvryDatabase db;
  final AppLocalDatabase localDb;
  final String deviceId;

  WalkRepository({
    required this.db,
    required this.localDb,
    this.deviceId = devDeviceId,
  });

  Future<WalkState> todayStatus() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final row =
        await (db.select(
              db.walkLogs,
            )..where((t) => t.deviceId.equals(deviceId) & t.date.equals(today)))
            .getSingleOrNull();

    if (row == null) return const WalkState();
    return WalkState(walked: row.walked, durationMin: row.durationMin);
  }

  Future<void> saveWalk({required bool walked, int? durationMin}) async {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    final entry = WalkLogsCompanion.insert(
      deviceId: deviceId,
      date: today,
      walked: walked,
      loggedAt: now,
      durationMin: Value(durationMin),
    );

    await db
        .into(db.walkLogs)
        .insert(
          entry,
          onConflict: DoUpdate(
            (_) => WalkLogsCompanion(
              walked: Value(walked),
              durationMin: Value(durationMin),
              loggedAt: Value(now),
              synced: const Value(false),
            ),
            target: [db.walkLogs.deviceId, db.walkLogs.date],
          ),
        );
  }
}
