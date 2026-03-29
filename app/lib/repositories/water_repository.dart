import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';
import '../models/water_state.dart';
import '../utils/device_id.dart';

export '../models/water_state.dart';

class WaterRepository {
  final SorgvryDatabase db;
  final AppLocalDatabase localDb;
  final String deviceId;

  WaterRepository({
    required this.db,
    required this.localDb,
    this.deviceId = devDeviceId,
  });

  Future<WaterState> todayStatus() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final row =
        await (db.select(
              db.waterLogs,
            )..where((t) => t.deviceId.equals(deviceId) & t.date.equals(today)))
            .getSingleOrNull();

    if (row == null) return const WaterState();
    return WaterState(glasses: row.glasses);
  }

  Future<void> setGlasses(int glasses) async {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);

    final entry = WaterLogsCompanion.insert(
      deviceId: deviceId,
      date: today,
      glasses: glasses,
      loggedAt: now,
    );

    await db
        .into(db.waterLogs)
        .insert(
          entry,
          onConflict: DoUpdate(
            (_) => WaterLogsCompanion(
              glasses: Value(glasses),
              loggedAt: Value(now),
              synced: const Value(false),
            ),
            target: [db.waterLogs.deviceId, db.waterLogs.date],
          ),
        );
  }
}
