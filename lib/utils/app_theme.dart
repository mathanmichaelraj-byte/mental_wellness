import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Mental Wellness App Theme - "Serene Twilight"
/// A therapeutically-informed color palette designed to promote calm,
/// safety, and emotional well-being.
class AppTheme {
  // ============================================================================
  // PRIMARY COLOR PALETTE
  // ============================================================================
  
  /// Soft Lavender - Primary brand color
  /// Psychology: Calming, peaceful, promotes mental clarity
  static const primary = Color(0xFFA5B4FC);
  
  /// Deeper Indigo - Accent for depth
  static const primaryDark = Color(0xFF818CF8);
  
  /// Gentle Teal - Success and growth indicators
  /// Psychology: Healing, growth, stability
  static const success = Color(0xFF5EEAD4);
  
  /// Warm Peach - Gentle attention (replaces harsh orange)
  /// Psychology: Comfort, care, supportive warmth
  static const warning = Color(0xFFFED7AA);
  
  /// Soft Coral - Error states with empathy
  static const error = Color(0xFFFC8181);
  
  // ============================================================================
  // BACKGROUND COLORS
  // ============================================================================
  
  /// Cloud White - Main background
  static const background = Color(0xFFF8FAFC);
  
  /// Soft Sage - Card and container backgrounds
  /// Provides gentle separation without harsh contrast
  static const surface = Color(0xFFECFDF5);
  
  /// Pure white for cards
  static const surfaceWhite = Color(0xFFFFFFFF);
  
  // ============================================================================
  // TEXT COLORS
  // ============================================================================
  
  /// Slate - Primary text (WCAG AAA compliant)
  static const textPrimary = Color(0xFF1E293B);
  
  /// Medium Slate - Secondary text
  static const textSecondary = Color(0xFF64748B);
  
  /// Light Slate - Tertiary text and hints
  static const textTertiary = Color(0xFF94A3B8);
  
  // ============================================================================
  // SEMANTIC COLORS
  // ============================================================================
  
  /// Calm state color - gentle blue-green
  static const stateCalm = Color(0xFF99F6E4);
  
  /// Restless state color - soft amber
  static const stateRestless = Color(0xFFFDE68A);
  
  /// Stressed state color - warm peach (empathetic, not alarming)
  static const stateStressed = Color(0xFFFED7AA);
  
  /// Low energy state color - gentle gray-blue
  static const stateLowEnergy = Color(0xFFCBD5E1);
  
  // ============================================================================
  // GRADIENTS
  // ============================================================================
  
  /// Primary gradient - Lavender to soft purple
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFFA5B4FC), Color(0xFFC4B5FD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Success gradient - Teal to mint
  static const successGradient = LinearGradient(
    colors: [Color(0xFF5EEAD4), Color(0xFF99F6E4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Warmth gradient - Peach to soft coral
  static const warmthGradient = LinearGradient(
    colors: [Color(0xFFFED7AA), Color(0xFFFCA5A5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Calm gradient - Soft blue to teal
  static const calmGradient = LinearGradient(
    colors: [Color(0xFFBFDBFE), Color(0xFF99F6E4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Breathing gradient - Gentle aqua to mint
  static const breathingGradient = LinearGradient(
    colors: [Color(0xFF5EEAD4), Color(0xFF7DD3FC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Location gradient - Soft pink to coral
  static const locationGradient = LinearGradient(
    colors: [Color(0xFFF9A8D4), Color(0xFFFCA5A5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  /// Audio gradient - Purple to lavender
  static const audioGradient = LinearGradient(
    colors: [Color(0xFFC4B5FD), Color(0xFFDDD6FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // ============================================================================
  // SHADOWS
  // ============================================================================
  
  /// Soft shadow for cards - subtle, layered effect
  static BoxShadow get softShadow => BoxShadow(
    color: Colors.black.withOpacity(0.04),
    blurRadius: 20,
    offset: const Offset(0, 4),
  );
  
  /// Medium shadow for elevated elements
  static BoxShadow get mediumShadow => BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 30,
    offset: const Offset(0, 8),
  );
  
  /// Glow effect for important elements
  static BoxShadow glowShadow(Color color) => BoxShadow(
    color: color.withOpacity(0.3),
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
        secondary: success,
        secondaryContainer: Color(0xFFCCFBF1),
        tertiary: warning,
        tertiaryContainer: Color(0xFFFFEDD5),
        error: error,
        errorContainer: Color(0xFFFEE2E2),
        background: background,
        surface: surfaceWhite,
        surfaceVariant: surface,
        onPrimary: Colors.white,
        onSecondary: textPrimary,
        onTertiary: textPrimary,
        onError: Colors.white,
        onBackground: textPrimary,
        onSurface: textPrimary,
        onSurfaceVariant: textSecondary,
        outline: Color(0xFFE2E8F0),
        shadow: Colors.black.withOpacity(0.04),
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
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
      ),
      
      // Card theme - extra soft borders
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24), // Increased from 20
          side: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        color: surfaceWhite,
        margin: const EdgeInsets.symmetric(vertical: 8),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w600,
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
        fillColor: Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.all(20), // Increased for better touch
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: error, width: 2),
        ),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: textSecondary,
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          color: textTertiary,
        ),
      ),
      
      // Dialog theme
      dialogTheme: DialogThemeData(
        elevation: 0,
        backgroundColor: surfaceWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          height: 1.6,
          color: textPrimary,
        ),
      ),
      
      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        deleteIconColor: textSecondary,
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          color: textPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: Color(0xFFE2E8F0),
        thickness: 1,
        space: 24,
      ),
      
      // Icon theme
      iconTheme: IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      
      // Typography
      textTheme: TextTheme(
        displayLarge: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        headlineLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.3,
        ),
        labelMedium: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
  
  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Get gradient for feature cards
  static Gradient getFeatureGradient(String featureName) {
    switch (featureName.toLowerCase()) {
      case 'emotional_analysis':
      case 'emotional analysis':
        return primaryGradient;
      case 'emotional_release':
      case 'emotional release':
        return successGradient;
      case 'calm_audio':
      case 'calm audio':
        return audioGradient;
      case 'location':
      case 'find places':
        return locationGradient;
      case 'breathing':
        return breathingGradient;
      default:
        return calmGradient;
    }
  }
  
  /// Get color for confidence level
  static Color getConfidenceColor(String level) {
    switch (level.toLowerCase()) {
      case 'low':
        return textSecondary;
      case 'medium':
        return success;
      case 'high':
        return warning;
      default:
        return textSecondary;
    }
  }
  
  /// Get color for emotional state
  static Color getStateColor(String state) {
    switch (state.toLowerCase()) {
      case 'calm':
        return stateCalm;
      case 'restless':
        return stateRestless;
      case 'stressed':
        return stateStressed;
      case 'low_energy':
      case 'low energy':
        return stateLowEnergy;
      default:
        return primary;
    }
  }
}