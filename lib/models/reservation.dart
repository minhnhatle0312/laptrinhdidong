class Reservation {
  final String id;
  final String spotId;
  final String vehicleId;
  final DateTime startAt;
  final DateTime? endAt;
  final String status; // pending, confirmed, cancelled

  Reservation({
    required this.id,
    required this.spotId,
    required this.vehicleId,
    required this.startAt,
    this.endAt,
    this.status = 'pending',
  });

  factory Reservation.fromJson(Map<String, dynamic> json) => Reservation(
    id: json['id'].toString(),
    spotId: json['spotId'].toString(),
    vehicleId: json['vehicleId'].toString(),
    startAt: DateTime.parse(json['startAt']),
    endAt: json['endAt'] != null ? DateTime.parse(json['endAt']) : null,
    status: json['status'] ?? 'pending',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'spotId': spotId,
    'vehicleId': vehicleId,
    'startAt': startAt.toIso8601String(),
    'endAt': endAt?.toIso8601String(),
    'status': status,
  };
}
