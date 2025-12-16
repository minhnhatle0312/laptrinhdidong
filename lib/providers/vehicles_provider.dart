import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';

class VehiclesProvider extends ChangeNotifier {
  final _database = FirebaseDatabase.instance.ref().child('vehicles');
  final ApiService api;
  final List<Vehicle> _vehicles = [];
  bool isLoading = false;
  String? errorMessage;

  VehiclesProvider({ApiService? apiService}) : api = apiService ?? ApiService();

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  Future<void> loadVehicles() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _database.get();
      _vehicles.clear();
      if (snapshot.exists) {
        final vehiclesMap = Map<String, dynamic>.from(snapshot.value as Map);
        vehiclesMap.forEach((key, value) {
          final data = Map<String, dynamic>.from(value);
          data['id'] = key;
          _vehicles.add(Vehicle.fromJson(data));
        });
      }
    } catch (e) {
      errorMessage = e.toString();
      _vehicles.clear();
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> addVehicle(Vehicle v) async {
    try {
      final docId = v.id.isEmpty ? '' : v.id;
      if (docId.isEmpty) {
        final newRef = _database.push();
        await newRef.set(v.toJson());
        final newV = Vehicle.fromJson({...v.toJson(), 'id': newRef.key!});
        _vehicles.insert(0, newV);
      } else {
        await _database.child(docId).set(v.toJson());
        _vehicles.insert(0, v);
      }
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      _vehicles.add(v);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateVehicle(Vehicle v) async {
    try {
      if (v.id.isNotEmpty) {
        await _database.child(v.id).update(v.toJson());
      }
      final idx = _vehicles.indexWhere((x) => x.id == v.id);
      if (idx >= 0) _vehicles[idx] = v;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteVehicle(String id) async {
    try {
      if (id.isNotEmpty) {
        await _database.child(id).remove();
      }
      _vehicles.removeWhere((v) => v.id == id);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
