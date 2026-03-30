import 'package:flutter/foundation.dart';

@immutable
class SyncStatus {
  final DateTime? lastSuccessfulSync;
  final String? lastError;
  final int consecutiveErrors;
  final Map<String, int> unsyncedCounts;

  const SyncStatus({
    this.lastSuccessfulSync,
    this.lastError,
    this.consecutiveErrors = 0,
    this.unsyncedCounts = const {},
  });

  bool get isHealthy => consecutiveErrors == 0 && lastError == null;
}
