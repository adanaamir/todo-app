import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand accent (same in both modes) ───────────────────────────────────
  static const Color primary    = Color(0xFFCB7D3A);   // warm amber
  static const Color primaryLight = Color(0xFFE8A860); // light warm amber
  static const Color secondary  = Color(0xFFFF6584);
  static const Color success    = Color(0xFF22C55E);
  static const Color error      = Color(0xFFEF4444);
  static const Color warning    = Color(0xFFFFD166);

  // ── Light mode static colours (used as fallbacks / const refs) ─────────
  static const Color bgDark      = Color(0xFFFAF0E2);   // warm cream
  static const Color bgCard      = Color(0xFFFFFAF5);   // warm white card
  static const Color bgCardLight = Color(0xFFF5EAD8);   // champagne input bg
  static const Color surface     = Color(0xFFFFFAF5);

  static const Color textPrimary   = Color(0xFF2D1B0E);  // deep warm brown
  static const Color textSecondary = Color(0xFF7A5C45);  // warm mid-brown
  static const Color textMuted     = Color(0xFFBBA090);  // light warm grey

  // ── Dark mode static colours ────────────────────────────────────────────
  static const Color bgDarkDm       = Color(0xFF1A1008);  // deep espresso
  static const Color bgCardDm       = Color(0xFF2A1C10);  // dark card
  static const Color bgCardLightDm  = Color(0xFF362415);  // dark input
  static const Color surfaceDm      = Color(0xFF241910);

  static const Color textPrimaryDm   = Color(0xFFF5E8D5); // warm cream
  static const Color textSecondaryDm = Color(0xFFB89F8A);
  static const Color textMutedDm     = Color(0xFF8B7060);

  // ── Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFCB7D3A), Color(0xFFE8A860)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light bg gradient (warm peach → golden)
  static const LinearGradient bgGradient = LinearGradient(
    colors: [
      Color(0xFFFAF0E2),   // warm ivory
      Color(0xFFF5DFC0),   // champagne
      Color(0xFFECC499),   // warm golden peach
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
  );

  // Dark bg gradient (espresso → deep terracotta)
  static const LinearGradient bgGradientDark = LinearGradient(
    colors: [
      Color(0xFF1A1008),   // deep espresso
      Color(0xFF2A1C10),   // dark brown
      Color(0xFF3D2415),   // deep terracotta
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient completedGradient = LinearGradient(
    colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Light Theme ──────────────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme(
    brightness: Brightness.light,
    scaffoldBg: bgDark,
    cardColor: bgCard,
    inputFill: bgCardLight,
    surfaceColor: surface,
    textMain: textPrimary,
    textSub: textSecondary,
    hintColor: textMuted,
    inputBorder: const Color(0xFFE0C8A8),
  );

  // ── Dark Theme ───────────────────────────────────────────────────────
  static ThemeData get darkTheme => _buildTheme(
    brightness: Brightness.dark,
    scaffoldBg: bgDarkDm,
    cardColor: bgCardDm,
    inputFill: bgCardLightDm,
    surfaceColor: surfaceDm,
    textMain: textPrimaryDm,
    textSub: textSecondaryDm,
    hintColor: textMutedDm,
    inputBorder: const Color(0xFF4A3520),
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBg,
    required Color cardColor,
    required Color inputFill,
    required Color surfaceColor,
    required Color textMain,
    required Color textSub,
    required Color hintColor,
    required Color inputBorder,
  }) {
    final isLight = brightness == Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: scaffoldBg,
      cardColor: cardColor,
      colorScheme: isLight
          ? ColorScheme.light(
              primary: primary,
              secondary: secondary,
              surface: surfaceColor,
              onSurface: textMain,
              error: error,
            )
          : ColorScheme.dark(
              primary: primary,
              secondary: secondary,
              surface: surfaceColor,
              onSurface: textMain,
              error: error,
            ),
      textTheme: GoogleFonts.poppinsTextTheme(
        isLight ? ThemeData.light().textTheme : ThemeData.dark().textTheme,
      ).apply(bodyColor: textMain, displayColor: textMain),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        hintStyle: TextStyle(color: hintColor),
        labelStyle: TextStyle(color: textSub),
        prefixIconColor: textSub,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
          textStyle:
              GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isLight ? primary : primaryLight,
          textStyle:
              GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: textMain,
        ),
        iconTheme: IconThemeData(color: textMain),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return success;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: hintColor, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
