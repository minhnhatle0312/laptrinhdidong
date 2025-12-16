import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/customer.dart';

class CustomersProvider extends ChangeNotifier {
  final _database = FirebaseDatabase.instance.ref().child('customers');
  final List<Customer> _customers = [];
  bool isLoading = false;

  List<Customer> get customers => List.unmodifiable(_customers);

  Future<void> loadCustomers() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _database.get();
      _customers.clear();
      if (snapshot.exists) {
        final customersMap = Map<String, dynamic>.from(snapshot.value as Map);
        customersMap.forEach((key, value) {
          final raw = Map<String, dynamic>.from(value);
          // Normalize field names (support both 'name' and 'name_customer' formats)
          final data = <String, dynamic>{
            'id': key,
            'name': raw['name'] ?? raw['name_customer'] ?? '',
            'phone': raw['phone'] ?? raw['phone_customer'] ?? '',
            'address': raw['address'] ?? raw['address_customer'] ?? '',
            'email': raw['email'] ?? raw['email_customer'] ?? '',
          };
          _customers.add(Customer.fromJson(data));
        });
      }
    } catch (e) {
      debugPrint('Error loading customers: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(Customer c) async {
    isLoading = true;
    notifyListeners();
    try {
      final newRef = _database.push();
      await newRef.set({
        'name_customer': c.name,
        'phone_customer': c.phone,
        'address_customer': c.address,
        'email_customer': c.email,
        'createdAt': DateTime.now().toIso8601String(),
      });
      
      final newCustomer = Customer(
        id: newRef.key!,
        name: c.name,
        phone: c.phone,
        address: c.address,
        email: c.email,
      );
      _customers.insert(0, newCustomer);
    } catch (e) {
      debugPrint('Error adding customer: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  Future<void> updateCustomer(Customer c) async {
    try {
      await _database.child(c.id).update({
        'name_customer': c.name,
        'phone_customer': c.phone,
        'address_customer': c.address,
        'email_customer': c.email,
      });
      
      final idx = _customers.indexWhere((x) => x.id == c.id);
      if (idx >= 0) _customers[idx] = c;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating customer: $e');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _database.child(id).remove();
      _customers.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting customer: $e');
    }
  }
}