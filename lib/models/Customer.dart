class Customer {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String email;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
    };
  }
}
