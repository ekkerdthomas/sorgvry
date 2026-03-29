import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';
import '../models/bp_state.dart';

export '../models/bp_state.dart';

class BpRepository {
  final SorgvryDatabase db;
  final AppLocalDatabase localDb;

  BpRepository({required this.db, required this.localDb});

  Future<BpState> todayStatus() {
    throw UnimplementedError();
  }

  Future<void> saveReading({required int systolic, required int diastolic}) {
    throw UnimplementedError();
  }
}
