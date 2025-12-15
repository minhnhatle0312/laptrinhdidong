// screens/management/staff_management_screen.dart (TẠO MỚI)

import 'package:flutter/material.dart';

class StaffManagementScreen extends StatelessWidget {
  const StaffManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Sử dụng StaffProvider để lấy danh sách Staff
    return Scaffold(
      appBar: AppBar(
        title: const Text('QL Nhân viên'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt),
            onPressed: () {
              // TODO: Điều hướng đến màn hình Add/Edit Staff
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Danh sách Nhân viên sẽ hiển thị ở đây.'),
      ),
    );
  }
}