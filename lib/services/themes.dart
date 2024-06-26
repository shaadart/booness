// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme() {
  print("objectifying Theme...");
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF334EAC), // Royal
      brightness: Brightness.light,
      primary: Color(0xFF334EAC), // Royal
      secondary: Color(0xFFBAD6EB), // Sky
      tertiary: Color(0xFF7096D1), // China
      surface: Color(0xFFFFFFFF), // Porcelain (Pure white for contrast)
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
          color: Color(0xFF081F5C),
          fontSize: 36.0,
          fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(
        color: Color(0xFF081F5C),
      ),
      bodyMedium: TextStyle(color: Color(0xFF334EAC), fontSize: 16.0),
      titleMedium: TextStyle(color: Color(0xFF334EAC), fontSize: 16.0),
      titleSmall: TextStyle(color: Color(0xFF334EAC), fontSize: 16.0),
      bodySmall: TextStyle(color: Color(0xFF334EAC), fontSize: 16.0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: Color(0xFF334EAC),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xFF334EAC),
        side: BorderSide(color: Color(0xFF334EAC)),
      ),
    ),
    // inputDecorationTheme: InputDecorationTheme(
    //   fillColor: Color(0xFFF2F0DE), // Asian Pear
    //   focusedBorder: OutlineInputBorder(
    //     borderSide: BorderSide(color: Color(0xFF334EAC)), // Royal
    //   ),
    // ),
  );
}

ThemeData darkTheme() {
  print("objectifying Theme...");
  return ThemeData(
    fontFamily: GoogleFonts.uchen().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFBAD6EB), // Muted Sky, base of dark theme
      brightness: Brightness.dark,
      primary: Color(0xFF7096D1), // China (slightly muted in darkness)
      secondary: Color(0xFF334EAC), // Royal (contrasting accent)
      tertiary: Color(0xFF081F5C), // Midnight (deepest shade)
      surface: Color(0xFF292929), // Slightly lighter surface for depth
    ),
    textTheme: TextTheme(
      headlineLarge: TextStyle(
          color: Color.fromARGB(199, 240, 240, 240), // Light text on dark
          fontSize: 36.0,
          fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(
        color: Color.fromARGB(255, 183, 183, 183),
      ),
      bodyMedium: TextStyle(
          color: Color.fromARGB(217, 255, 255, 255), // Royal for emphasis
          fontSize: 16.0),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Color(0xFF292929), // Dark text on...
        backgroundColor: Color(0xFF7096D1), // ... a muted China background
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Color(0xFFBAD6EB), // Muted Sky for the outline
        side: BorderSide(color: Color(0xFFBAD6EB)),
      ),
    ),
  );
}
