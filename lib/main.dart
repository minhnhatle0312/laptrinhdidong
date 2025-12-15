import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'router.dart';
import 'firebase_options.dart';
import 'providers/providers.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
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
        ChangeNotifierProvider(create: (_) => VehiclesProvider()),
        ChangeNotifierProvider(create: (_) => TransactionsProvider()),
      ],
      child: MaterialApp.router(
        title: 'Quản lý Gara & Bãi xe',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
            centerTitle: false,
            elevation: 1,
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}