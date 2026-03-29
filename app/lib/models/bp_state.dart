class BpState {
  final int? systolic;
  final int? diastolic;
  final double? meanArterialPressure;
  final DateTime? loggedAt;

  const BpState({
    this.systolic,
    this.diastolic,
    this.meanArterialPressure,
    this.loggedAt,
  });

  bool get hasReading => systolic != null;
}
