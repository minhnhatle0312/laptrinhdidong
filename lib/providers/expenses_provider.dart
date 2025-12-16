import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/expense.dart';

class ExpensesProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  final _database = FirebaseDatabase.instance.ref().child('expenses');

  List<Expense> get expenses => List.unmodifiable(_expenses);

  Future<void> fetchExpenses() async {
    try {
      final snapshot = await _database.orderByChild('date').get();
      _expenses.clear();
      if (snapshot.exists) {
        final expensesMap = Map<String, dynamic>.from(snapshot.value as Map);
        final expenseList = <Expense>[];
        expensesMap.forEach((key, value) {
          final data = Map<String, dynamic>.from(value);
          data['id'] = key;
          expenseList.add(Expense.fromJson(data));
        });
        // Sort by date descending
        expenseList.sort((a, b) => b.date.compareTo(a.date));
        _expenses.addAll(expenseList);
      }
      notifyListeners();
    } catch (e) {
      print('Error fetching expenses: $e');
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      await _database.child(expense.id).set(expense.toJson());
      _expenses.insert(0, expense);
      notifyListeners();
    } catch (e) {
      print('Error adding expense: $e');
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      await _database.child(expense.id).update(expense.toJson());
      final idx = _expenses.indexWhere((e) => e.id == expense.id);
      if (idx != -1) {
        _expenses[idx] = expense;
        notifyListeners();
      }
    } catch (e) {
      print('Error updating expense: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _database.child(id).remove();
      _expenses.removeWhere((e) => e.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting expense: $e');
    }
  }

  double get totalExpense => _expenses.fold(0, (sum, e) => sum + e.amount);

  Map<String, double> get expenseByCategory {
    final map = <String, double>{};
    for (var e in _expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }

  Future<String?> uploadExpenseImage(File file, String expenseId) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('expenses/$expenseId/${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }
}
