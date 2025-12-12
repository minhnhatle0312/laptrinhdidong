class Vehicle {
  final String id;
  final String plate;
  final String model;
  final String ownerName;

  Vehicle({
    required this.id,
    required this.plate,
    required this.model,
    required this.ownerName,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
    id: json['id'].toString(),
    plate: json['plate'] ?? '',
    model: json['model'] ?? '',
    ownerName: json['ownerName'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'plate': plate,
    'model': model,
    'ownerName': ownerName,
  };
}
