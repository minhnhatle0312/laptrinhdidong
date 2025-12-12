import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/parking_spot.dart';
import '../models/reservation.dart';
import '../models/vehicle.dart';

class ApiService {
  String baseUrl = '';

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

  Future<bool> authenticate(String email, String password) async {
    // Mock authentication
    await Future.delayed(const Duration(seconds: 2));
    return email == 'user@test.com' && password == '123456';
  }
}
