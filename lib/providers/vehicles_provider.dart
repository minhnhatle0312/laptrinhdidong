import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart'; // THÊM IMPORT

class VehiclesProvider extends ChangeNotifier {
  // THÊM: Biến ApiService và isLoading
  final ApiService api;
  List<Vehicle> _vehicles = [];
  bool isLoading = false;

  // CẬP NHẬT: Constructor nhận ApiService
  VehiclesProvider({ApiService? apiService}) 
      : api = apiService ?? ApiService() {
    // Thử tải dữ liệu từ API, nếu lỗi sẽ dùng mock data
    // Nếu bạn muốn giữ mock data khi baseUrl rỗng, giữ nguyên logic sau:
    if (api.baseUrl.isEmpty) {
       _vehicles = [
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
    }
  }

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  // THÊM: Phương thức tải dữ liệu từ API
  Future<void> loadVehicles() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();

    try {
      _vehicles = await api.fetchVehicles();
    } catch (e) {
      // Xử lý lỗi nếu cần
      _vehicles = [];
    }

    isLoading = false;
    notifyListeners();
  }

  // CẬP NHẬT: addVehicle (Chỉ là mock logic, cần thêm gọi API thực tế)
  void addVehicle(Vehicle v) {
    _vehicles.add(v);
    // TODO: Cần thêm logic gọi api.addVehicle(v) sau này
    notifyListeners();
  }
}