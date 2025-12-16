import 'screens/map_parking_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Imports cho Providers
import 'providers/auth_provider.dart';

// Imports cho các màn hình
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/user_dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/repairs_screen.dart';
import 'screens/payments_history_screen.dart';
import 'screens/dashboard_placeholder.dart';

// Imports cho màn hình quản lý 
import 'screens/management/management_menu_screen.dart'; 
import 'screens/vehicles_management_screen.dart';
import 'screens/customers_management_screen.dart';
import 'screens/management/staff_management_screen.dart'; 
import 'screens/services_management_screen.dart';
import 'screens/parking_management_screen.dart';
import 'screens/expenses_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  
  // Logic Redirect Bảo vệ Tuyến đường
  redirect: (context, state) {
    final auth = Provider.of<AuthProvider>(context, listen: false); 
    final loggedIn = auth.isAuthenticated;
    final isLoggingInOrResetting =
        state.uri.path == '/login' || 
        state.uri.path == '/register';

    if (!loggedIn && !isLoggingInOrResetting) return '/login'; 
    if (loggedIn && isLoggingInOrResetting) return '/dashboard';
    return null; 
  },
  
  routes: [
    // Tuyến đường Auth
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/register', builder: (context, state) => const RegisterScreen()),
    
    // Tuyến đường Chính (Dùng ShellRoute + Bottom Bar)
    ShellRoute(
      builder: (context, state, child) => HomeScreen(child: child),
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) {
            final auth = Provider.of<AuthProvider>(context);
            final role = auth.userRole ?? 'user';
            if (role == 'admin') return const AdminDashboardScreen();
            if (role == 'staff') return const DashboardPlaceholderScreen(title: 'Bảng điều khiển Nhân viên');
            return const UserDashboardScreen();
          },
        ),
        GoRoute(
          path: '/manage',
          builder: (context, state) => const ManagementMenuScreen(),
        ),
      ],
    ),
    
    // Các màn hình Phụ
    GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    GoRoute(path: '/transactions', builder: (context, state) => const TransactionsScreen()),
    GoRoute(path: '/repairs', builder: (context, state) => const RepairsScreen()),
    GoRoute(path: '/payments-history', builder: (context, state) => const PaymentsHistoryScreen()),

    // Các màn hình Quản lý
    GoRoute(path: '/manage/vehicles', builder: (context, state) => const VehiclesManagementScreen()),
    GoRoute(path: '/manage/customers', builder: (context, state) => const CustomersManagementScreen()),
    GoRoute(path: '/manage/staff', builder: (context, state) => const StaffManagementScreen()),
    GoRoute(path: '/manage/services', builder: (context, state) => const ServicesManagementScreen()),
    GoRoute(path: '/manage/expenses', builder: (context, state) => const ExpensesScreen()),
    GoRoute(path: '/manage/parts', builder: (context, state) => Scaffold(appBar: AppBar(title: const Text('Quản lý Phụ tùng')), body: Center(child: Text('Phụ tùng - Đang phát triển...')))),
    GoRoute(path: '/manage/reports', builder: (context, state) => Scaffold(appBar: AppBar(title: const Text('Báo cáo')), body: Center(child: Text('Báo cáo - Đang phát triển...')))),
    GoRoute(path: '/manage/parking', builder: (context, state) => const ParkingLocationsManagementScreen()),
    GoRoute(path: '/map-parking', builder: (context, state) => const MapParkingScreen()),
  ],
);