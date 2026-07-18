import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumAmbientBackground extends StatelessWidget {
  final Widget child;
  const PremiumAmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // Soft lavender base (light) / Midnight dark purple base (dark)
      color: isDark ? AppTheme.bgDarkDm : AppTheme.bgDark,
      child: Stack(
        children: [
          // Large bottom warm purple glow 

          // Top-right violet glow 
          Positioned(
            top: -100,
            right: -120,
            width: 420,
            height: 420,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    isDark
                        ? const Color(0xFF2E1A47).withValues(alpha: 0.60)
                        : const Color(0xFFDDD6FE).withValues(alpha: 0.65),
                    const Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
          // Top-left plum/lavender blush accent 
          Positioned(
            top: -60,
            left: -100,
            width: 340,
            height: 340,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    isDark
                        ? const Color(0xFF3B1A54).withValues(alpha: 0.50)
                        : const Color(0xFFEDE9FE).withValues(alpha: 0.60),
                    const Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
          //  Bottom-right deep indigo/wisteria 
          Positioned(
            bottom: -40,
            right: -60,
            width: 280,
            height: 280,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    isDark
                        ? const Color(0xFF1E0E3B).withValues(alpha: 0.60)
                        : const Color(0xFFF3E8FF).withValues(alpha: 0.50),
                    const Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}
