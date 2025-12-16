import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  final _database = FirebaseDatabase.instance.ref();
  
  // Stats for dashboard
  Map<String, dynamic> _adminStats = {
    'totalVehicles': 0,
    'totalTickets': 0,
    'totalRevenue': 0.0,
    'pendingTickets': 0,
    'totalCustomers': 0,
    'totalStaff': 0,
    'estimatedProfit': 0.0,
    'profitMargin': 0.0,
  };

  Map<String, dynamic> _userStats = {
    'myVehicles': 0,
    'activeTickets': 0,
    'completedTickets': 0,
    'totalSpent': 0.0,
  };

  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic> get adminStats => _adminStats;
  Map<String, dynamic> get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load admin dashboard stats
  Future<void> loadAdminStats() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get total vehicles
      final vehiclesSnap = await _database.child('vehicles').get();
      final totalVehicles = vehiclesSnap.exists ? (vehiclesSnap.value as Map).length : 0;

      // Get total repair tickets
      final ticketsSnap = await _database.child('repair_tickets').get();
      final totalTickets = ticketsSnap.exists ? (ticketsSnap.value as Map).length : 0;

      // Get pending tickets
      int pendingTickets = 0;
      if (ticketsSnap.exists) {
        final ticketsMap = Map<String, dynamic>.from(ticketsSnap.value as Map);
        pendingTickets = ticketsMap.values
            .where((t) {
              final status = t is Map ? t['status'] : null;
              return status == 'received' || status == 'waiting' || status == 'repairing';
            })
            .length;
      }

      // Get total revenue
      final paymentsSnap = await _database.child('payments').get();
      double totalRevenue = 0;
      if (paymentsSnap.exists) {
        final paymentsMap = Map<String, dynamic>.from(paymentsSnap.value as Map);
        paymentsMap.values.forEach((p) {
          if (p is Map && p['status'] == 'success') {
            totalRevenue += (p['amount'] as num?)?.toDouble() ?? 0;
          }
        });
      }

      // Get total customers
      final customersSnap = await _database.child('customers').get();
      final totalCustomers = customersSnap.exists ? (customersSnap.value as Map).length : 0;

      // Get total staff
      final staffSnap = await _database.child('staff').get();
      final totalStaff = staffSnap.exists ? (staffSnap.value as Map).length : 0;

      // Calculate estimated profit (assume 30% margin)
      const profitMarginPercent = 0.30;
      final estimatedProfit = totalRevenue * profitMarginPercent;
      final profitMargin = totalRevenue > 0 ? (estimatedProfit / totalRevenue) * 100 : 0.0;

      _adminStats = {
        'totalVehicles': totalVehicles,
        'totalTickets': totalTickets,
        'totalRevenue': totalRevenue,
        'pendingTickets': pendingTickets,
        'totalCustomers': totalCustomers,
        'totalStaff': totalStaff,
        'estimatedProfit': estimatedProfit,
        'profitMargin': profitMargin,
      };

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load user dashboard stats
  Future<void> loadUserStats(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Get my vehicles
      final vehiclesSnap = await _database.child('vehicles').get();
      int myVehicles = 0;
      if (vehiclesSnap.exists) {
        final vehiclesMap = Map<String, dynamic>.from(vehiclesSnap.value as Map);
        myVehicles = vehiclesMap.values
            .where((v) => v is Map && v['customerId'] == customerId)
            .length;
      }

      // Get active tickets
      final ticketsSnap = await _database.child('repair_tickets').get();
      int activeTickets = 0;
      if (ticketsSnap.exists) {
        final ticketsMap = Map<String, dynamic>.from(ticketsSnap.value as Map);
        activeTickets = ticketsMap.values
            .where((t) {
              if (t is !Map) return false;
              final status = t['status'];
              return t['customerId'] == customerId && 
                  (status == 'received' || status == 'waiting' || status == 'repairing');
            })
            .length;
      }

      // Get completed tickets
      int completedTickets = 0;
      if (ticketsSnap.exists) {
        final ticketsMap = Map<String, dynamic>.from(ticketsSnap.value as Map);
        completedTickets = ticketsMap.values
            .where((t) =>
                t is Map && 
                t['customerId'] == customerId && 
                t['status'] == 'completed')
            .length;
      }

      // Get total spent
      final paymentsSnap = await _database.child('payments').get();
      double totalSpent = 0;
      if (paymentsSnap.exists) {
        final paymentsMap = Map<String, dynamic>.from(paymentsSnap.value as Map);
        paymentsMap.values.forEach((p) {
          if (p is Map && p['customerId'] == customerId && p['status'] == 'success') {
            totalSpent += (p['amount'] as num?)?.toDouble() ?? 0;
          }
        });
      }

      _userStats = {
        'myVehicles': myVehicles,
        'activeTickets': activeTickets,
        'completedTickets': completedTickets,
        'totalSpent': totalSpent,
      };

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
