import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  // ShellRoute sẽ truyền tuyến đường con (child) vào đây
  final Widget child; 
  
  const HomeScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Lấy tuyến đường hiện tại để highlight icon
    final location = GoRouterState.of(context).uri.path;

    int getSelectedIndex(String path) {
      if (path == '/dashboard') return 0;
      // Nếu bắt đầu bằng /manage (bao gồm /manage/cars, /manage/customers,...)
      if (path.startsWith('/manage')) return 1; 
      return 0; 
    }

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.go('/dashboard');
          break;
        case 1:
          context.go('/manage'); // Chuyển đến Management Menu Screen
          break;
      }
    }

    return Scaffold(
      // Hiển thị nội dung của tuyến đường con
      body: child, 
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: getSelectedIndex(location),
        onTap: onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Tổng quan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build_circle),
            label: 'Quản lý',
          ),
        ],
      ),
    );
  }
}