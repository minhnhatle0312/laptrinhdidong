import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Payment.dart';

class PaymentsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
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
      final snapshot = await _firestore
          .collection('payments')
          .orderBy('createdAt', descending: true)
          .get();
      _payments = snapshot.docs
          .map((doc) => Payment.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
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
      final snapshot = await _firestore
          .collection('payments')
          .where('customerId', isEqualTo: customerId)
          .orderBy('createdAt', descending: true)
          .get();
      _customerPayments = snapshot.docs
          .map((doc) => Payment.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
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
      await _firestore.collection('payments').doc(payment.id).set(payment.toJson());
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
        if (status == 'success') 'paidAt': now,
      };
      
      await _firestore.collection('payments').doc(paymentId).update(updateData);
      
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
      final snapshot = await _firestore
          .collection('payments')
          .where('ticketId', isEqualTo: ticketId)
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return Payment.fromJson({...snapshot.docs[0].data(), 'id': snapshot.docs[0].id});
      }
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
}
