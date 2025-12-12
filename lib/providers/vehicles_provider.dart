import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class VehiclesProvider extends ChangeNotifier {
  final List<Vehicle> _vehicles = [
    Vehicle(
      id: 'v1',
      plate: '51A-123.45',
      model: 'Toyota Vios',
      ownerName: 'Nguyễn A',
    ),
    Vehicle(
      id: 'v2',
      plate: '29B-987.65',
      model: 'Honda City',
      ownerName: 'Trần B',
    ),
  ];

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  void addVehicle(Vehicle v) {
    _vehicles.add(v);
    notifyListeners();
  }
}
