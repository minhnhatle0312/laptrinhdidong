import 'package:flutter/material.dart';
import '../models/vehicle.dart';
import '../services/api_service.dart'; // Import ApiService

class VehiclesProvider extends ChangeNotifier {
  final ApiService api;
  
  List<Vehicle> _vehicles = [];
  bool isLoading = false; // Thêm trạng thái loading

  // Cập nhật constructor để nhận ApiService
  VehiclesProvider({required this.api});

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);

  // Phương thức tải dữ liệu từ API
  Future<void> loadVehicles() async {
    // Ngăn chặn việc gọi API nhiều lần nếu đang loading
    if (isLoading) return;

    isLoading = true;
    notifyListeners();

    try {
      // Gọi API để lấy danh sách xe
      _vehicles = await api.fetchVehicles();
    } catch (e) {
      // Log lỗi nếu cần
      debugPrint('Error loading vehicles: $e');
      _vehicles = [];
    }
    
    isLoading = false;
    notifyListeners();
  }

  void addVehicle(Vehicle v) {
    // Đây là logic mock. Trong ứng dụng thực tế, nên gọi API createVehicle trước.
    _vehicles.add(v);
    notifyListeners();
  }
}