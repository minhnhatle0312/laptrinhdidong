// File: lib/screens/vehicle/vehicle_list_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_application/models/vehicle.dart';
import 'package:flutter_application/services/vehicle_firestore.dart';
import 'package:flutter_application/screens/vehicle/vehicle_history_screen.dart';

class VehicleListScreen extends StatelessWidget {
  const VehicleListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = VehicleFirestore();

    // BẮT BUỘC PHẢI CÓ SCAFFOLD Ở ĐÂY (VÌ ĐÃ XÓA BÊN ROUTER)
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Màu nền xám nhẹ sang trọng
      
      // 1. THANH TIÊU ĐỀ (APP BAR)
      appBar: AppBar(
        title: const Text('Danh sách phương tiện', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black, // Màu chữ và nút Back màu đen
      ),

      // 2. NÚT THÊM XE (FLOATING ACTION BUTTON)
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vehicle_form'),
        label: const Text('Thêm xe'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        elevation: 4,
      ),

      // 3. NỘI DUNG CHÍNH
      body: StreamBuilder<List<Vehicle>>(
        stream: firestore.getVehicles(),
        builder: (context, snapshot) {
          // Trạng thái Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Trạng thái Trống
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.directions_car_outlined,
                        size: 64, color: Colors.blue[300]),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có phương tiện nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final vehicles = snapshot.data!;

          // Danh sách xe
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: vehicles.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final v = vehicles[index];
              final isLinked = v.customerId != null;

              return Card(
                elevation: 0, // Phẳng, hiện đại hơn
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200), // Viền nhẹ
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => context.push('/vehicle_form', extra: v),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // --- ICON XE ---
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.directions_car_filled,
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
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  // Biển số (Style như cái tag)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Text(
                                      v.plateNumber,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.black87,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Icon liên kết khách hàng
                                  if (isLinked)
                                    Row(
                                      children: [
                                        Icon(Icons.person, size: 14, color: Colors.green[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Đã gán chủ',
                                          style: TextStyle(fontSize: 11, color: Colors.green[700]),
                                        )
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // --- NÚT CHỨC NĂNG NHỎ ---
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.history, color: Colors.orange),
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
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}