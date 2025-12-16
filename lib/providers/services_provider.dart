import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/Service.dart';

class ServicesProvider extends ChangeNotifier {
  final _database = FirebaseDatabase.instance.ref().child('services');
  
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
      final snapshot = await _database.get();
      _services = [];
      if (snapshot.exists) {
        final servicesMap = Map<String, dynamic>.from(snapshot.value as Map);
        servicesMap.forEach((key, value) {
          final data = Map<String, dynamic>.from(value);
          data['id'] = key;
          _services.add(Service.fromJson(data));
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

  /// Create new service (Admin only)
  Future<bool> createService(Service service) async {
    try {
      if (service.id.isEmpty) {
        final newRef = _database.push();
        await newRef.set(service.toJson());
        final newService = Service.fromJson({...service.toJson(), 'id': newRef.key!});
        _services.insert(0, newService);
      } else {
        await _database.child(service.id).set(service.toJson());
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
      await _database.child(service.id).update(service.toJson());
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
      await _database.child(serviceId).remove();
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
