import 'package:drift/drift.dart';

class MedLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get session => text()();
  BoolColumn get taken => boolean()();
  DateTimeColumn get loggedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {deviceId, date, session},
  ];
}

class BpReadings extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get systolic => integer()();
  IntColumn get diastolic => integer()();
  @JsonKey('map')
  RealColumn get meanArterialPressure => real().named('map')();
  DateTimeColumn get loggedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {deviceId, date},
  ];
}

class WaterLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  DateTimeColumn get date => dateTime()();
  IntColumn get glasses => integer()();
  DateTimeColumn get loggedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {deviceId, date},
  ];
}

class WalkLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deviceId => text()();
  DateTimeColumn get date => dateTime()();
  BoolColumn get walked => boolean()();
  IntColumn get durationMin => integer().nullable()();
  DateTimeColumn get loggedAt => dateTime()();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {deviceId, date},
  ];
}

class Devices extends Table {
  TextColumn get id => text()();
  TextColumn get patientName => text()();
  TextColumn get token => text()();
  DateTimeColumn get registeredAt => dateTime()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
