import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mental Wellness App Theme - Simplified 4-Color Palette
class AppTheme {
  // ============================================================================
  // CORE COLOR PALETTE (4 Colors)
  // ============================================================================
  
  /// Primary - Soft Indigo (Calm, Trust, Stability)
  static const primary = Color.fromARGB(255, 99, 130, 241);
  static const primaryLight = Color(0xFFA5B4FC);
  static const primaryDark = Color.fromARGB(255, 70, 81, 229);
  
  /// Secondary - Teal (Growth, Healing, Balance)
  static const secondary = Color(0xFF14B8A6);
  static const secondaryLight = Color(0xFF5EEAD4);
  
  /// Accent - Warm Amber (Attention, Care, Support)
  static const accent = Color(0xFFF59E0B);
  static const accentLight = Color(0xFFFBBF24);
  
  /// Neutral - Slate (Text, Backgrounds)
  static const neutral = Color(0xFF64748B);
  static const neutralLight = Color(0xFFF1F5F9);
  static const neutralDark = Color(0xFF1E293B);
  
  // Semantic colors (derived from core palette)
  static const success = secondary;
  static const warning = accent;
  static const error = Color(0xFFEF4444);
  
  // Background colors
  static const background = Color(0xFFFAFAFA);
  static const surface = Colors.white;
  
  // Text colors
  static const textPrimary = neutralDark;
  static const textSecondary = neutral;
  static const textTertiary = Color(0xFF94A3B8);
  
  // ============================================================================
  // GRADIENTS (Using Core Colors)
  // ============================================================================
  
  static const primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const successGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const breathingGradient = LinearGradient(
    colors: [secondaryLight, Color(0xFF7DD3FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const locationGradient = LinearGradient(
    colors: [Color(0xFFF472B6), Color(0xFFFCA5A5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const audioGradient = LinearGradient(
    colors: [Color(0xFFC4B5FD), primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const calmGradient = LinearGradient(
    colors: [secondaryLight, Color(0xFF99F6E4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const warmthGradient = LinearGradient(
    colors: [accentLight, Color(0xFFFCA5A5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================================================
  // SPACING (Consistent 8px grid)
  // ============================================================================
  
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space48 = 48.0;
  
  // ============================================================================
  // BORDER RADIUS (Consistent)
  // ============================================================================
  
  static const double radiusSmall = 12.0;
  static const double radiusMedium = 16.0;
  static const double radiusLarge = 24.0;
  static const double radiusXLarge = 28.0;
  
  // ============================================================================
  // SHADOWS
  // ============================================================================
  
  static BoxShadow get softShadow => const BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 20,
    offset: Offset(0, 4),
  );
  
  static BoxShadow get mediumShadow => const BoxShadow(
    color: Color(0x14000000),
    blurRadius: 30,
    offset: Offset(0, 8),
  );
  
  static BoxShadow glowShadow(Color color) => BoxShadow(
    color: color.withValues(alpha: 0.3),
    blurRadius: 20,
    spreadRadius: -5,
  );
  
  // ============================================================================
  // MAIN THEME DEFINITION
  // ============================================================================
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Color scheme
      colorScheme: ColorScheme.light(
        primary: primary,
        primaryContainer: Color(0xFFE0E7FF),
        secondary: secondary,
        secondaryContainer: Color(0xFFCCFBF1),
        tertiary: accent,
        tertiaryContainer: Color(0xFFFFEDD5),
        error: error,
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onTertiary: neutralDark,
        onError: Colors.white,
        onSurface: textPrimary,
        outline: Color(0xFFE2E8F0),
      ),
      
      // Scaffold
      scaffoldBackgroundColor: background,
      
      // AppBar theme - transparent, minimal
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      
      // Card theme - extra soft borders
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLarge),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        color: surface,
        margin: const EdgeInsets.symmetric(vertical: space8),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: space32, vertical: space16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: space24, vertical: space12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSmall),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: BorderSide(color: primary, width: 2),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input decoration - gentle, accessible
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neutralLight,
        contentPadding: const EdgeInsets.all(space20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXLarge),
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: neutralLight,
        padding: const EdgeInsets.symmetric(horizontal: space12, vertical: space8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSmall),
        ),
      ),
      
      // Divider theme
      dividerTheme: const DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: space24,
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: neutral,
        size: 24,
      ),
      
      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: textPrimary,
          height: 1.5,
        ),
      ),
    );
  }
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  static Color getConfidenceColor(String level) {
    switch (level.toLowerCase()) {
      case 'high': return warning;
      case 'medium': return success;
      default: return neutral;
    }
  }
  
  static Color getStateColor(String state) {
    if (state.contains('calm')) return secondaryLight;
    if (state.contains('stressed')) return accentLight;
    if (state.contains('restless')) return accentLight;
    if (state.contains('low')) return neutral;
    return primaryLight;
  }
}