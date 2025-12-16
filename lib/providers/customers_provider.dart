import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer.dart';

class CustomersProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Customer> _customers = [];
  bool isLoading = false;

  List<Customer> get customers => List.unmodifiable(_customers);

  Future<void> loadCustomers() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('customers').get();
      _customers.clear();
      for (var doc in snapshot.docs) {
        final raw = Map<String, dynamic>.from(doc.data());
        // Normalize field names (support both 'name' and 'name_customer' formats)
        final data = <String, dynamic>{
          'id': doc.id,
          'name': raw['name'] ?? raw['name_customer'] ?? '',
          'phone': raw['phone'] ?? raw['phone_customer'] ?? '',
          'address': raw['address'] ?? raw['address_customer'] ?? '',
          'email': raw['email'] ?? raw['email_customer'] ?? '',
        };
        _customers.add(Customer.fromJson(data));
      }
    } catch (e) {
      debugPrint('Error loading customers: $e');
    }
    isLoading = false;
    notifyListeners();
  }

  // SỬA: Không cần truyền ID khi tạo mới, Firestore sẽ tự tạo ID
  Future<void> addCustomer(Customer c) async {
    isLoading = true;
    notifyListeners();
    try {
      // SỬA: Sử dụng collection.add() để Firestore tự động tạo ID
      final docRef = await _firestore.collection('customers').add({
        'name_customer': c.name,
        'phone_customer': c.phone,
        'address_customer': c.address,
        'email_customer': c.email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      // Thêm Customer vào danh sách local với ID mới được tạo
      final newCustomer = Customer(
        id: docRef.id,
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
      // Cập nhật tài liệu Firestore bằng ID đã có
      await _firestore.collection('customers').doc(c.id).set(
        {
          'name_customer': c.name,
          'phone_customer': c.phone,
          'address_customer': c.address,
          'email_customer': c.email,
        },
        SetOptions(merge: true),
      );
      
      final idx = _customers.indexWhere((x) => x.id == c.id);
      if (idx >= 0) _customers[idx] = c;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating customer: $e');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      await _firestore.collection('customers').doc(id).delete();
      _customers.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting customer: $e');
    }
  }
}