import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System for Planning Poker
///
/// Modern, premium theme with Emerald Green and Gold accents
/// Inspired by classic poker aesthetics
/// Optimized for both light and dark modes
class AppTheme {
  AppTheme._();

  // ══════════════════════════════════════════════════════════════════════════
  // COLOR PALETTE - Emerald & Gold Premium
  // ══════════════════════════════════════════════════════════════════════════

  // Primary - Emerald Green (mesa de poker)
  static const Color _primaryLight = Color(0xFF059669); // Emerald 600
  static const Color _primaryDark = Color(0xFF34D399); // Emerald 400

  // Secondary - Royal Gold
  static const Color _secondaryLight = Color(0xFFD97706); // Amber 600
  static const Color _secondaryDark = Color(0xFFFBBF24); // Amber 400

  // Tertiary - Deep Purple (cartas)
  static const Color _tertiaryLight = Color(0xFF7C3AED); // Violet 600
  static const Color _tertiaryDark = Color(0xFFA78BFA); // Violet 400

  // Surfaces - Neutral warm
  static const Color _surfaceLight = Color(0xFFFAFAF9); // Stone 50
  static const Color _surfaceDark = Color(0xFF18181B); // Zinc 900

  // Success/Error/Warning
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color error = Color(0xFFF87171); // Red 400
  static const Color warning = Color(0xFFFBBF24); // Amber 400
  static const Color info = Color(0xFF60A5FA); // Blue 400

  // ══════════════════════════════════════════════════════════════════════════
  // LIGHT THEME
  // ══════════════════════════════════════════════════════════════════════════

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: _primaryLight,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD1FAE5), // Emerald 100
      onPrimaryContainer: const Color(0xFF064E3B), // Emerald 900
      secondary: _secondaryLight,
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFFEF3C7), // Amber 100
      onSecondaryContainer: const Color(0xFF78350F), // Amber 900
      tertiary: _tertiaryLight,
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFEDE9FE), // Violet 100
      onTertiaryContainer: const Color(0xFF4C1D95), // Violet 900
      error: error,
      onError: Colors.white,
      surface: _surfaceLight,
      onSurface: const Color(0xFF1C1917), // Stone 900
      surfaceContainerHighest: const Color(0xFFE7E5E4), // Stone 200
      surfaceContainerHigh: const Color(0xFFF5F5F4), // Stone 100
      surfaceContainerLow: const Color(0xFFFAFAF9), // Stone 50
      surfaceContainerLowest: Colors.white,
      outline: const Color(0xFFA8A29E), // Stone 400
      outlineVariant: const Color(0xFFE7E5E4), // Stone 200
      shadow: Colors.black.withValues(alpha: 0.08),
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DARK THEME
  // ══════════════════════════════════════════════════════════════════════════

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: _primaryDark,
      onPrimary: const Color(0xFF064E3B), // Emerald 900
      primaryContainer: const Color(0xFF065F46), // Emerald 800
      onPrimaryContainer: const Color(0xFFD1FAE5), // Emerald 100
      secondary: _secondaryDark,
      onSecondary: const Color(0xFF78350F), // Amber 900
      secondaryContainer: const Color(0xFF92400E), // Amber 800
      onSecondaryContainer: const Color(0xFFFEF3C7), // Amber 100
      tertiary: _tertiaryDark,
      onTertiary: const Color(0xFF4C1D95), // Violet 900
      tertiaryContainer: const Color(0xFF5B21B6), // Violet 800
      onTertiaryContainer: const Color(0xFFEDE9FE), // Violet 100
      error: error,
      onError: Colors.black,
      surface: _surfaceDark,
      onSurface: const Color(0xFFFAFAF9), // Stone 50
      surfaceContainerHighest: const Color(0xFF3F3F46), // Zinc 700
      surfaceContainerHigh: const Color(0xFF27272A), // Zinc 800
      surfaceContainerLow: const Color(0xFF1F1F23), // Custom
      surfaceContainerLowest: const Color(0xFF18181B), // Zinc 900
      outline: const Color(0xFF52525B), // Zinc 600
      outlineVariant: const Color(0xFF3F3F46), // Zinc 700
      shadow: Colors.black.withValues(alpha: 0.4),
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // THEME BUILDER
  // ══════════════════════════════════════════════════════════════════════════

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final textTheme =
        GoogleFonts.interTextTheme(
          isDark ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
        ).copyWith(
          displayLarge: GoogleFonts.plusJakartaSans(
            fontSize: 57,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.25,
          ),
          displayMedium: GoogleFonts.plusJakartaSans(
            fontSize: 45,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          displaySmall: GoogleFonts.plusJakartaSans(
            fontSize: 36,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          headlineLarge: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          headlineMedium: GoogleFonts.plusJakartaSans(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          headlineSmall: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
          titleMedium: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.15,
          ),
          titleSmall: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          bodyLarge: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
          bodyMedium: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
          bodySmall: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.4,
          ),
          labelLarge: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          labelMedium: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          labelSmall: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: colorScheme.surface,

      // AppBar
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        centerTitle: true,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        color: colorScheme.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Filled Button
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        prefixIconColor: colorScheme.onSurface.withValues(alpha: 0.6),
        suffixIconColor: colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.7),
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHigh,
        labelStyle: textTheme.labelMedium,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: colorScheme.surface,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: isDark
            ? colorScheme.surfaceContainerHigh
            : colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? colorScheme.onSurface : colorScheme.onInverseSurface,
        ),
      ),

      // Segmented Button
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.surfaceContainerLow;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimary;
            }
            return colorScheme.onSurface;
          }),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Icon Theme
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),

      // ListTile
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),

      // Tooltip
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: colorScheme.inverseSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
      ),

      // Progress Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.surfaceContainerHighest,
        circularTrackColor: colorScheme.surfaceContainerHighest,
      ),

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════
// THEME EXTENSIONS
// ══════════════════════════════════════════════════════════════════════════

/// Extension for easy access to custom colors
extension ThemeExtensions on ThemeData {
  Color get successColor => AppTheme.success;
  Color get warningColor => AppTheme.warning;
  Color get infoColor => AppTheme.info;
}

/// Extension for easy color manipulation
extension ColorExtensions on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness(
      (hsl.lightness + amount).clamp(0.0, 1.0),
    );
    return hslLight.toColor();
  }
}
