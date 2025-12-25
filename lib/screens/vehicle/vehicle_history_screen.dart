import 'package:flutter/material.dart';
import 'package:flutter_application/models/reception.dart';
import 'package:flutter_application/services/reception_firestore.dart';

class VehicleHistoryScreen extends StatelessWidget {
  final String vehicleId;
  final String licensePlate;

  const VehicleHistoryScreen({
    super.key,
    required this.vehicleId,
    required this.licensePlate,
  });

  @override
  Widget build(BuildContext context) {
    final firestore = ReceptionFirestore();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Lịch sử sửa chữa', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text(licensePlate, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: StreamBuilder<List<Reception>>(
        stream: firestore.getReceptions(), // Lấy tất cả và lọc (đơn giản)
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) return const SizedBox();

          // Lọc ra các phiếu của xe này và đã hoàn thành
          final history = snapshot.data!
              .where((r) => r.vehicleId == vehicleId && r.status == 'done')
              .toList();

          // Sắp xếp mới nhất lên đầu
          history.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (history.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text('Xe này chưa có lịch sử sửa chữa', style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: history.length,
            itemBuilder: (context, index) {
              return _buildTimelineItem(history[index], index, history.length);
            },
          );
        },
      ),
    );
  }

  Widget _buildTimelineItem(Reception item, int index, int total) {
    final isFirst = index == 0;
    final isLast = index == total - 1;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline Line
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 2,
                  height: 20,
                  color: isFirst ? Colors.transparent : Colors.grey[300],
                ),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue.shade100, width: 3),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : Colors.grey[300],
                  ),
                ),
              ],
            ),
          ),
          
          // Card Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDate(item.createdAt),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          _formatMoney(item.totalPrice),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      'Dịch vụ đã làm:',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 4),
                    // Vì Reception model chỉ lưu serviceIds, ta tạm thời hiển thị số lượng
                    // Để hiển thị tên, cần map serviceIds với ServiceFirestore (nâng cao)
                    Text(
                      '• ${item.serviceIds.length} hạng mục dịch vụ',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• ${item.staffIds.length} kỹ thuật viên thực hiện',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatMoney(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')} đ';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}