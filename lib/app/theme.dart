import 'package:flutter/material.dart';

const _green = Color(0xFF1A3A2A);
const _cream = Color(0xFFF5F0E8);
const _amber = Color(0xFFD4A853);

final zenvlogTheme = ThemeData(
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: _green,
    secondary: _amber,
    surface: Color(0xFF243D30),
    onPrimary: _cream,
    onSecondary: _green,
    onSurface: _cream,
  ),
  scaffoldBackgroundColor: _green,
  cardColor: _cream,
  textTheme: const TextTheme(
    headlineLarge: TextStyle(color: _cream, fontWeight: FontWeight.w700, fontSize: 28),
    headlineMedium: TextStyle(color: _cream, fontWeight: FontWeight.w600, fontSize: 22),
    bodyLarge: TextStyle(color: _cream, fontSize: 16),
    bodyMedium: TextStyle(color: _cream, fontSize: 14),
    labelLarge: TextStyle(color: _cream, fontWeight: FontWeight.w600),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _amber,
      foregroundColor: _green,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: _green,
    selectedItemColor: _amber,
    unselectedItemColor: _cream,
    type: BottomNavigationBarType.fixed,
  ),
);
