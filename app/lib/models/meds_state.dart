class MedsState {
  final bool morningTaken;
  final bool nightTaken;
  final bool b12Taken;
  final DateTime? morningAt;
  final DateTime? nightAt;
  final DateTime? b12At;

  const MedsState({
    this.morningTaken = false,
    this.nightTaken = false,
    this.b12Taken = false,
    this.morningAt,
    this.nightAt,
    this.b12At,
  });

  bool isTaken(String session) => switch (session) {
    'morning' => morningTaken,
    'night' => nightTaken,
    'b12' => b12Taken,
    _ => false,
  };

  DateTime? takenAt(String session) => switch (session) {
    'morning' => morningAt,
    'night' => nightAt,
    'b12' => b12At,
    _ => null,
  };

  bool canUndo(String session) {
    final at = takenAt(session);
    if (at == null) return false;
    return DateTime.now().difference(at).inMinutes <= 30;
  }
}
