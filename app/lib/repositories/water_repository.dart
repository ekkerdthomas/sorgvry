import 'package:sorgvry_shared/database/database.dart';

import '../database/local_database.dart';
import '../models/water_state.dart';

export '../models/water_state.dart';

class WaterRepository {
  final SorgvryDatabase db;
  final AppLocalDatabase localDb;

  WaterRepository({required this.db, required this.localDb});

  Future<WaterState> todayStatus() async {
    return const WaterState();
  }

  Future<void> setGlasses(int glasses) async {
    // TODO: implement write to DB + sync queue
  }
}
