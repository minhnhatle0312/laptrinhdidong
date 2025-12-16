// providers/parts_provider.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Part.dart';

class PartsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final List<Part> _parts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Part> get parts => List.unmodifiable(_parts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Lấy phụ tùng theo ID
  Part? getPartById(String id) {
    try {
      return _parts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Tải tất cả phụ tùng (bao gồm logic mock nếu cần)
  Future<void> loadParts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final snapshot = await _firestore.collection('parts').where('isActive', isEqualTo: true).get();
      _parts.clear();
      for (var doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        _parts.add(Part.fromJson(data));
      }
      if (_parts.isEmpty) {
        _mockLoadParts(); // Nếu Firebase trống, tải mock data
      }
    } catch (e) {
      _errorMessage = e.toString();
      _mockLoadParts(); // Tải mock khi có lỗi kết nối
      debugPrint('Error loading parts from Firestore: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Logic mock data (Dùng khi Firebase trống hoặc lỗi)
  void _mockLoadParts() {
    if (_parts.isNotEmpty) return;
    _parts.addAll([
      Part(
        id: 'P001', name: 'Lọc dầu Honda City', sku: 'HD-OIL-F', costPrice: 80000, sellingPrice: 120000, stockQuantity: 50,
      ),
      Part(
        id: 'P002', name: 'Má phanh trước Toyota Vios', sku: 'TY-PAD-F', costPrice: 450000, sellingPrice: 750000, stockQuantity: 20,
      ),
      Part(
        id: 'P003', name: 'Bugia Denso', sku: 'DS-SPARK', costPrice: 50000, sellingPrice: 80000, stockQuantity: 100,
      ),
    ]);
  }

  /// Tạo phụ tùng mới
  Future<bool> createPart(Part part) async {
    try {
      final docRef = await _firestore.collection('parts').add(part.toJson());
      final newPart = part.copyWith(id: docRef.id);
      _parts.insert(0, newPart);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Cập nhật phụ tùng
  Future<bool> updatePart(Part part) async {
    try {
      await _firestore.collection('parts').doc(part.id).set(part.toJson(), SetOptions(merge: true));
      final index = _parts.indexWhere((p) => p.id == part.id);
      if (index >= 0) {
        _parts[index] = part;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Xóa phụ tùng (Đặt isActive = false)
  Future<bool> deletePart(String partId) async {
    try {
      await _firestore.collection('parts').doc(partId).update({'isActive': false});
      _parts.removeWhere((p) => p.id == partId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Điều chỉnh tồn kho (dùng sau khi sửa chữa/nhập hàng)
  Future<bool> adjustStock(String partId, int quantityChange) async {
    final part = getPartById(partId);
    if (part == null) return false;
    
    final newStock = part.stockQuantity + quantityChange;
    final updatedPart = part.copyWith(stockQuantity: newStock);
    
    return updatePart(updatedPart); // Sử dụng hàm updatePart đã có
  }
}