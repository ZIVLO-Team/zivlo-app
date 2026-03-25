import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System Colors
/// Based on docs/Styles.md
class AppColors {
  AppColors._();
  
  // Primary Colors
  static const Color colorPrimary = Color(0xFF1A1A2E);        // Azul-negro profundo
  static const Color colorPrimaryVariant = Color(0xFF16213E); // Variante más oscura
  static const Color colorAccent = Color(0xFFE94560);         // Rojo coral vibrante
  static const Color colorAccentSoft = Color(0xFFFF6B7A);     // Versión suave
  
  // Surface Colors
  static const Color colorSurface = Color(0xFF0F3460);        // Azul marino
  static const Color colorSurfaceVariant = Color(0xFF1A4A80); // Variante superficie
  static const Color colorBackground = Color(0xFF0A0A1A);     // Fondo base
  static const Color colorOnSurface = Color(0xFFFFFFFF);      // Texto sobre superficies
  static const Color colorOnSurfaceMuted = Color(0xFF8899AA); // Texto secundario
  
  // Functional Colors
  static const Color colorSuccess = Color(0xFF00D97E);        // Verde eléctrico
  static const Color colorWarning = Color(0xFFFFB830);        // Amarillo ámbar
  static const Color colorError = Color(0xFFE94560);          // Rojo (mismo que accent)
  static const Color colorInfo = Color(0xFF4DA3FF);           // Azul claro
  
  // Price and Numbers
  static const Color colorPrice = Color(0xFFFFFFFF);          // Blanco puro
  static const Color colorTotal = Color(0xFFE94560);          // Accent
  static const Color colorDiscount = Color(0xFF00D97E);       // Verde
  static const Color colorChange = Color(0xFFFFB830);         // Ámbar
}

/// Typography using Google Fonts
/// Space Mono for display/numbers, DM Sans for body/ui
class AppTypography {
  AppTypography._();
  
  static TextTheme get textTheme {
    return const TextTheme(
      // Display - Space Mono (for numbers, prices)
      displayLarge: TextStyle(
        fontFamily: 'Space Mono',
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Space Mono',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Space Mono',
        fontSize: 20,
        fontWeight: FontWeight.bold,
        height: 1.4,
      ),
      
      // Headlines - DM Sans
      headlineLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      
      // Titles - DM Sans
      titleLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      titleSmall: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.5,
      ),
      
      // Body - DM Sans
      bodyLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 16,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 12,
        fontWeight: FontWeight.normal,
        height: 1.5,
      ),
      
      // Labels - DM Sans
      labelLarge: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.4,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.5,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        fontFamily: 'DM Sans',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.6,
        letterSpacing: 0.5,
      ),
    );
  }
  
  /// Alternative: Use Google Fonts directly (requires internet for first load)
  static TextTheme googleFontsTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.spaceMono(fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: GoogleFonts.spaceMono(fontSize: 24, fontWeight: FontWeight.bold),
      displaySmall: GoogleFonts.spaceMono(fontSize: 20, fontWeight: FontWeight.bold),
      
      headlineLarge: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w600),
      headlineMedium: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600),
      headlineSmall: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
      
      titleLarge: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w500),
      titleSmall: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
      
      bodyLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.normal),
      bodyMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.normal),
      bodySmall: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.normal),
      
      labelLarge: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500),
      labelSmall: GoogleFonts.dmSans(fontSize: 11, fontWeight: FontWeight.w500),
    );
  }
}

/// Spacing System (multiples of 4dp)
class AppSpacing {
  AppSpacing._();
  
  static const double spacing2 = 2.0;
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;
  
  /// Default horizontal page margin
  static const double pageMargin = spacing16;
}

/// Border Radius System
class AppRadius {
  AppRadius._();
  
  static const double radiusSmall = 6.0;      // Chips, badges, inputs
  static const double radiusMedium = 12.0;    // Cards, tiles
  static const double radiusLarge = 16.0;     // BottomSheets, modals
  static const double radiusXL = 24.0;        // FAB, primary buttons
  static const double radiusFull = 999.0;     // Pill buttons, circles
}

/// Icon Sizes
class AppIconSize {
  AppIconSize._();
  
  static const double small = 16.0;
  static const double medium = 20.0;
  static const double large = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;  // Empty state icons
}
