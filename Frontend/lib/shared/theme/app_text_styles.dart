import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Theater typography system — four font families, each accessed via
/// a static builder method so call-sites stay concise.
class AppTextStyles {
  AppTextStyles._();

  // ── Theater / Display (Alfa Slab One) ────────────────────────────────────
  /// Bold slab-serif — buttons, big labels, code displays.
  static TextStyle theater({
    double size = 16,
    Color color = AppColors.textLight,
    double letterSpacing = 0,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.alfaSlabOne(
        fontSize: size,
        color: color,
        letterSpacing: letterSpacing,
        fontWeight: weight,
      );

  // ── Handwritten / Notes (Kalam) ──────────────────────────────────────────
  /// Kalam — labels, pills, informal notes.
  static TextStyle hand({
    double size = 14,
    Color color = AppColors.textLight,
    double letterSpacing = 0,
    FontStyle style = FontStyle.normal,
    FontWeight weight = FontWeight.w400,
  }) =>
      GoogleFonts.kalam(
        fontSize: size,
        color: color,
        letterSpacing: letterSpacing,
        fontStyle: style,
        fontWeight: weight,
      );

  // ── Marquee / Bulb-dot letters (Codystar) ────────────────────────────────
  /// Codystar — marquee text, countdown numbers, code chars.
  static TextStyle marquee({
    double size = 28,
    Color color = AppColors.bulbOn,
    double letterSpacing = 0.06,
  }) =>
      GoogleFonts.codystar(
        fontSize: size,
        color: color,
        letterSpacing: size * letterSpacing,
        fontWeight: FontWeight.w700,
      );

  // ── Secondary UI (Space Grotesk) ─────────────────────────────────────────
  static TextStyle ui({
    double size = 14,
    Color color = AppColors.textLight,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0,
  }) =>
      GoogleFonts.spaceGrotesk(
        fontSize: size,
        color: color,
        fontWeight: weight,
        letterSpacing: letterSpacing,
      );

  // ── Convenience shortcuts ─────────────────────────────────────────────────
  static TextStyle get sectionLabel => hand(
        size: 11,
        color: AppColors.gold,
        letterSpacing: 3,
        weight: FontWeight.w500,
      );

  static TextStyle get onAirLabel => hand(
        size: 11,
        color: AppColors.paper,
        letterSpacing: 2,
      );
}
