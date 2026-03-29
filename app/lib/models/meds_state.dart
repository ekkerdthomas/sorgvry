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
}
