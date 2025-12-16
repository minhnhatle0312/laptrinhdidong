class Reservation {
  final String id;
  final String spotId;
  final String vehicleId;
  final DateTime startAt;
  final DateTime? endAt;
  final String status; // 'active', 'completed', 'cancelled'

  Reservation({
    required this.id,
    required this.spotId,
    required this.vehicleId,
    required this.startAt,
    this.endAt,
    this.status = 'active',
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? '',
      spotId: json['spotId'] ?? '',
      vehicleId: json['vehicleId'] ?? '',
      startAt: json['startAt'] != null ? DateTime.parse(json['startAt']) : DateTime.now(),
      endAt: json['endAt'] != null ? DateTime.parse(json['endAt']) : null,
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'spotId': spotId,
      'vehicleId': vehicleId,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt?.toIso8601String(),
      'status': status,
    };
  }
}
