import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import '../models/Payment.dart';

class PaymentsProvider extends ChangeNotifier {
  final _database = FirebaseDatabase.instance.ref().child('payments');
  
  List<Payment> _payments = [];
  List<Payment> _customerPayments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Payment> get payments => _payments;
  List<Payment> get customerPayments => _customerPayments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Load all payments (Admin)
  Future<void> loadAllPayments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _database.get();
      _payments = [];
      if (snapshot.exists) {
        final paymentsMap = Map<String, dynamic>.from(snapshot.value as Map);
        final paymentsList = <Payment>[];
        paymentsMap.forEach((key, value) {
          final data = Map<String, dynamic>.from(value);
          data['id'] = key;
          paymentsList.add(Payment.fromJson(data));
        });
        // Sort by createdAt descending
        paymentsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _payments = paymentsList;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Alias for loadAllPayments
  Future<void> loadPayments() async => await loadAllPayments();

  /// Load customer payments
  Future<void> loadCustomerPayments(String customerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _database.orderByChild('customerId').equalTo(customerId).get();
      _customerPayments = [];
      if (snapshot.exists) {
        final paymentsMap = Map<String, dynamic>.from(snapshot.value as Map);
        final paymentsList = <Payment>[];
        paymentsMap.forEach((key, value) {
          final data = Map<String, dynamic>.from(value);
          data['id'] = key;
          paymentsList.add(Payment.fromJson(data));
        });
        // Sort by createdAt descending
        paymentsList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        _customerPayments = paymentsList;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create payment
  Future<bool> createPayment(Payment payment) async {
    try {
      await _database.child(payment.id).set(payment.toJson());
      _payments.add(payment);
      _customerPayments.add(payment);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Update payment status
  Future<bool> updatePaymentStatus(String paymentId, String status) async {
    try {
      final now = DateTime.now();
      final updateData = {
        'status': status,
        if (status == 'success') 'paidAt': now.toIso8601String(),
      };
      
      await _database.child(paymentId).update(updateData);
      
      // Update local state
      final index = _payments.indexWhere((p) => p.id == paymentId);
      if (index >= 0) {
        final payment = _payments[index];
        _payments[index] = Payment(
          id: payment.id,
          ticketId: payment.ticketId,
          customerId: payment.customerId,
          amount: payment.amount,
          method: payment.method,
          status: status,
          createdAt: payment.createdAt,
          paidAt: status == 'success' ? now : payment.paidAt,
          notes: payment.notes,
        );
      }
      
      final customerIndex = _customerPayments.indexWhere((p) => p.id == paymentId);
      if (customerIndex >= 0) {
        final payment = _customerPayments[customerIndex];
        _customerPayments[customerIndex] = Payment(
          id: payment.id,
          ticketId: payment.ticketId,
          customerId: payment.customerId,
          amount: payment.amount,
          method: payment.method,
          status: status,
          createdAt: payment.createdAt,
          paidAt: status == 'success' ? now : payment.paidAt,
          notes: payment.notes,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get payments by status
  List<Payment> getPaymentsByStatus(String status) {
    return _payments.where((p) => p.status == status).toList();
  }

  /// Get payment by ticket
  Future<Payment?> getPaymentByTicket(String ticketId) async {
    try {
      final snapshot = await _database.orderByChild('ticketId').equalTo(ticketId).get();
      if (snapshot.exists) {
        final paymentsMap = Map<String, dynamic>.from(snapshot.value as Map);
        if (paymentsMap.isNotEmpty) {
          final firstKey = paymentsMap.keys.first;
          final data = Map<String, dynamic>.from(paymentsMap[firstKey]);
          data['id'] = firstKey;
          return Payment.fromJson(data);
        }
      }
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
