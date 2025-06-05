import 'package:flutter/material.dart';
import 'package:forklift_mobile/screens/auth/masuk.dart';
import 'package:forklift_mobile/screens/splash_screen.dart';
import 'package:forklift_mobile/theme/app_theme.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:forklift_mobile/screens/user/about.dart';
import 'package:forklift_mobile/screens/user/order_history.dart';
import 'package:upgrader/upgrader.dart';

/// Fungsi utama yang dijalankan saat aplikasi dimulai
/// Menginisialisasi binding Flutter dan format tanggal Indonesia
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

/// Widget utama aplikasi yang mendefinisikan tema dan rute
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forklift Rental',
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const Masuk(),
        '/about': (context) => const About(),
        '/order-history': (context) => const OrderHistory(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
