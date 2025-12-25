// File: lib/screens/vehicle/vehicle_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/vehicle.dart';
import 'package:flutter_application/services/vehicle_firestore.dart';
// Import màn hình lịch sử (Đảm bảo bạn đã tạo file này theo hướng dẫn trước)
import 'package:flutter_application/screens/vehicle/vehicle_history_screen.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = VehicleFirestore();

    return StreamBuilder<List<Vehicle>>(
      stream: firestore.getVehicles(),
      builder: (context, snapshot) {
        // 1. Trạng thái Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2. Trạng thái Trống hoặc Lỗi
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.directions_car_outlined,
                      size: 64, color: Colors.blue[300]),
                ),
                const SizedBox(height: 16),
                Text(
                  'Chưa có phương tiện',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => context.push('/vehicle_form'),
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm xe ngay'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        final vehicles = snapshot.data!;

        // 3. Danh sách xe
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: vehicles.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final v = vehicles[index];
            final isLinked = v.customerId != null;

            return Card(
              elevation: 2,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push('/vehicle_form', extra: v),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // --- ICON ĐẠI DIỆN ---
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.directions_car,
                            color: Colors.blue, size: 28),
                      ),
                      const SizedBox(width: 16),

                      // --- THÔNG TIN XE ---
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${v.brand} ${v.model}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                // Biển số xe (Badge)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(4),
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: Text(
                                    v.plateNumber,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Trạng thái liên kết
                                if (isLinked)
                                  const Icon(Icons.link,
                                      size: 14, color: Colors.green),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // --- CÁC NÚT HÀNH ĐỘNG ---
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Nút Lịch sử (Mới thêm)
                          IconButton(
                            icon: const Icon(Icons.history,
                                color: Colors.orange),
                            tooltip: 'Xem lịch sử sửa chữa',
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => VehicleHistoryScreen(
                                    vehicleId: v.id,
                                    licensePlate: v.plateNumber,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Nút Xóa
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            tooltip: 'Xóa xe',
                            onPressed: () =>
                                _showDeleteDialog(context, firestore, v),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Hàm hiển thị hộp thoại xác nhận xóa
  void _showDeleteDialog(
      BuildContext context, VehicleFirestore firestore, Vehicle v) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa xe ${v.brand} ${v.model} '
            '(${v.plateNumber}) không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              firestore.deleteVehicle(v.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đã xóa phương tiện')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}