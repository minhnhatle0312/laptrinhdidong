import 'package:flutter/material.dart';
import '../../models/reception.dart';
import '../../services/reception_firestore.dart';
import '../../services/revenue_firestore.dart';

class DashboardController extends ChangeNotifier {
  int currentIndex = 0;
  final ReceptionFirestore _receptionService = ReceptionFirestore();
  final RevenueFirestore _revenueService = RevenueFirestore();

  void setIndex(int index) {
    currentIndex = index;
    notifyListeners();
  }

  Stream<List<Reception>> get receptionsStream => _receptionService.getReceptions();
  Future<double> get todayRevenueFuture => _revenueService.getTodayRevenue();

  // Logic đếm số lượng
  int countTodayReceptions(List<Reception> receptions) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return receptions.where((r) {
      final createdDate = DateTime(r.createdAt.year, r.createdAt.month, r.createdAt.day);
      return createdDate.isAtSameMomentAs(today);
    }).length;
  }

  int countCarsInShop(List<Reception> receptions) {
    return receptions.where((r) => r.status == 'pending' || r.status == 'in_progress').length;
  }

  int countProcessing(List<Reception> receptions) {
    return receptions.where((r) => r.status == 'in_progress').length;
  }

  List<Reception> getActiveReceptions(List<Reception> receptions) {
    return receptions
        .where((r) => r.status == 'pending' || r.status == 'in_progress')
        .take(5)
        .toList();
  }

  List<Map<String, dynamic>> getWarnings(List<Reception> receptions) {
    final warnings = <Map<String, dynamic>>[];
    // Phiếu chờ > 30 phút
    final longWaiting = receptions.where((r) {
      if (r.status != 'pending') return false;
      return DateTime.now().difference(r.createdAt).inMinutes > 30;
    }).length;

    if (longWaiting > 0) {
      warnings.add({
        'title': 'Phiếu chờ lâu',
        'message': '$longWaiting phiếu chờ > 30 phút',
        'color': const Color(0xFFFF9F43), // Cam đậm
        'bg_color': const Color(0xFFFFF2E2),
        'icon': Icons.timer_off_outlined,
      });
    }

    // Xe sửa > 2 giờ
    final longProcessing = receptions.where((r) {
      if (r.status != 'in_progress') return false;
      return DateTime.now().difference(r.createdAt).inHours > 2;
    }).length;

    if (longProcessing > 0) {
      warnings.add({
        'title': 'Cảnh báo tiến độ',
        'message': '$longProcessing xe sửa > 2 giờ',
        'color': const Color(0xFFEE5253), // Đỏ
        'bg_color': const Color(0xFFFFE5E5),
        'icon': Icons.warning_amber_rounded,
      });
    }
    return warnings;
  }

  // Formatters
  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng';
    if (hour < 18) return 'Chào buổi chiều';
    return 'Chào buổi tối';
  }

  String formatDate(DateTime date) {
    final days = ['CN', 'Th 2', 'Th 3', 'Th 4', 'Th 5', 'Th 6', 'Th 7'];
    return '${days[date.weekday % 7]}, ${date.day}/${date.month}';
  }

  String formatMoneyShort(double amount) {
    if (amount >= 1000000000) return '${(amount / 1000000000).toStringAsFixed(1)}B';
    if (amount >= 1000000) return '${(amount / 1000000).toStringAsFixed(1)}M';
    if (amount >= 1000) return '${(amount / 1000).toStringAsFixed(0)}K';
    return amount.toStringAsFixed(0);
  }
}