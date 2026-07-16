import 'package:flutter/material.dart';

class PremiumAmbientBackground extends StatelessWidget {
  final Widget child;
  const PremiumAmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // Warm ivory base (light) / Deep espresso base (dark)
      color: isDark ? const Color(0xFF1A1008) : const Color(0xFFFAF0E2),
      child: Stack(
        children: [
          // ── Large bottom warm peach / terracotta glow ──────────────────

          // ── Top-right warm amber glow ──────────────────────────────────
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
                        ? const Color(0xFF4A2A0C).withValues(alpha: 0.55)
                        : const Color(0xFFF0C070).withValues(alpha: 0.55),
                    const Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
          // ── Top-left rose / plum blush accent ─────────────────────────
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
                        ? const Color(0xFF3D1828).withValues(alpha: 0.40)
                        : const Color(0xFFF2C0D4).withValues(alpha: 0.45),
                    const Color(0x00000000),
                  ],
                ),
              ),
            ),
          ),
          // ── Bottom-right deep amber ────────────────────────────────────
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
                        ? const Color(0xFF3D2010).withValues(alpha: 0.50)
                        : const Color(0xFFE09050).withValues(alpha: 0.40),
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
