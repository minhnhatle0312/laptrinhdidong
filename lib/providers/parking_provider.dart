import 'package:flutter/material.dart';
import '../models/parking_spot.dart';
import '../services/api_service.dart';

class ParkingProvider extends ChangeNotifier {
  final ApiService api;
  List<ParkingSpot> spots = [];
  bool isLoading = false;

  ParkingProvider({ApiService? apiService}) : api = apiService ?? ApiService();

  Future<void> loadSpots() async {
    isLoading = true;
    notifyListeners();
    try {
      spots = await api.fetchParkingSpots();
    } catch (e) {
      spots = [];
    }
    isLoading = false;
    notifyListeners();
  }

  ParkingSpot? getById(String id) {
    try {
      return spots.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> reserve(String spotId, String vehicleId) async {
    final spot = getById(spotId);
    if (spot == null || !spot.isAvailable) return false;
    final ok = await api.reserveSpot(spotId, vehicleId, DateTime.now());
    if (ok) {
      spot.isAvailable = false;
      notifyListeners();
    }
    return ok;
  }

  // --- Management CRUD used by admin screens ---
  List<ParkingSpot> get parkingSpots => List.unmodifiable(spots);

  Future<void> addParkingSpot(ParkingSpot spot) async {
    // For compatibility, persist to Firestore if available via ApiService
    try {
      // If ApiService supports adding, use it; otherwise just add locally
      if (api.baseUrl.isNotEmpty) {
        await api.createParkingSpot(spot);
        await loadSpots();
      } else {
        spots.add(spot);
        notifyListeners();
      }
    } catch (e) {
      spots.add(spot);
      notifyListeners();
    }
  }

  Future<void> updateParkingSpot(ParkingSpot spot) async {
    try {
      if (api.baseUrl.isNotEmpty) {
        await api.updateParkingSpot(spot);
        await loadSpots();
      } else {
        final idx = spots.indexWhere((s) => s.id == spot.id);
        if (idx >= 0) spots[idx] = spot;
        notifyListeners();
      }
    } catch (e) {
      final idx = spots.indexWhere((s) => s.id == spot.id);
      if (idx >= 0) spots[idx] = spot;
      notifyListeners();
    }
  }

  Future<void> deleteParkingSpot(String id) async {
    try {
      if (api.baseUrl.isNotEmpty) {
        await api.deleteParkingSpot(id);
        await loadSpots();
      } else {
        spots.removeWhere((s) => s.id == id);
        notifyListeners();
      }
    } catch (e) {
      spots.removeWhere((s) => s.id == id);
      notifyListeners();
    }
  }
}
