import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu') ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => context.go('/dashboard'),
              icon: const Icon(Icons.dashboard),
              label: const Text('Dashboard'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/parking'),
              icon: const Icon(Icons.local_parking),
              label: const Text('Danh sách Bãi xe'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/map'),
              icon: const Icon(Icons.map),
              label: const Text('Bản đồ'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/vehicles'), 
              icon: const Icon(Icons.directions_car),
              label: const Text('Xe của tôi'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/transactions'),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Giao dịch'),
            ),
            const SizedBox(height: 12),
            // THÊM: Nút điều hướng đến Menu Quản lý
            ElevatedButton.icon(
              onPressed: () => context.go('/manage'),
              icon: const Icon(Icons.business),
              label: const Text('Menu Quản lý'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => context.go('/settings'),
              icon: const Icon(Icons.settings),
              label: const Text('Cài đặt'),
            ),
          ],
        ),
      ),
    );
  }
}