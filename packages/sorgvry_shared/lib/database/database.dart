import 'package:drift/drift.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [MedLogs, BpReadings, WaterLogs, WalkLogs, MediaAttachments, Devices],
)
class SorgvryDatabase extends _$SorgvryDatabase {
  SorgvryDatabase(super.e);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(mediaAttachments);
      }
    },
  );
}
