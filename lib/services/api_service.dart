// services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parking_spot.dart';
import '../models/reservation.dart';
import '../models/vehicle.dart';
import '../models/customer.dart';
import '../models/Staff.dart';

class ApiService {
  String baseUrl = '';

  // -----------------------------------------------------------------
  // 1. AUTHENTICATION (Đã sửa lỗi)
  // -----------------------------------------------------------------
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Nếu không có baseUrl, trả về mock data
    if (baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (email == 'admin@test.com' && password == '123456') {
        return {'success': true, 'token': 'abc123xyz', 'user': {'name': 'Quản lý', 'role': 'admin'}};
      }
      return {'success': false, 'message': 'Sai email hoặc mật khẩu'};
    }

    // Real HTTP call
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'token': data['token'], 'user': data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {'success': false, 'message': error['message'] ?? 'Login failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối API: $e'};
    }
  }


  // -----------------------------------------------------------------
  // 2. CRUD CUSTOMERS (THÊM MỚI)
  // -----------------------------------------------------------------
  Future<List<Customer>> fetchCustomers() async {
    if (baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        Customer(id: 'c1', name: 'Nguyễn Văn A', phone: '0901xxxxxx', address: 'Hà Nội', email: 'a@mail.com'),
        Customer(id: 'c2', name: 'Trần Thị B', phone: '0902xxxxxx', address: 'HCM', email: 'b@mail.com'),
      ];
    }
    // TODO: Triển khai API call thực tế (sử dụng http.get)
    return [];
  }
  
  Future<bool> createCustomer(Customer customer) async {
    // Mock success
    await Future.delayed(const Duration(milliseconds: 300));
    return true; 
  }
  
  Future<bool> updateCustomer(Customer customer) async {
    // Mock success
    await Future.delayed(const Duration(milliseconds: 300));
    return true; 
  }

  // -----------------------------------------------------------------
  // 3. CRUD STAFF (THÊM MỚI)
  // -----------------------------------------------------------------
  Future<List<Staff>> fetchStaff() async {
    if (baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        Staff(
          id: 's1',
          name: 'Lê Văn C',
          position: 'manager',
          email: 'c@mail.com',
          phone: '0901234561',
          specialization: 'management',
          isActive: true,
          joinedAt: DateTime.now().subtract(const Duration(days: 365)),
        ),
        Staff(
          id: 's2',
          name: 'Phạm Thị D',
          position: 'mechanic',
          email: 'd@mail.com',
          phone: '0901234562',
          specialization: 'engine',
          isActive: true,
          joinedAt: DateTime.now().subtract(const Duration(days: 180)),
        ),
      ];
    }
    // TODO: Triển khai API call thực tế (sử dụng http.get)
    return [];
  }
  
  Future<bool> createStaff(Staff staff) async {
    // Mock success
    await Future.delayed(const Duration(milliseconds: 300));
    return true; 
  }
  
  Future<bool> deleteStaff(String staffId) async {
    // Mock success
    await Future.delayed(const Duration(milliseconds: 300));
    return true; 
  }

  // -----------------------------------------------------------------
  // 4. CRUD SERVICES (THÊM MỚI)
  // -----------------------------------------------------------------
  Future<List<Map<String, dynamic>>> fetchServices() async {
    if (baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
      return [
        {'id': 'sv1', 'name': 'Rửa xe cơ bản', 'price': 50000.0, 'duration': 30},
        {'id': 'sv2', 'name': 'Thay dầu', 'price': 350000.0, 'duration': 60},
        {'id': 'sv3', 'name': 'Bảo dưỡng nhanh', 'price': 800000.0, 'duration': 90},
      ];
    }
    // TODO: Triển khai API call thực tế (sử dụng http.get)
    return [];
  }
  
  // -----------------------------------------------------------------
  // 5. CÁC PHƯƠNG THỨC GỐC (GIỮ NGUYÊN)
  // -----------------------------------------------------------------

  Future<List<ParkingSpot>> fetchParkingSpots() async {
    // If no baseUrl, return mock data
    if (baseUrl.isEmpty) {
      return List.generate(
        6,
        (i) => ParkingSpot(
          id: 'spot_${i + 1}',
          name: 'Bãi xe ${i + 1}',
          lat: 21.0285 + (i * 0.001),
          lng: 105.8542 + (i * 0.001),
          isAvailable: i % 2 == 0,
          pricePerHour: 10.0 + (i * 5),
        ),
      );
    }

    // Real HTTP call
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/parking-spots'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => ParkingSpot.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load parking spots');
      }
    } catch (e) {
      // Fallback to mock data
      return List.generate(
        6,
        (i) => ParkingSpot(
          id: 'spot_${i + 1}',
          name: 'Bãi xe ${i + 1}',
          lat: 21.0285 + (i * 0.001),
          lng: 105.8542 + (i * 0.001),
          isAvailable: i % 2 == 0,
          pricePerHour: 10.0 + (i * 5),
        ),
      );
    }
  }

  Future<bool> reserveSpot(
    String spotId,
    String vehicleId,
    DateTime startAt,
  ) async {
    if (baseUrl.isEmpty) {
      return true; // Mock success
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'spotId': spotId,
          'vehicleId': vehicleId,
          'startAt': startAt.toIso8601String(),
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return true; // Mock success on error
    }
  }

  Future<bool> createPayment(double amount, String method) async {
    if (baseUrl.isEmpty) {
      return true; // Mock success
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/payments'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'method': method,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return true; // Mock success on error
    }
  }

  // -----------------------------------------------------------------
  // Parking spot management (create/update/delete) - mock implementations
  // -----------------------------------------------------------------
  Future<bool> createParkingSpot(ParkingSpot spot) async {
    if (baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/parking-spots'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(spot.toJson()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateParkingSpot(ParkingSpot spot) async {
    if (baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/parking-spots/${spot.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(spot.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteParkingSpot(String id) async {
    if (baseUrl.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    }

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/parking-spots/$id'),
        headers: {'Content-Type': 'application/json'},
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  Future<List<Vehicle>> fetchVehicles() async {
    if (baseUrl.isEmpty) {
      return [
        Vehicle(
          id: 'v1',
          plate: 'ABC-123',
          model: 'Tesla Model 3',
          ownerName: 'Nguyễn Văn A',
        ),
        Vehicle(
          id: 'v2',
          plate: 'XYZ-789',
          model: 'BMW X5',
          ownerName: 'Trần Thị B',
        ),
      ];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vehicles'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Vehicle.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load vehicles');
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<Reservation>> fetchReservations() async {
    if (baseUrl.isEmpty) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/reservations'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data
            .map((json) => Reservation.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to load reservations');
      }
    } catch (e) {
      return [];
    }
  }
}