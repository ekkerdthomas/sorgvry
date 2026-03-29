import 'dart:async';

import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';

class SyncService {
  final SorgvryDatabase healthDb;
  final AppLocalDatabase localDb;
  Timer? _timer;

  SyncService({required this.healthDb, required this.localDb});

  void start() {
    _timer = Timer.periodic(const Duration(seconds: 60), (_) => _flush());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _flush() async {
    // TODO: implement queue flush
  }
}
