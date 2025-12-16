import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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
      final vehiclesSnap = await _firestore.collection('vehicles').count().get();
      final totalVehicles = vehiclesSnap.count ?? 0;

      // Get total repair tickets
      final ticketsSnap = await _firestore.collection('repair_tickets').count().get();
      final totalTickets = ticketsSnap.count ?? 0;

      // Get pending tickets
      final pendingSnap = await _firestore
          .collection('repair_tickets')
          .where('status', whereIn: ['received', 'waiting', 'repairing']).count().get();
      final pendingTickets = pendingSnap.count ?? 0;

      // Get total revenue
      final paymentsSnap = await _firestore
          .collection('payments')
          .where('status', isEqualTo: 'success')
          .get();
      double totalRevenue = 0;
      for (var doc in paymentsSnap.docs) {
        totalRevenue += (doc['amount'] as num?)?.toDouble() ?? 0;
      }

      // Get total customers (unique customerId from vehicles)
      final customersSnap = await _firestore.collection('users').count().get();
      final totalCustomers = customersSnap.count ?? 0;

      // Get total staff
      final staffSnap = await _firestore.collection('staff').count().get();
      final totalStaff = staffSnap.count ?? 0;

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
      final vehiclesSnap = await _firestore
          .collection('vehicles')
          .where('customerId', isEqualTo: customerId)
          .count().get();
      final myVehicles = vehiclesSnap.count ?? 0;

      // Get active tickets
      final activeSnap = await _firestore
          .collection('repair_tickets')
          .where('customerId', isEqualTo: customerId)
          .where('status', whereIn: ['received', 'waiting', 'repairing']).count().get();
      final activeTickets = activeSnap.count ?? 0;

      // Get completed tickets
      final completedSnap = await _firestore
          .collection('repair_tickets')
          .where('customerId', isEqualTo: customerId)
          .where('status', isEqualTo: 'completed').count().get();
      final completedTickets = completedSnap.count ?? 0;

      // Get total spent
      final paymentsSnap = await _firestore
          .collection('payments')
          .where('customerId', isEqualTo: customerId)
          .where('status', isEqualTo: 'success')
          .get();
      double totalSpent = 0;
      for (var doc in paymentsSnap.docs) {
        totalSpent += (doc['amount'] as num?)?.toDouble() ?? 0;
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
