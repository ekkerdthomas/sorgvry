import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';
import '../models/bp_state.dart';
import '../utils/device_id.dart';

export '../models/bp_state.dart';

class BpRepository {
  final SorgvryDatabase db;
  final AppLocalDatabase localDb;
  final String deviceId;

  BpRepository({
    required this.db,
    required this.localDb,
    this.deviceId = devDeviceId,
  });

  Future<BpState> todayStatus() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final row =
        await (db.select(
              db.bpReadings,
            )..where((t) => t.deviceId.equals(deviceId) & t.date.equals(today)))
            .getSingleOrNull();

    if (row == null) return const BpState();
    return BpState(
      systolic: row.systolic,
      diastolic: row.diastolic,
      meanArterialPressure: row.meanArterialPressure,
      loggedAt: row.loggedAt,
    );
  }

  Future<void> saveReading({
    required int systolic,
    required int diastolic,
  }) async {
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final map = (systolic + 2 * diastolic) / 3.0;

    final entry = BpReadingsCompanion.insert(
      deviceId: deviceId,
      date: today,
      systolic: systolic,
      diastolic: diastolic,
      meanArterialPressure: map,
      loggedAt: now,
    );

    await db
        .into(db.bpReadings)
        .insert(
          entry,
          onConflict: DoUpdate(
            (_) => BpReadingsCompanion(
              systolic: Value(systolic),
              diastolic: Value(diastolic),
              meanArterialPressure: Value(map),
              loggedAt: Value(now),
              synced: const Value(false),
            ),
            target: [db.bpReadings.deviceId, db.bpReadings.date],
          ),
        );
  }
}
