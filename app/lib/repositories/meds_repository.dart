import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';
import '../models/meds_state.dart';

export '../models/meds_state.dart';

class MedsRepository {
  final SorgvryDatabase db;
  final AppLocalDatabase localDb;

  MedsRepository({required this.db, required this.localDb});

  Future<MedsState> todayStatus() {
    throw UnimplementedError();
  }

  Future<void> confirmMeds({required String session, required bool taken}) {
    throw UnimplementedError();
  }
}
