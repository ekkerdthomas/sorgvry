// ignore_for_file: deprecated_member_use
import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor openDatabase(String name) {
  return WebDatabase(name);
}
