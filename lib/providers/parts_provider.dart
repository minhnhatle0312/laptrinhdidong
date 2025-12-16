// providers/parts_provider.dart

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/Part.dart';

class PartsProvider extends ChangeNotifier {
  final _database = FirebaseDatabase.instance.ref().child('parts');
  final List<Part> _parts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Part> get parts => List.unmodifiable(_parts);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get part by ID
  Part? getPartById(String id) {
    try {
      return _parts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Load all parts
  Future<void> loadParts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final snapshot = await _database.get();
      _parts.clear();
      if (snapshot.exists) {
        final partsMap = Map<String, dynamic>.from(snapshot.value as Map);
        partsMap.forEach((key, value) {
          final data = Map<String, dynamic>.from(value);
          data['id'] = key;
          // Only load active parts
          if (data['isActive'] != false) {
            _parts.add(Part.fromJson(data));
          }
        });
      }
      if (_parts.isEmpty) {
        _mockLoadParts(); // If Realtime DB is empty, load mock data
      }
    } catch (e) {
      _errorMessage = e.toString();
      _mockLoadParts(); // Load mock data on error
      debugPrint('Error loading parts from Firebase: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Mock data logic
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

  /// Create new part
  Future<bool> createPart(Part part) async {
    try {
      final newRef = _database.push();
      await newRef.set(part.toJson());
      final newPart = part.copyWith(id: newRef.key!);
      _parts.insert(0, newPart);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update part
  Future<bool> updatePart(Part part) async {
    try {
      await _database.child(part.id).update(part.toJson());
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
  
  /// Delete part (soft delete)
  Future<bool> deletePart(String partId) async {
    try {
      await _database.child(partId).update({'isActive': false});
      _parts.removeWhere((p) => p.id == partId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Adjust stock
  Future<bool> adjustStock(String partId, int quantityChange) async {
    final part = getPartById(partId);
    if (part == null) return false;
    
    final newStock = part.stockQuantity + quantityChange;
    final updatedPart = part.copyWith(stockQuantity: newStock);
    
    return updatePart(updatedPart);
  }
}