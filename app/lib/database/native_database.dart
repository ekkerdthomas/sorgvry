import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor openDatabase(String name) {
  return driftDatabase(name: name);
}
