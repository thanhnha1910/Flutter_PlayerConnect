import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Sophisticated Color Palette
  static const Color scaffoldBackground = Color(0xFFF4F6F8);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3748);
  static const Color textSecondary = Color(0xFF718096);
  static const Color primaryAccent = Color(0xFF38B2AC);
  static const Color secondaryAccent = Color(0xFF4299E1);
  static const Color successColor = Color(0xFF48BB78);
  static const Color warningColor = Color(0xFFED8936);
  static const Color errorColor = Color(0xFFE53E3E);
  static const Color surfaceColor = Color(0xFFFAFAFA);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color shadowColor = Color(0x0D000000);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF38B2AC), Color(0xFF319795)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF4299E1), Color(0xFF3182CE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card Theme
  static BoxDecoration get cardDecoration => BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static BoxDecoration get elevatedCardDecoration => BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      );

  // Text Styles
  static TextStyle get headingLarge => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.2,
      );

  static TextStyle get headingMedium => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get headingSmall => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        height: 1.4,
      );

  static TextStyle get caption => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: textSecondary,
        height: 1.3,
      );

  static TextStyle get buttonText => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  // Button Styles
  static ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: primaryAccent,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: buttonText,
      );

  static ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: borderColor, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: buttonText,
      );

  // Input Decoration
  static InputDecoration get searchInputDecoration => InputDecoration(
        hintText: 'Search for fields, matches, or areas...',
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textSecondary,
        ),
        prefixIcon: Icon(
          Icons.search,
          color: textSecondary,
          size: 20,
        ),
        filled: true,
        fillColor: surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryAccent, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      );

  // Chip Theme
  static ChipThemeData get chipTheme => ChipThemeData(
        backgroundColor: surfaceColor,
        selectedColor: primaryAccent.withOpacity(0.1),
        disabledColor: borderColor,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: primaryAccent,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: borderColor, width: 1),
        ),
        selectedShadowColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        pressElevation: 0,
      );

  // Icon Styles
  static const double iconSizeSmall = 16;
  static const double iconSizeMedium = 20;
  static const double iconSizeLarge = 24;
  static const double iconSizeXLarge = 32;

  // Spacing
  static const double spacingXS = 4;
  static const double spacingS = 8;
  static const double spacingM = 12;
  static const double spacingL = 16;
  static const double spacingXL = 20;
  static const double spacingXXL = 24;
  static const double spacingXXXL = 32;

  // Border Radius
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;

  // Additional properties for Super App
  static const Color accentColor = Color(0xFF9F7AEA);
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ];

  static TextStyle get headlineMedium => GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        height: 1.3,
      );

  static TextStyle get headlineSmall => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        height: 1.4,
      );

  // Theme Data
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryAccent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: scaffoldBackground,
        cardColor: cardBackground,
        textTheme: GoogleFonts.interTextTheme(),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: primaryButtonStyle,
        ),
        chipTheme: chipTheme,
      );
}