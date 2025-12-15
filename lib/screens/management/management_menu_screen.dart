import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ManagementMenuScreen extends StatelessWidget {
  const ManagementMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Quản lý'),
        // Loại bỏ nút Back vì đây là điểm gốc của ShellRoute item 2
        automaticallyImplyLeading: false, 
      ),
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
              route: '/manage/cars',
            ),
            _buildManagementCard(
              context,
              title: 'Quản lý Khách hàng',
              icon: Icons.people,
              route: '/manage/customers',
            ),
            _buildManagementCard(
              context,
              title: 'Quản lý Nhân viên',
              icon: Icons.engineering,
              route: '/manage/staff',
            ),
            _buildManagementCard(
              context,
              title: 'Quản lý Dịch vụ',
              icon: Icons.miscellaneous_services,
              route: '/manage/services',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManagementCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required String route,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // Dùng context.go để thay thế màn hình trong ShellRoute
        onTap: () => context.go(route), 
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Theme.of(context).primaryColor),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}