// screens/management/customers_management_screen.dart (TẠO MỚI)

import 'package:flutter/material.dart';

class CustomersManagementScreen extends StatelessWidget {
  const CustomersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Sử dụng CustomersProvider để lấy danh sách Customer
    return Scaffold(
      appBar: AppBar(
        title: const Text('QL Khách hàng'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt),
            onPressed: () {
              // TODO: Điều hướng đến màn hình Add/Edit Customer
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Danh sách Khách hàng sẽ hiển thị ở đây.'),
      ),
    );
  }
}