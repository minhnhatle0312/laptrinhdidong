// ignore_for_file: file_names, non_constant_identifier_names

class Car {
  final String id;
  final String model;
  final String licensePlate;
  final String ownerCustomer;

  Car({
    required this.id,
    required this.model,
    required this.licensePlate,
    required this.ownerCustomer,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id_car'] ?? json['id'] ?? '',
      model: json['model_car'] ?? json['model'] ?? '',
      licensePlate: json['license_plate'] ?? json['licensePlate'] ?? '',
      ownerCustomer: json['owner_customer'] ?? json['owner_customer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_car': id,
      'model_car': model,
      'license_plate': licensePlate,
      'owner_customer': ownerCustomer,
    };
  }
}
