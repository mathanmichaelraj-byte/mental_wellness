import 'package:flutter/material.dart';

/// Mental Wellness App Theme - Black, White & Teal Palette
class AppTheme {
  // Core Colors (Only 5 colors)
  static const primary = Color(0xFF14B8A6);      // Teal
  static const primaryLight = Color(0xFF5EEAD4); // Light Teal
  static const black = Color(0xFF000000);        // Black
  static const white = Color(0xFFFFFFFF);        // White
  static const grey = Color(0xFF374151);         // Dark Grey
  
  // Theme-aware dynamic colors (use with context)
  static Color background(BuildContext context) => 
    Theme.of(context).brightness == Brightness.light ? white : black;
  
  static Color surface(BuildContext context) => 
    Theme.of(context).brightness == Brightness.light ? Color(0xFFF3F4F6) : grey;
  
  static Color textPrimary(BuildContext context) => 
    Theme.of(context).brightness == Brightness.light ? black : white;
  
  static Color textSecondary(BuildContext context) => 
    Theme.of(context).brightness == Brightness.light ? grey : primaryLight;
  
  // Semantic (reuse core colors)
  static const success = primary;
  static const error = primary;
  
  // Single gradient
  static const gradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Spacing
  static const double space8 = 8.0;
  static const double space16 = 16.0;
  static const double space24 = 24.0;
  
  // Radius
  static const double radius = 16.0;
  
  // Shadow
  static BoxShadow get shadow => BoxShadow(
    color: primary.withValues(alpha: 0.2),
    blurRadius: 20,
    offset: const Offset(0, 4),
  );
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        surface: Color(0xFFF3F4F6),
        onPrimary: black,
        onSecondary: white,
        onSurface: black,
      ),
      scaffoldBackgroundColor: white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: black,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Color(0xFFF3F4F6),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Color(0xFFF3F4F6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Color(0xFFF3F4F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      iconTheme: IconThemeData(color: black),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: black),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: black),
        bodyLarge: TextStyle(fontSize: 16, color: black),
        bodyMedium: TextStyle(fontSize: 14, color: grey),
      ),
    );
  }
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: primary,
        secondary: primaryLight,
        surface: grey,
        onPrimary: black,
        onSecondary: black,
        onSurface: white,
      ),
      scaffoldBackgroundColor: black,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: black,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: grey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: primary, width: 2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: grey,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      iconTheme: IconThemeData(color: white),
      textTheme: TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: white),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: white),
        bodyLarge: TextStyle(fontSize: 16, color: white),
        bodyMedium: TextStyle(fontSize: 14, color: primaryLight),
      ),
    );
  }
  // Helper methods
  static Color getConfidenceColor(String level) => level == 'high' ? primary : primaryLight;
  static Color getStateColor(String state) => state.contains('calm') ? primaryLight : primary;
}