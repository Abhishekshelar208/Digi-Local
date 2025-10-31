import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Modern Color Palette - Deep Ocean & Sunset
  static const Color primaryColor = Color(0xFF0A192F); // Deep Navy Blue
  static const Color secondaryColor = Color(0xFFFF6B6B); // Vibrant Coral
  static const Color accentColor = Color(0xFF4ECDC4); // Turquoise
  static const Color highlightColor = Color(0xFFFFE66D); // Warm Yellow
  
  // Gradient Colors
  static const Color gradientStart = Color(0xFF667EEA); // Purple Blue
  static const Color gradientEnd = Color(0xFF764BA2); // Deep Purple
  
  // Background Colors
  static const Color backgroundColor = Color(0xFFF8F9FA); // Soft White
  static const Color cardBackground = Color(0xFFFFFFFF); // Pure White
  static const Color darkBackground = Color(0xFF1A1F36); // Dark Blue
  
  // Text Colors
  static const Color textPrimary = Color(0xFF2D3436); // Almost Black
  static const Color textSecondary = Color(0xFF636E72); // Gray
  static const Color textLight = Color(0xFFB2BEC3); // Light Gray
  
  // Accent Colors
  static const Color successColor = Color(0xFF00D2A0); // Mint Green
  static const Color warningColor = Color(0xFFFFA502); // Orange
  static const Color errorColor = Color(0xFFFF6B81); // Pink Red
  static const Color infoColor = Color(0xFF5F27CD); // Purple
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFFE66D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF0A192F), Color(0xFF1C3D5A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Typography
  static TextStyle heading1(BuildContext context, {Color? color}) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return GoogleFonts.poppins(
      fontSize: isMobile ? 32 : 56,
      fontWeight: FontWeight.w800,
      color: color ?? textPrimary,
      letterSpacing: -1.5,
      height: 1.2,
    );
  }

  static TextStyle heading2(BuildContext context, {Color? color}) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return GoogleFonts.poppins(
      fontSize: isMobile ? 24 : 40,
      fontWeight: FontWeight.w700,
      color: color ?? textPrimary,
      letterSpacing: -1,
    );
  }

  static TextStyle heading3(BuildContext context, {Color? color}) {
    bool isMobile = MediaQuery.of(context).size.width < 600;
    return GoogleFonts.poppins(
      fontSize: isMobile ? 20 : 32,
      fontWeight: FontWeight.w600,
      color: color ?? textPrimary,
      letterSpacing: -0.5,
    );
  }

  static TextStyle bodyLarge({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 18,
      fontWeight: FontWeight.w400,
      color: color ?? textSecondary,
      height: 1.6,
    );
  }

  static TextStyle bodyMedium({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: color ?? textSecondary,
      height: 1.5,
    );
  }

  static TextStyle bodySmall({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: color ?? textLight,
      height: 1.4,
    );
  }

  static TextStyle buttonText({Color? color}) {
    return GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: color ?? Colors.white,
      letterSpacing: 0.5,
    );
  }

  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> elevatedShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 32,
      offset: Offset(0, 12),
    ),
  ];

  static List<BoxShadow> glowShadow(Color color) => [
    BoxShadow(
      color: color.withOpacity(0.4),
      blurRadius: 20,
      offset: Offset(0, 8),
    ),
  ];

  // Border Radius
  static BorderRadius smallRadius = BorderRadius.circular(12);
  static BorderRadius mediumRadius = BorderRadius.circular(16);
  static BorderRadius largeRadius = BorderRadius.circular(24);
  static BorderRadius xlRadius = BorderRadius.circular(32);

  // Decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackground,
    borderRadius: largeRadius,
    border: Border.all(color: Color(0xFFE8ECF0), width: 1),
    boxShadow: cardShadow,
  );

  static BoxDecoration gradientCardDecoration = BoxDecoration(
    gradient: primaryGradient,
    borderRadius: largeRadius,
    boxShadow: elevatedShadow,
  );

  static BoxDecoration glassmorphismDecoration = BoxDecoration(
    color: Colors.white.withOpacity(0.7),
    borderRadius: largeRadius,
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: Offset(0, 8),
      ),
    ],
  );

  // Spacing
  static const double spacingXS = 8.0;
  static const double spacingS = 16.0;
  static const double spacingM = 24.0;
  static const double spacingL = 32.0;
  static const double spacingXL = 48.0;
  static const double spacingXXL = 64.0;

  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
}
