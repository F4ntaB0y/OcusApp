import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/theme/app_colors.dart';
import 'features/timer/controller/timer_controller.dart';
import 'features/tasks/controller/task_controller.dart';
import 'features/profile/controller/profile_controller.dart';
import 'home_page.dart';
import 'core/notifications/notification_service.dart';

Future<void> _requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (status.isDenied || status.isRestricted || status.isLimited) {
    await Permission.notification.request();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestNotificationPermission();
  await initializeDateFormatting('id_ID', null);
  await NotificationService.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimerController()),
        ChangeNotifierProvider(create: (_) => TaskController()),
        ChangeNotifierProvider(create: (_) => ProfileController()),
      ],
      child: const FocusApp(),
    ),
  );
}

class FocusApp extends StatelessWidget {
  const FocusApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita tidak perlu lagi Consumer<ProfileController> di sini untuk tema
    return MaterialApp(
      title: 'Ocus',
      debugShowCheckedModeBanner: false,
      // PERBAIKAN: Memaksa menggunakan Tema Gelap sebagai default
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: AppColors.primarySwatch,
        scaffoldBackgroundColor: AppColors.background,
        cardColor: Colors.grey.shade900,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppColors.text),
          bodyMedium: TextStyle(color: AppColors.text),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.text,
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}
