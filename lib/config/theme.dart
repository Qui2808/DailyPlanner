import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF7DABF6),
    surface: Color(0xFFF9FFFF),
    surfaceContainer: Color(0xFFF4F9FC),
    surfaceBright: Colors.white,
    secondary: Color(0xFF4784AE),
    tertiary: Color(0xFF9FA1A2),
  ),
  // textTheme: TextTheme(
  //   bodyMedium: TextStyle()
  // ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF7DABF6),
    surface: Color(0xFF35343C),
    surfaceContainer: Color(0xFF393840),
    surfaceBright: Colors.black87,
    secondary: Color(0xFF4784AE),
    tertiary: Color(0xFF9FA1A2),
  ),
);