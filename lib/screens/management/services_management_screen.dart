// screens/management/services_management_screen.dart (TẠO MỚI)

import 'package:flutter/material.dart';

class ServicesManagementScreen extends StatelessWidget {
  const ServicesManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Sử dụng ServicesProvider để lấy danh sách Dịch vụ
    return Scaffold(
      appBar: AppBar(
        title: const Text('QL Dịch vụ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Điều hướng đến màn hình Add/Edit Dịch vụ
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Danh sách Dịch vụ sẽ hiển thị ở đây.'),
      ),
    );
  }
}