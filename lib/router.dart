import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

// Imports cho Providers
import 'providers/auth_provider.dart';

// Imports cho Models
import 'models/parking_spot.dart'; 

// Imports cho các màn hình
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/main_menu.dart';
import 'screens/settings_screen.dart';
import 'screens/vehicles_screen.dart'; 
import 'screens/parking_list_screen.dart'; 
import 'screens/map_screen.dart'; 
import 'screens/transactions_screen.dart'; 
import 'screens/home_screen.dart'; // Màn hình chính bao quanh ShellRoute
import 'screens/reservation_screen.dart'; // Màn hình đặt chỗ
import 'screens/payment_screen.dart'; // Màn hình thanh toán

// Imports cho màn hình quản lý (Giả lập nếu bạn chưa có)
import 'screens/management/management_menu_screen.dart'; 
import 'screens/management/cars_management_screen.dart';
import 'screens/management/customers_management_screen.dart';
import 'screens/management/staff_management_screen.dart'; 
import 'screens/management/services_management_screen.dart';


final appRouter = GoRouter(
  initialLocation: '/login',
  
  // Logic Redirect Bảo vệ Tuyến đường
  redirect: (context, state) {
    // Đảm bảo Provider đã được khởi tạo
    final auth = Provider.of<AuthProvider>(context, listen: false); 
    final loggedIn = auth.isAuthenticated;
    final isLoggingIn =
        state.uri.path == '/login' || state.uri.path == '/register';

    if (!loggedIn && !isLoggingIn) return '/login'; // Chưa đăng nhập -> Login
    if (loggedIn && isLoggingIn) return '/dashboard'; // Đã đăng nhập -> Dashboard
    return null; // Tiếp tục đi đến tuyến đường mong muốn
  },
  
  routes: [
    // Tuyến đường Auth
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    
    // Tuyến đường Chính (Dùng ShellRoute + Bottom Bar)
    ShellRoute(
      builder: (context, state, child) => HomeScreen(child: child), // HomeScreen chứa Bottom Bar
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        // Menu quản lý chính (Điểm dừng cho BottomBar item 1)
        GoRoute(
          path: '/manage',
          builder: (context, state) => const ManagementMenuScreen(),
        ),
      ],
    ),
    
    // Các màn hình Phụ không có Bottom Bar
    GoRoute(path: '/menu', builder: (context, state) => const MainMenu()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/transactions',
      builder: (context, state) => const TransactionsScreen(),
    ),
    GoRoute(
      path: '/parking',
      builder: (context, state) => const ParkingListScreen(),
    ),
    GoRoute(path: '/map', builder: (context, state) => const MapScreen()),

    // Tuyến đường đặt chỗ (Nhận dữ liệu ParkingSpot qua 'extra')
    GoRoute(
      path: '/reserve',
      builder: (context, state) {
        final spot = state.extra as ParkingSpot?; 
        if (spot == null) {
          return const Center(child: Text('Lỗi: Không tìm thấy Bãi đỗ xe'));
        }
        return ReservationScreen(spot: spot);
      },
    ),
    // Tuyến đường thanh toán (Nhận số tiền qua 'extra')
    GoRoute(
      path: '/payment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?; 
        final amount = extra?['amount'] as double?;
        
        if (amount == null) {
          return const Center(child: Text('Lỗi: Thiếu thông tin thanh toán'));
        }
        return PaymentScreen(amount: amount);
      },
    ),

    // Các màn hình Quản lý chi tiết
    GoRoute( 
      path: '/vehicles', 
      builder: (context, state) => const VehiclesScreen(),
    ),
    GoRoute( 
      path: '/manage/cars', 
      builder: (context, state) => const CarsManagementScreen(), // Giả lập
    ),
    GoRoute(
      path: '/manage/customers',
      builder: (context, state) => const CustomersManagementScreen(), // Giả lập
    ),
    GoRoute(
      path: '/manage/staff',
      builder: (context, state) => const StaffManagementScreen(), // Giả lập
    ),
    GoRoute( 
      path: '/manage/services', 
      builder: (context, state) => const ServicesManagementScreen(), // Giả lập
    ),
  ],
);