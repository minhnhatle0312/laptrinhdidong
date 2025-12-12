import 'package:flutter/material.dart';
import '../models/transaction_record.dart';

class TransactionsProvider extends ChangeNotifier {
  final List<TransactionRecord> _transactions = [];

  List<TransactionRecord> get transactions => List.unmodifiable(_transactions);

  void addTransaction(TransactionRecord t) {
    _transactions.insert(0, t);
    notifyListeners();
  }
}
