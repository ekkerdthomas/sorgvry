import 'package:drift/drift.dart';

part 'local_database.g.dart';

class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get endpoint => text()();
  TextColumn get payload => text()();
  DateTimeColumn get queuedAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [SyncQueue])
class AppLocalDatabase extends _$AppLocalDatabase {
  AppLocalDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
