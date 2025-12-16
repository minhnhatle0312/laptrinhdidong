// screens/dashboard_placeholder.dart

import 'package:flutter/material.dart';

/// Màn hình Dashboard đơn giản được sử dụng như một placeholder 
/// cho các vai trò khác (ví dụ: Staff Dashboard)
class DashboardPlaceholderScreen extends StatelessWidget {
  final String title;
  const DashboardPlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'Bảng điều khiển cho $title đang được xây dựng.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}