// ignore_for_file: file_names

class Service {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final String? description;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.description,
    this.isActive = true,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      durationMinutes: json['durationMinutes'] as int,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
      'description': description,
      'isActive': isActive,
    };
  }
}
