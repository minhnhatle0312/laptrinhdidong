import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart';

class VehiclesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
      final snapshot = await _firestore.collection('vehicles').get();
      _vehicles.clear();
      for (var doc in snapshot.docs) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        _vehicles.add(Vehicle.fromJson(data));
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
        final doc = await _firestore.collection('vehicles').add(v.toJson());
        final newV = Vehicle.fromJson({...v.toJson(), 'id': doc.id});
        _vehicles.insert(0, newV);
      } else {
        await _firestore.collection('vehicles').doc(docId).set(v.toJson());
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
        await _firestore.collection('vehicles').doc(v.id).set(v.toJson(), SetOptions(merge: true));
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
        await _firestore.collection('vehicles').doc(id).delete();
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
