class ParkingSpot {
  final String id;
  final String name;
  final double lat;
  final double lng;
  bool isAvailable;
  final double pricePerHour;

  ParkingSpot({
    required this.id,
    required this.name,
    required this.lat,
    required this.lng,
    required this.isAvailable,
    required this.pricePerHour,
  });

  factory ParkingSpot.fromJson(Map<String, dynamic> json) {
    return ParkingSpot(
      id: json['id'].toString(),
      name: json['name'] ?? 'Bãi xe',
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      isAvailable: json['isAvailable'] ?? true,
      pricePerHour: (json['pricePerHour'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'lat': lat,
    'lng': lng,
    'isAvailable': isAvailable,
    'pricePerHour': pricePerHour,
  };
}
