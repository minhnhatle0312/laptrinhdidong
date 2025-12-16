import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Service.dart';

class ServicesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Service> _services = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Service> get services => _services;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Fetch all services
  Future<void> loadServices() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore.collection('services').get();
      _services = snapshot.docs
          .map((doc) => Service.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create new service (Admin only)
  Future<bool> createService(Service service) async {
    try {
      if (service.id.isEmpty) {
        final docRef = await _firestore.collection('services').add(service.toJson());
        final newService = Service.fromJson({...service.toJson(), 'id': docRef.id});
        _services.insert(0, newService);
      } else {
        await _firestore.collection('services').doc(service.id).set(service.toJson());
        _services.add(service);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update service (Admin only)
  Future<bool> updateService(Service service) async {
    try {
      await _firestore.collection('services').doc(service.id).update(service.toJson());
      final index = _services.indexWhere((s) => s.id == service.id);
      if (index >= 0) {
        _services[index] = service;
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete service (Admin only)
  Future<bool> deleteService(String serviceId) async {
    try {
      await _firestore.collection('services').doc(serviceId).delete();
      _services.removeWhere((s) => s.id == serviceId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
