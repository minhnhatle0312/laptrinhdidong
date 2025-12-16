// ignore_for_file: file_names

class ParkingBay {
  final String id;
  final String name;
  final int totalSpots;
  final int availableSpots;
  final String address;
  final double lat;
  final double lng;
  final double pricePerHour;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  ParkingBay({
    required this.id,
    required this.name,
    required this.totalSpots,
    required this.availableSpots,
    required this.address,
    required this.lat,
    required this.lng,
    required this.pricePerHour,
    this.imageUrl,
    this.isActive = true,
    required this.createdAt,
  });

  factory ParkingBay.fromJson(Map<String, dynamic> json) {
    return ParkingBay(
      id: json['id'] as String,
      name: json['name'] as String,
      totalSpots: json['totalSpots'] as int,
      availableSpots: json['availableSpots'] as int,
      address: json['address'] as String,
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      imageUrl: json['imageUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'totalSpots': totalSpots,
      'availableSpots': availableSpots,
      'address': address,
      'lat': lat,
      'lng': lng,
      'pricePerHour': pricePerHour,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
