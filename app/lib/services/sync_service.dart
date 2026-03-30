import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:sorgvry_shared/api/contracts.dart';
import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';
import 'sync_status.dart';

class SyncService {
  final SorgvryDatabase healthDb;
  final AppLocalDatabase localDb;
  final String baseUrl;
  final String deviceId;
  final http.Client _client;
  Timer? _timer;
  String? _token;
  bool _running = false;
  final ValueNotifier<SyncStatus> statusNotifier = ValueNotifier(
    const SyncStatus(),
  );

  SyncService({
    required this.healthDb,
    required this.localDb,
    required this.baseUrl,
    required this.deviceId,
    http.Client? client,
  }) : _client = client ?? http.Client();

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _flush());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _flush() async {
    if (_running) return;
    _running = true;
    try {
      _token ??= await _loadOrRegisterToken();
      await _syncMeds();
      await _syncBp();
      await _syncWater();
      await _syncWalk();
      await _syncMedia();
      statusNotifier.value = SyncStatus(
        lastSuccessfulSync: DateTime.now(),
        unsyncedCounts: await _countUnsynced(),
      );
    } catch (e) {
      final prev = statusNotifier.value;
      Map<String, int> counts;
      try {
        counts = await _countUnsynced();
      } catch (_) {
        counts = prev.unsyncedCounts;
      }
      statusNotifier.value = SyncStatus(
        lastSuccessfulSync: prev.lastSuccessfulSync,
        lastError: e.toString(),
        consecutiveErrors: prev.consecutiveErrors + 1,
        unsyncedCounts: counts,
      );
    } finally {
      _running = false;
    }
  }

  Future<Map<String, int>> _countUnsynced() async {
    Future<int> count(TableInfo table, GeneratedColumn<bool> synced) async {
      final expr = countAll();
      final query = healthDb.selectOnly(table)
        ..addColumns([expr])
        ..where(synced.equals(false));
      return await query.map((r) => r.read(expr)!).getSingle();
    }

    return {
      'meds': await count(healthDb.medLogs, healthDb.medLogs.synced),
      'bp': await count(healthDb.bpReadings, healthDb.bpReadings.synced),
      'water': await count(healthDb.waterLogs, healthDb.waterLogs.synced),
      'walk': await count(healthDb.walkLogs, healthDb.walkLogs.synced),
      'media': await count(
        healthDb.mediaAttachments,
        healthDb.mediaAttachments.synced,
      ),
    };
  }

  // -- Auth ------------------------------------------------------------------

  Future<String> _loadOrRegisterToken() async {
    final row = await (localDb.select(
      localDb.keyValue,
    )..where((t) => t.key.equals('auth_token'))).getSingleOrNull();
    if (row != null) return row.value;

    final resp = await _client.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        RegisterRequest(deviceId: deviceId, patientName: 'Amanda').toJson(),
      ),
    );
    if (resp.statusCode != 200) throw Exception('Registration failed');

    final token = RegisterResponse.fromJson(
      jsonDecode(resp.body) as Map<String, dynamic>,
    ).token;

    await localDb
        .into(localDb.keyValue)
        .insert(
          KeyValueCompanion.insert(key: 'auth_token', value: token),
          onConflict: DoUpdate((_) => KeyValueCompanion(value: Value(token))),
        );
    return token;
  }

  // -- HTTP helper -----------------------------------------------------------

  Future<bool> _post(String endpoint, Map<String, dynamic> body) async {
    final resp = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      },
      body: jsonEncode(body),
    );
    if (resp.statusCode == 401) {
      _token = null;
      await (localDb.delete(
        localDb.keyValue,
      )..where((t) => t.key.equals('auth_token'))).go();
      throw Exception('Token expired');
    }
    return resp.statusCode == 200;
  }

  // -- Per-table sync --------------------------------------------------------

  String _dateStr(DateTime d) => d.toIso8601String().substring(0, 10);

  Future<void> _syncMeds() async {
    final rows =
        await (healthDb.select(healthDb.medLogs)
              ..where((t) => t.synced.equals(false))
              ..limit(50))
            .get();
    for (final row in rows) {
      try {
        final ok = await _post(
          '/log/meds',
          MedLogRequest(
            deviceId: row.deviceId,
            date: _dateStr(row.date),
            session: row.session,
            taken: row.taken,
            loggedAt: row.loggedAt.toIso8601String(),
          ).toJson(),
        );
        if (ok) {
          await (healthDb.update(healthDb.medLogs)
                ..where((t) => t.id.equals(row.id)))
              .write(const MedLogsCompanion(synced: Value(true)));
        }
      } catch (e) {
        debugPrint('Sync error: $e');
      }
    }
  }

  Future<void> _syncBp() async {
    final rows =
        await (healthDb.select(healthDb.bpReadings)
              ..where((t) => t.synced.equals(false))
              ..limit(50))
            .get();
    for (final row in rows) {
      try {
        final ok = await _post(
          '/log/bp',
          BpReadingRequest(
            deviceId: row.deviceId,
            date: _dateStr(row.date),
            systolic: row.systolic,
            diastolic: row.diastolic,
            map: row.meanArterialPressure,
            loggedAt: row.loggedAt.toIso8601String(),
          ).toJson(),
        );
        if (ok) {
          await (healthDb.update(healthDb.bpReadings)
                ..where((t) => t.id.equals(row.id)))
              .write(const BpReadingsCompanion(synced: Value(true)));
        }
      } catch (e) {
        debugPrint('Sync error: $e');
      }
    }
  }

  Future<void> _syncWater() async {
    final rows =
        await (healthDb.select(healthDb.waterLogs)
              ..where((t) => t.synced.equals(false))
              ..limit(50))
            .get();
    for (final row in rows) {
      try {
        final ok = await _post(
          '/log/water',
          WaterLogRequest(
            deviceId: row.deviceId,
            date: _dateStr(row.date),
            glasses: row.glasses,
            loggedAt: row.loggedAt.toIso8601String(),
          ).toJson(),
        );
        if (ok) {
          await (healthDb.update(healthDb.waterLogs)
                ..where((t) => t.id.equals(row.id)))
              .write(const WaterLogsCompanion(synced: Value(true)));
        }
      } catch (e) {
        debugPrint('Sync error: $e');
      }
    }
  }

  Future<void> _syncWalk() async {
    final rows =
        await (healthDb.select(healthDb.walkLogs)
              ..where((t) => t.synced.equals(false))
              ..limit(50))
            .get();
    for (final row in rows) {
      try {
        final ok = await _post(
          '/log/walk',
          WalkLogRequest(
            deviceId: row.deviceId,
            date: _dateStr(row.date),
            walked: row.walked,
            durationMin: row.durationMin,
            loggedAt: row.loggedAt.toIso8601String(),
          ).toJson(),
        );
        if (ok) {
          await (healthDb.update(healthDb.walkLogs)
                ..where((t) => t.id.equals(row.id)))
              .write(const WalkLogsCompanion(synced: Value(true)));
        }
      } catch (e) {
        debugPrint('Sync error: $e');
      }
    }
  }

  // -- Media sync --------------------------------------------------------------

  /// Posts a multipart request and returns the decoded JSON body on success,
  /// or null on failure.
  Future<Map<String, dynamic>?> _postMultipart(
    String endpoint,
    Map<String, String> fields,
    String filePath,
  ) async {
    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'))
          ..headers['Authorization'] = 'Bearer $_token'
          ..fields.addAll(fields)
          ..files.add(await http.MultipartFile.fromPath('file', filePath));

    final streamed = await _client.send(request);
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 401) {
      _token = null;
      await (localDb.delete(
        localDb.keyValue,
      )..where((t) => t.key.equals('auth_token'))).go();
      throw Exception('Token expired');
    }
    if (resp.statusCode == 200) {
      return jsonDecode(resp.body) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> _syncMedia() async {
    final rows =
        await (healthDb.select(healthDb.mediaAttachments)
              ..where((t) => t.synced.equals(false))
              ..limit(10))
            .get();
    for (final row in rows) {
      try {
        final file = File(row.localPath);
        if (!file.existsSync()) {
          debugPrint('Media file missing, skipping: ${row.localPath}');
          await (healthDb.update(healthDb.mediaAttachments)
                ..where((t) => t.id.equals(row.id)))
              .write(const MediaAttachmentsCompanion(synced: Value(true)));
          continue;
        }

        final fields = MediaUploadFields(
          deviceId: row.deviceId,
          date: _dateStr(row.date),
          module: row.module,
          session: row.session,
          loggedAt: row.loggedAt.toIso8601String(),
        ).toFields();

        final resp = await _postMultipart('/log/media', fields, row.localPath);
        if (resp != null) {
          final objectKey = resp['objectKey'] as String;
          await (healthDb.update(
            healthDb.mediaAttachments,
          )..where((t) => t.id.equals(row.id))).write(
            MediaAttachmentsCompanion(
              synced: const Value(true),
              objectKey: Value(objectKey),
            ),
          );
        }
      } catch (e) {
        debugPrint('Media sync error: $e');
      }
    }
  }
}
