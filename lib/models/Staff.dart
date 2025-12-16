// ignore_for_file: file_names

class Staff {
  final String id;
  final String name;
  final String position; // mechanic, manager, admin
  final String email;
  final String phone;
  final String specialization; // engine, transmission, electrical, etc
  final bool isActive;
  final DateTime joinedAt;
  final String? photoUrl;

  Staff({
    required this.id,
    required this.name,
    required this.position,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.isActive,
    required this.joinedAt,
    this.photoUrl,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? 'mechanic',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      specialization: json['specialization'] ?? '',
      isActive: json['isActive'] ?? true,
      joinedAt: json['joinedAt'] is DateTime 
          ? json['joinedAt'] as DateTime
          : DateTime.parse(json['joinedAt'] as String? ?? DateTime.now().toIso8601String()),
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'email': email,
      'phone': phone,
      'specialization': specialization,
      'isActive': isActive,
      'joinedAt': joinedAt,
      'photoUrl': photoUrl,
    };
  }
}
