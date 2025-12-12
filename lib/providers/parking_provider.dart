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
}
