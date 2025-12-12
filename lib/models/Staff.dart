// ignore_for_file: file_names

class Staff {
  final String id;
  final String name;
  final String position;
  final String email;

  Staff({
    required this.id,
    required this.name,
    required this.position,
    required this.email,
  });

  factory Staff.fromJson(Map<String, dynamic> json) {
    return Staff(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      position: json['position'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'position': position, 'email': email};
  }
}
