// ignore_for_file: file_names, non_constant_identifier_names

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
      id: json['id_customer'] ?? json['id'] ?? '',
      name: json['name_customer'] ?? json['name'] ?? '',
      phone: json['phone_customer'] ?? json['phone'] ?? '',
      address: json['address_customer'] ?? json['address'] ?? '',
      email: json['email_customer'] ?? json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_customer': id,
      'name_customer': name,
      'phone_customer': phone,
      'address_customer': address,
      'email_customer': email,
    };
  }
}
