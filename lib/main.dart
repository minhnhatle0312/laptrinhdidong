import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'router.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'providers/providers.dart';
import 'theme.dart';
import 'services/api_service.dart';
import 'utils/firebase_init_sample_data.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // You can show a notification here if needed
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Sample data initialization disabled (using Realtime Database now)
    // try {
    //   await FirebaseInitSampleData.initializeAll();
    // } catch (e) {
    //   debugPrint('Sample data initialization warning: $e');
    // }
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Firebase Messaging setup
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Local notifications setup
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  final ApiService? api;
  final SettingsProvider? settings;

  const MyApp({super.key, this.api, this.settings});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initFCM();
  }

  void _initFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.requestPermission();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'Thông báo',
              channelDescription: 'Kênh thông báo mặc định',
              importance: Importance.max,
              priority: Priority.high,
              icon: '@mipmap/ic_launcher',
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final apiLocal = widget.api ?? ApiService();
    final settingsLocal = widget.settings ?? SettingsProvider(apiLocal);

    if (widget.settings == null) {
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
        ChangeNotifierProvider(create: (_) => ExpensesProvider()),
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