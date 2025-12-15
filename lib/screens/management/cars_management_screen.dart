// screens/management/cars_management_screen.dart (TẠO MỚI)

import 'package:flutter/material.dart';

class CarsManagementScreen extends StatelessWidget {
  const CarsManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Sử dụng CarsProvider để lấy danh sách Car
    return Scaffold(
      appBar: AppBar(
        title: const Text('QL Xe (Car)'),
        automaticallyImplyLeading: false, // Loại bỏ nút back
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              // TODO: Điều hướng đến màn hình Add/Edit Car
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Danh sách Xe sẽ hiển thị ở đây.'),
            // TODO: ListView.builder để hiển thị danh sách
          ],
        ),
      ),
    );
  }
}