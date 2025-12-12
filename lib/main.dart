import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'router.dart';

// Imports cho Providers và Services
import 'providers/providers.dart';
import 'services/api_service.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If you want to initialize Firebase, uncomment and configure Firebase options
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  final ApiService? api;
  final SettingsProvider? settings;

  const MyApp({super.key, this.api, this.settings});

  @override
  Widget build(BuildContext context) {
    // Create instances lazily if not provided (useful for tests)
    final apiLocal = api ?? ApiService();
    final settingsLocal = settings ?? SettingsProvider(apiLocal);

    // If settings was not provided externally, try to load saved config
    if (settings == null) {
      // Fire-and-forget load (will notify listeners when complete)
      Future.microtask(() => settingsLocal.load());
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsLocal),
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
