import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Staff.dart';

class StaffProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Staff> _staff = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Staff> get staff => List.unmodifiable(_staff);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadStaff() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('staff').get();
      _staff.clear();
      for (var doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        // Sử dụng logic chuyển đổi an toàn cho DateTime
        data['joinedAt'] = data['joinedAt'] is Timestamp 
          ? (data['joinedAt'] as Timestamp).toDate()
          : (data['joinedAt'] is String 
              ? DateTime.parse(data['joinedAt'] as String) 
              : DateTime.now());
        _staff.add(Staff.fromJson(data));
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading staff: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Sửa: Sử dụng collection.add() để Firestore tự động tạo ID
  Future<bool> createStaff(Staff s) async {
    _isLoading = true;
    notifyListeners();
    try {
      final docRef = await _firestore.collection('staff').add({
        'name': s.name,
        'position': s.position,
        'email': s.email,
        'phone': s.phone,
        'specialization': s.specialization,
        'isActive': s.isActive,
        'joinedAt': FieldValue.serverTimestamp(), // Sử dụng server timestamp
        'photoUrl': s.photoUrl,
      });
      
      // Thêm nhân viên vào danh sách local với ID và timestamp mới
      final newStaff = Staff(
        id: docRef.id,
        name: s.name,
        email: s.email,
        phone: s.phone,
        position: s.position,
        specialization: s.specialization,
        isActive: s.isActive,
        joinedAt: DateTime.now(),
        photoUrl: s.photoUrl,
      );
      _staff.insert(0, newStaff);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update staff (Admin)
  Future<bool> updateStaff(Staff staffMember) async {
    try {
      await _firestore.collection('staff').doc(staffMember.id).update(staffMember.toJson());
      final index = _staff.indexWhere((s) => s.id == staffMember.id);
      if (index >= 0) {
        _staff[index] = staffMember;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete staff (Admin) - soft delete
  Future<bool> deleteStaff(String staffId) async {
    try {
      await _firestore.collection('staff').doc(staffId).update({'isActive': false});
      _staff.removeWhere((s) => s.id == staffId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get staff by position
  List<Staff> getStaffByPosition(String position) {
    return _staff.where((s) => s.position == position).toList();
  }

  /// Get staff by specialization
  List<Staff> getStaffBySpecialization(String specialization) {
    return _staff.where((s) => s.specialization == specialization).toList();
  }
}
