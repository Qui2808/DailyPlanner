import 'package:daily_planner/config/theme.dart';
import 'package:daily_planner/config/theme_provider.dart';
import 'package:daily_planner/page/home_page.dart';
import 'package:daily_planner/page/login_page.dart';
import 'package:daily_planner/view_model/app_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Đảm bảo rằng mọi thứ đã được khởi tạo
  await _initializeNotifications(); // Khởi tạo thông báo

  runApp( MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => AppViewModel()),
    ],
    child: const MyApp())
  );
}


Future<void> _initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // Icon cho thông báo

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, provider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightMode,
          darkTheme: darkMode,
          themeMode: provider.themeMode,
          home: LoginScreen(),
        );
      }
    );
  }
}

