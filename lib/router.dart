import 'package:flutter/material.dart';
import 'package:flutter_application/models/position.dart';
import 'package:flutter_application/screens/auth/login_screen.dart';
import 'package:flutter_application/screens/auth/register_screen.dart';
import 'package:flutter_application/screens/dashboard_screens/dashboard_screen.dart';
import 'package:flutter_application/screens/services/service_form_screen.dart';
import 'package:flutter_application/screens/staff/staff_form_screen.dart';
import 'package:flutter_application/screens/customer/customer_form_screen.dart';
import 'package:flutter_application/screens/staff_positions/position_form_screen.dart';
import 'package:flutter_application/screens/task_assignment/task_assignment_list_screen.dart';
import 'screens/staff_positions/position_list_screen.dart';
import 'package:flutter_application/screens/vehicle/vehicle_form_screen.dart';
import 'package:flutter_application/screens/customer/customer_list_screen.dart';
import 'package:flutter_application/screens/vehicle/vehicle_list_screen.dart';
import 'package:flutter_application/screens/reception/reception_list_screen.dart';
import 'package:flutter_application/screens/reception/reception_form_screen.dart';
import 'package:flutter_application/models/customer.dart';
import 'package:flutter_application/models/vehicle.dart';
import 'package:flutter_application/models/service.dart';
import 'package:flutter_application/models/staff.dart';
import 'package:flutter_application/models/reception.dart';
import 'package:go_router/go_router.dart';

// --- BỔ SUNG IMPORT CHO PRODUCT ---
import 'package:flutter_application/models/product.dart';
import 'package:flutter_application/screens/inventory/product_list_screen.dart';
import 'package:flutter_application/screens/inventory/product_form_screen.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/service_form',
        builder: (context, state) =>
            ServiceFormScreen(service: state.extra as Service?),
      ),
      GoRoute(
        path: '/staff_form',
        builder: (context, state) =>
            StaffFormScreen(staff: state.extra as Staff?),
      ),
      GoRoute(
        path: '/customer_form',
        builder: (context, state) =>
            CustomerFormScreen(customer: state.extra as Customer?),
      ),
      GoRoute(
        path: '/vehicle_form',
        builder: (context, state) =>
            VehicleFormScreen(vehicle: state.extra as Vehicle?),
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Khách hàng')),
          body: const CustomerListScreen(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/customer_form'),
            child: const Icon(Icons.add),
          ),
        ),
      ),
      GoRoute(
        path: '/vehicles',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Phương tiện')),
          body: const VehicleListScreen(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/vehicle_form'),
            child: const Icon(Icons.add),
          ),
        ),
      ),
      GoRoute(
        path: '/receptions',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Phiếu tiếp nhận')),
          body: ReceptionListScreen(),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.push('/reception_form'),
            child: const Icon(Icons.add),
          ),
        ),
      ),
      GoRoute(
        path: '/reception_form',
        builder: (context, state) =>
            ReceptionFormScreen(reception: state.extra as Reception?),
      ),
      GoRoute(
        path: '/positions',
        builder: (context, state) => const PositionListScreen(),
      ),
      GoRoute(
        path: '/position_form',
        builder: (context, state) {
          final position = state.extra as Position?;
          return PositionFormScreen(position: position);
        },
      ),
      GoRoute(
        path: '/task-assignments',
        builder: (context, state) => const TaskAssignmentListScreen(),
      ),
      GoRoute(
        path: '/task-assignments/:receptionId',
        builder: (context, state) {
          final receptionId = state.pathParameters['receptionId'];
          return TaskAssignmentListScreen(receptionId: receptionId);
        },
      ),

      // --- BỔ SUNG ROUTE CHO PRODUCT ---
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductListScreen(),
      ),
      GoRoute(
        path: '/product_form',
        builder: (context, state) {
          final product = state.extra as Product?;
          return ProductFormScreen(product: product);
        },
      ),
    ],
  );
}