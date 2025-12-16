import 'package:flutter/material.dart';
import '../models/RepairTicket.dart';

class RepairTicketsProvider extends ChangeNotifier {
  List<RepairTicket> _allTickets = [];
  List<RepairTicket> _customerTickets = [];
  bool _isLoading = false;
  
  List<RepairTicket> get allTickets => _allTickets;
  List<RepairTicket> get customerTickets => _customerTickets;
  bool get isLoading => _isLoading;

  RepairTicketsProvider() {
    _mockLoadAllTickets();
  }

  void _mockLoadAllTickets() {
    _allTickets = [
      RepairTicket(
        id: 'T001',
        vehicleId: '51A-12345',
        customerId: 'c1',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        serviceIds: ['sv1', 'sv2'],
        status: 'completed',
        totalCost: 1500000,
        assignedStaffId: 's1', 
        partsUsed: [],
      ),
      RepairTicket(
        id: 'T002',
        vehicleId: '29B-98765',
        customerId: 'c2',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        serviceIds: ['sv3'],
        status: 'waiting',
        totalCost: 800000,
        assignedStaffId: null, 
        partsUsed: [],
      ),
      RepairTicket(
        id: 'T003',
        vehicleId: '51C-67890',
        customerId: 'c1',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        serviceIds: ['sv1'],
        status: 'received',
        totalCost: 50000,
        assignedStaffId: null,
        partsUsed: [],
      ),
    ];
  }

  Future<void> loadAllTickets() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 300));
    _mockLoadAllTickets();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCustomerTickets() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500)); 
    _customerTickets = _allTickets.where((t) => t.customerId == 'c1').toList();
    _customerTickets.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateTicket(RepairTicket updatedTicket) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _allTickets.indexWhere((t) => t.id == updatedTicket.id);
    if (index != -1) {
      _allTickets[index] = updatedTicket;
      await loadCustomerTickets(); 
      notifyListeners();
      return true;
    }
    return false;
  }

  Map<String, double> getReportOverview() {
    final completedTickets = _allTickets.where((t) => ['completed', 'delivered'].contains(t.status)).toList();
    double totalRevenue = completedTickets.fold(0.0, (sum, t) => sum + t.totalCost);
    double netProfit = totalRevenue * 0.7;
    double profitMargin = totalRevenue > 0 ? (netProfit / totalRevenue) * 100 : 0;

    return {
      'totalRevenue': totalRevenue,
      'totalCogs': totalRevenue * 0.3,
      'netProfit': netProfit,
      'profitMargin': profitMargin,
    };
  }
}