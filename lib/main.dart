import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'router.dart';
import 'firebase_options.dart';
import 'providers/providers.dart';
import 'theme.dart';
import 'services/api_service.dart';
import 'utils/firebase_init_sample_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize sample data on first launch
    try {
      await FirebaseInitSampleData.initializeAll();
    } catch (e) {
      debugPrint('Sample data initialization warning: $e');
    }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService? api;
  final SettingsProvider? settings;

  const MyApp({super.key, this.api, this.settings});

  @override
  Widget build(BuildContext context) {
    final apiLocal = api ?? ApiService();
    final settingsLocal = settings ?? SettingsProvider(apiLocal);

    if (settings == null) {
      Future.microtask(() => settingsLocal.load());
    }
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsLocal),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
          create: (_) => ParkingProvider(apiService: apiLocal),
        ),
        ChangeNotifierProvider(
          create: (_) => VehiclesProvider(apiService: apiLocal), 
        ),
        ChangeNotifierProvider(create: (_) => TransactionsProvider()),
        ChangeNotifierProvider(create: (_) => ServicesProvider()),
        ChangeNotifierProvider(create: (_) => RepairTicketsProvider()),
        ChangeNotifierProvider(create: (_) => PaymentsProvider()),
        ChangeNotifierProvider(create: (_) => ParkingBaysProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
        ChangeNotifierProvider(create: (_) => CustomersProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
      ],
        child: MaterialApp.router(
          title: 'Quản lý Gara & Bãi xe',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme(),
          routerConfig: appRouter,
        ),
    );
  }
}