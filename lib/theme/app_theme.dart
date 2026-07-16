import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ── Brand accent (same in both modes) ───────────────────────────────────
  static const Color primary    = Color(0xFF5B21B6);   // deep premium royal purple
  static const Color primaryLight = Color(0xFF7C3AED); // medium royal purple
  static const Color secondary  = Color(0xFFFF6584);
  static const Color success    = Color(0xFF22C55E);
  static const Color error      = Color(0xFFEF4444);
  static const Color warning    = Color(0xFFFFD166);

  // ── Light mode static colours (used as fallbacks / const refs) ─────────
  static const Color bgDark      = Color(0xFFF5F3FF);   // softest lavender
  static const Color bgCard      = Color(0xFFFAF9FF);   // light card
  static const Color bgCardLight = Color(0xFFEDE9FE);   // light purple input bg
  static const Color surface     = Color(0xFFFAF9FF);

  static const Color textPrimary   = Color(0xFF1E293B);  // premium slate-black
  static const Color textSecondary = Color(0xFF475569);  // medium slate-gray
  static const Color textMuted     = Color(0xFF94A3B8);  // light slate-gray

  // ── Dark mode static colours ────────────────────────────────────────────
  static const Color bgDarkDm       = Color(0xFF0F0C1B);  // midnight dark purple
  static const Color bgCardDm       = Color(0xFF1A172E);  // rich dark purple card
  static const Color bgCardLightDm  = Color(0xFF25213F);  // dark lavender input
  static const Color surfaceDm      = Color(0xFF141224);

  static const Color textPrimaryDm   = Color(0xFFECE9FC); // pale lavender-white
  static const Color textSecondaryDm = Color(0xFFB4B0C4); // soft lavender-grey
  static const Color textMutedDm     = Color(0xFF827F93); // dark lavender-grey

  // ── Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4C1D95), Color(0xFF6D28D9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light bg gradient (light lavender → wisteria)
  static const LinearGradient bgGradient = LinearGradient(
    colors: [
      Color(0xFFF5F3FF),   // softest lavender
      Color(0xFFE9E3FF),   // pale lavender
      Color(0xFFDCD3FF),   // light wisteria
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.55, 1.0],
  );

  // Dark bg gradient (midnight purple → deep wisteria)
  static const LinearGradient bgGradientDark = LinearGradient(
    colors: [
      Color(0xFF0F0C1B),   // midnight dark purple
      Color(0xFF1A172E),   // rich dark purple
      Color(0xFF2B1A4A),   // deep wisteria
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
    inputBorder: const Color(0xFFD8B4FE),
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
    inputBorder: const Color(0xFF581C87),
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
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: inputBorder, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        hintStyle: TextStyle(color: hintColor, fontSize: 13.5),
        labelStyle: TextStyle(color: textSub, fontSize: 13.5),
        prefixIconColor: textSub,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 0,
          textStyle:
              GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: isLight ? primary : primaryLight,
          textStyle:
              GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500),
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
