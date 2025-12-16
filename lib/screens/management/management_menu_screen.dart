import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/animated_scaffold.dart';

class ManagementMenuScreen extends StatelessWidget {
  const ManagementMenuScreen({super.key});

  // Tối ưu hóa UI: Thẻ nổi bật hơn với BoxShadow và màu sắc động
  Widget _buildManagementCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
    required Color color, // THÊM THAM SỐ MÀU SẮC
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Quản lý chi tiết',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScaffold(
      title: 'Menu Quản lý',
      automaticallyImplyLeading: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildManagementCard(
              context,
              title: 'Quản lý Xe',
              icon: Icons.directions_car,
              route: '/manage/vehicles',
              color: Colors.indigo,
            ),
            _buildManagementCard(
              context,
              title: 'Quản lý Khách hàng',
              icon: Icons.people,
              route: '/manage/customers',
              color: Colors.blue,
            ),
            _buildManagementCard(
              context,
              title: 'Quản lý Nhân viên',
              icon: Icons.engineering,
              route: '/manage/staff',
              color: Colors.orange,
            ),
            _buildManagementCard(
              context,
              title: 'Quản lý Dịch vụ',
              icon: Icons.miscellaneous_services,
              route: '/manage/services',
              color: Colors.green,
            ),
            _buildManagementCard( // THÊM MỚI
              context,
              title: 'Quản lý Phụ tùng',
              icon: Icons.inventory_2,
              route: '/manage/parts', 
              color: Colors.brown,
            ),
            _buildManagementCard(
              context,
              title: 'Quản lý Bãi đỗ',
              icon: Icons.location_on,
              route: '/manage/parking',
              color: Colors.teal,
            ),
            _buildManagementCard(
              context,
              title: 'Bản đồ bãi giữ xe',
              icon: Icons.map,
              route: '/map-parking',
              color: Colors.lightBlueAccent,
            ),
            _buildManagementCard(
              context,
              title: 'Báo cáo chi tiêu',
              icon: Icons.money_off,
              route: '/manage/expenses',
              color: Colors.pink,
            ),
            _buildManagementCard(
              context,
              title: 'Báo cáo',
              icon: Icons.analytics,
              route: '/manage', // Tạm thời quay lại menu
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}