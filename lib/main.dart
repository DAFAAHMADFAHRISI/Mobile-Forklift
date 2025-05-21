import 'package:flutter/material.dart';
import 'package:forklift_mobile/screens/auth/daftar.dart';
import 'package:forklift_mobile/screens/splash_screen.dart';
import 'package:forklift_mobile/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

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
        '/home': (context) => Daftar(), // Ganti dengan halaman utama Anda
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
