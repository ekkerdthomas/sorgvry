import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';
import '../models/meds_state.dart';
import '../utils/device_id.dart';

export '../models/meds_state.dart';

class MedsRepository {
  final SorgvryDatabase db;
  final AppLocalDatabase localDb;
  final String deviceId;

  MedsRepository({
    required this.db,
    required this.localDb,
    this.deviceId = devDeviceId,
  });

  Future<MedsState> todayStatus() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final rows = await (db.select(
      db.medLogs,
    )..where((t) => t.deviceId.equals(deviceId) & t.date.equals(today))).get();

    bool morningTaken = false;
    bool nightTaken = false;
    bool b12Taken = false;
    DateTime? morningAt;
    DateTime? nightAt;
    DateTime? b12At;

    for (final row in rows) {
      if (!row.taken) continue;
      switch (row.session) {
        case 'morning':
          morningTaken = true;
          morningAt = row.loggedAt;
        case 'night':
          nightTaken = true;
          nightAt = row.loggedAt;
        case 'b12':
          b12Taken = true;
          b12At = row.loggedAt;
      }
    }

    return MedsState(
      morningTaken: morningTaken,
      nightTaken: nightTaken,
      b12Taken: b12Taken,
      morningAt: morningAt,
      nightAt: nightAt,
      b12At: b12At,
    );
  }

  static const _validSessions = {'morning', 'night', 'b12'};

  Future<void> confirmMeds({
    required String session,
    required bool taken,
  }) async {
    assert(_validSessions.contains(session), 'Invalid session: $session');
    if (!_validSessions.contains(session)) return;
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final entry = MedLogsCompanion.insert(
      deviceId: deviceId,
      date: today,
      session: session,
      taken: taken,
      loggedAt: now,
    );

    await db
        .into(db.medLogs)
        .insert(
          entry,
          onConflict: DoUpdate(
            (_) => MedLogsCompanion(
              taken: Value(taken),
              loggedAt: Value(now),
              synced: const Value(false),
            ),
            target: [db.medLogs.deviceId, db.medLogs.date, db.medLogs.session],
          ),
        );
  }

  Future<bool> undoMeds(String session) async {
    final today = DateUtils.dateOnly(DateTime.now());
    return db.transaction(() async {
      final row =
          await (db.select(db.medLogs)..where(
                (t) =>
                    t.deviceId.equals(deviceId) &
                    t.date.equals(today) &
                    t.session.equals(session),
              ))
              .getSingleOrNull();

      if (row == null) return false;

      final elapsed = DateTime.now().difference(row.loggedAt);
      if (elapsed.inMinutes > 30) return false;

      await (db.delete(db.medLogs)..where(
            (t) =>
                t.deviceId.equals(deviceId) &
                t.date.equals(today) &
                t.session.equals(session),
          ))
          .go();
      return true;
    });
  }
}
