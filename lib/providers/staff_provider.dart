import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/Staff.dart';

class StaffProvider extends ChangeNotifier {
  final _database = FirebaseDatabase.instance.ref().child('staff');
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
      final snapshot = await _database.get();
      _staff.clear();
      if (snapshot.exists) {
        final staffMap = Map<String, dynamic>.from(snapshot.value as Map);
        staffMap.forEach((key, value) {
          final data = Map<String, dynamic>.from(value);
          data['id'] = key;
          // Convert joinedAt string to DateTime
          if (data['joinedAt'] is String) {
            data['joinedAt'] = DateTime.parse(data['joinedAt'] as String);
          } else {
            data['joinedAt'] = DateTime.now();
          }
          _staff.add(Staff.fromJson(data));
        });
        // Sort by joinedAt descending
        _staff.sort((a, b) => b.joinedAt.compareTo(a.joinedAt));
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error loading staff: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createStaff(Staff s) async {
    _isLoading = true;
    notifyListeners();
    try {
      final newRef = _database.push();
      await newRef.set({
        'name': s.name,
        'position': s.position,
        'email': s.email,
        'phone': s.phone,
        'specialization': s.specialization,
        'isActive': s.isActive,
        'joinedAt': DateTime.now().toIso8601String(),
        'photoUrl': s.photoUrl,
      });
      
      final newStaff = Staff(
        id: newRef.key!,
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
      final data = staffMember.toJson();
      if (data.containsKey('joinedAt') && data['joinedAt'] is DateTime) {
        data['joinedAt'] = (data['joinedAt'] as DateTime).toIso8601String();
      }
      await _database.child(staffMember.id).update(data);
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
      await _database.child(staffId).update({'isActive': false});
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
