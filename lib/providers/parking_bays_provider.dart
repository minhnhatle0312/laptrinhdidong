import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ParkingBay.dart';

class ParkingBaysProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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
      final snapshot = await _firestore
          .collection('parking_bays')
          .where('isActive', isEqualTo: true)
          .get();
      _bays = snapshot.docs
          .map((doc) => ParkingBay.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
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
      await _firestore.collection('parking_bays').doc(bay.id).set(bay.toJson());
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
      await _firestore.collection('parking_bays').doc(bay.id).update(bay.toJson());
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
      await _firestore.collection('parking_bays').doc(bayId).update({'isActive': false});
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
      await _firestore.collection('parking_bays').doc(bayId).update({
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
