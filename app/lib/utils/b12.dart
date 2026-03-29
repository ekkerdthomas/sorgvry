import 'package:flutter/material.dart';

final _b12Start = DateTime(2026, 3, 25);

bool isB12Day(DateTime date) {
  final diff = DateUtils.dateOnly(
    date,
  ).difference(DateUtils.dateOnly(_b12Start)).inDays;
  return diff >= 0 && diff % 14 == 0;
}

DateTime nextB12(DateTime from) {
  final daysSinceStart = DateUtils.dateOnly(
    from,
  ).difference(DateUtils.dateOnly(_b12Start)).inDays;
  if (daysSinceStart < 0) return _b12Start;
  final remainder = daysSinceStart % 14;
  if (remainder == 0) return DateUtils.dateOnly(from);
  return DateUtils.dateOnly(from).add(Duration(days: 14 - remainder));
}
