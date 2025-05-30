import 'package:flutter/material.dart';

class AdminTheme {
  static const Color primaryDark = Color(0xFF1A1D29);
  static const Color deepPurple = Color(0xFF2D1B69);
  static const Color accentPink = Color(0xFFE91E63);
  static const Color accentPurple = Color(0xFF9C27B0);
  static const Color lightGray = Color(0xFFF8F9FA);

  static const BoxDecoration backgroundGradient = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        primaryDark,
        deepPurple,
        accentPurple,
      ],
    ),
  );

  static BoxDecoration cardBox = BoxDecoration(
    color: lightGray,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );

  static TextStyle appBarTitle = const TextStyle(
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
    color: Colors.white,
    fontSize: 20,
  );

  static TextStyle cardTitle = const TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
    color: primaryDark,
  );

  static TextStyle cardSubtitle = const TextStyle(
    color: Colors.black87,
    fontSize: 14,
  );
}
