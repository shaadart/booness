import 'package:flutter/material.dart';

ThemeData lightTheme() {
  print("objectifying Theme...");
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF334EAC), // Royal
      brightness: Brightness.light,
      primary: Color(0xFF334EAC), // Royal
      secondary: Color(0xFFBAD6EB), // Sky
      tertiary: Color(0xFF7096D1), // China
      background: Color.fromARGB(255, 254, 254, 254), // Moon
      onBackground: Color(0xFF081F5C), // Midnight
      surface: Color(0xFFFFFFFF), // Porcelain (Pure white for contrast)
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          color: Color(0xFF081F5C),
          fontSize: 36.0,
          fontWeight: FontWeight.bold),
      bodyText1: TextStyle(
        color: Color(0xFF081F5C),
      ),
      bodyText2: TextStyle(color: Color(0xFF334EAC), fontSize: 16.0),
      subtitle1: TextStyle(color: Color(0xFF334EAC), fontSize: 16.0),
      subtitle2: TextStyle(color: Color(0xFF334EAC), fontSize: 16.0),
      caption: TextStyle(color: Color(0xFF334EAC), fontSize: 16.0),
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
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFFBAD6EB), // Muted Sky, base of dark theme
      brightness: Brightness.dark,
      primary: Color(0xFF7096D1), // China (slightly muted in darkness)
      secondary: Color(0xFF334EAC), // Royal (contrasting accent)
      tertiary: Color(0xFF081F5C), // Midnight (deepest shade)
      background: Color(0xFF121212), // True dark for background
      onBackground: Color(0xFFF0F0F0), // Light text for readability
      surface: Color(0xFF292929), // Slightly lighter surface for depth
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
          color: Color(0xFFF0F0F0), // Light text on dark
          fontSize: 36.0,
          fontWeight: FontWeight.bold),
      bodyText1: TextStyle(
        color: Color(0xFFF0F0F0),
      ),
      bodyText2: TextStyle(
          color: Color.fromARGB(255, 255, 255, 255), // Royal for emphasis
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
