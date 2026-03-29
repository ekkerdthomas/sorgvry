import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';
import '../models/walk_state.dart';

export '../models/walk_state.dart';

class WalkRepository {
  final SorgvryDatabase db;
  final AppLocalDatabase localDb;

  WalkRepository({required this.db, required this.localDb});

  Future<WalkState> todayStatus() {
    throw UnimplementedError();
  }

  Future<void> saveWalk({required bool walked, int? durationMin}) {
    throw UnimplementedError();
  }
}
