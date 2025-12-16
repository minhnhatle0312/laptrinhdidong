import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/ParkingBay.dart';

class ParkingBaysProvider extends ChangeNotifier {
  final _database = FirebaseDatabase.instance.ref().child('parking_bays');
  
  List<ParkingBay> _bays = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ParkingBay> get bays => _bays;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load parking bays
  Future<void> loadBays() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _database.get();
      _bays = [];
      if (snapshot.exists) {
        final baysMap = Map<String, dynamic>.from(snapshot.value as Map);
        baysMap.forEach((key, value) {
          final data = Map<String, dynamic>.from(value);
          data['id'] = key;
          // Only load active bays
          if (data['isActive'] != false) {
            _bays.add(ParkingBay.fromJson(data));
          }
        });
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create parking bay (Admin)
  Future<bool> createBay(ParkingBay bay) async {
    try {
      await _database.child(bay.id).set(bay.toJson());
      _bays.add(bay);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update parking bay (Admin)
  Future<bool> updateBay(ParkingBay bay) async {
    try {
      await _database.child(bay.id).update(bay.toJson());
      final index = _bays.indexWhere((b) => b.id == bay.id);
      if (index >= 0) {
        _bays[index] = bay;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete parking bay (Admin)
  Future<bool> deleteBay(String bayId) async {
    try {
      await _database.child(bayId).update({'isActive': false});
      _bays.removeWhere((b) => b.id == bayId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update available spots (when vehicle enters/exits)
  Future<bool> updateAvailableSpots(String bayId, int change) async {
    try {
      final bay = _bays.firstWhere((b) => b.id == bayId);
      final newAvailable = (bay.availableSpots + change).clamp(0, bay.totalSpots);
      await _database.child(bayId).update({
        'availableSpots': newAvailable,
      });
      final index = _bays.indexWhere((b) => b.id == bayId);
      if (index >= 0) {
        _bays[index] = ParkingBay(
          id: bay.id,
          name: bay.name,
          totalSpots: bay.totalSpots,
          availableSpots: newAvailable,
          address: bay.address,
          lat: bay.lat,
          lng: bay.lng,
          pricePerHour: bay.pricePerHour,
          imageUrl: bay.imageUrl,
          isActive: bay.isActive,
          createdAt: bay.createdAt,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
