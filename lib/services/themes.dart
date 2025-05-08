import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData lightTheme() {
  print("objectifying Theme...");
  return ThemeData(
    fontFamily: GoogleFonts.workSans().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF334EAC), // Royal
      brightness: Brightness.light,
      primary: const Color(0xFF334EAC), // Royal
      secondary: const Color(0xFFBAD6EB), // Sky
      tertiary: const Color(0xFF7096D1), // China
      surface: const Color(0xFFFFFFFF), // Porcelain (Pure white for contrast)
      background: const Color(0xFFF7F7F7), // Light grey for background
      onBackground: const Color(0xFF1B1B1F), // Darker grey for text on light background
    ),
   textTheme: const TextTheme(
  headlineLarge: TextStyle(
    color: Color.fromARGB(255, 0, 0, 255), // Dark grey for readability
    fontSize: 36.0,
    fontWeight: FontWeight.bold,
  ),
  bodyLarge: TextStyle(
    color: Color.fromARGB(255, 2, 2, 69),
    fontSize: 16.0,
  ),
  bodyMedium: TextStyle(
    color: Color.fromARGB(255, 16, 1, 59), // Neutral grey for text appearance
    fontSize: 16.0,
  ),
  titleMedium: TextStyle(
    color: Color.fromARGB(255, 12, 1, 59), // Neutral grey for titles
    fontSize: 16.0,
  ),
  titleSmall: TextStyle(
    color: Color.fromARGB(255, 36, 0, 80), // Neutral grey for small titles
    fontSize: 16.0,
  ),
  bodySmall: TextStyle(
    color: Color(0xFF4A4A4A), // Neutral grey for small text
    fontSize: 16.0,
  ),
),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF334EAC),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF334EAC),
        side: const BorderSide(color: Color(0xFF334EAC)),
      ),
    ),
  );
}

ThemeData darkTheme() {
  print("objectifying Theme...");
  return ThemeData(
    fontFamily: GoogleFonts.workSans().fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF121212), // Near-black for the base of dark theme
      brightness: Brightness.dark,
      primary: const Color(0xFF7096D1), // China (slightly muted in darkness)
      secondary: const Color(0xFF334EAC), // Royal (contrasting accent)
      tertiary: const Color(0xFF081F5C), // Midnight (deepest shade)
      surface: const Color(0xFF121212), // Near-black surface
      background: const Color(0xFF1F1F1F), // Dark grey for background
      onBackground: const Color(0xFFE0E0E0), // Light grey for text on dark background
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          color: Color(0xFFE0E0E0), // Light grey for readability
          fontSize: 36.0,
          fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(
        color: Color(0xFFB7B7B7), // Light grey for body text
        fontSize: 16.0,
      ),
      bodyMedium: TextStyle(
        color: Color(0xFF7096D1), // China
        fontSize: 16.0,
      ),
      titleMedium: TextStyle(
        color: Color(0xFF7096D1), // China
        fontSize: 16.0,
      ),
      titleSmall: TextStyle(
        color: Color(0xFF7096D1), // China
        fontSize: 16.0,
      ),
      bodySmall: TextStyle(
        color: Color(0xFF7096D1), // China
        fontSize: 16.0,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: const Color(0xFF1F1F1F), // Dark text on...
        backgroundColor: const Color(0xFF7096D1), // ... a muted China background
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFFBAD6EB), // Muted Sky for the outline
        side: const BorderSide(color: Color(0xFFBAD6EB)),
      ),
    ),
  );
}
