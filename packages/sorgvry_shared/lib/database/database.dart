import 'package:drift/drift.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [MedLogs, BpReadings, WaterLogs, WalkLogs, Devices])
class SorgvryDatabase extends _$SorgvryDatabase {
  SorgvryDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
