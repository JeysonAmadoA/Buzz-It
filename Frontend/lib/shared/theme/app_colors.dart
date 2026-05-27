import 'package:flutter/material.dart';

/// Theater/Broadway color palette — matches the HTML prototype's CSS tokens.
class AppColors {
  AppColors._();

  // ── Backgrounds ─────────────────────────────────────────────────────────
  static const Color velvetBg      = Color(0xFF8C1320);
  static const Color velvetBgDeep  = Color(0xFF3E070D);
  static const Color darkVelvet    = Color(0xFF2A0509);
  static const Color darkVelvetDeep= Color(0xFF120203);
  static const Color darkBase      = Color(0xFF1A0D0D);
  static const Color joinBg        = Color(0xFF1F0808);
  static const Color hostBg        = Color(0xFF1F1208);
  static const Color woodLight     = Color(0xFF3A2814);
  static const Color woodDark      = Color(0xFF2A1A0A);
  static const Color lcdBg         = Color(0xFF0D0703);
  static const Color codeBg        = Color(0xFF0D0405);

  // ── Gold family ──────────────────────────────────────────────────────────
  static const Color gold          = Color(0xFFC9A23A);
  static const Color goldDeep      = Color(0xFF8A6C1F);
  static const Color goldLight     = Color(0xFFD8C98F);
  static const Color goldBtnTop    = Color(0xFFE3C264);
  static const Color goldBtnBot    = Color(0xFFB88D23);
  static const Color goldBtnShadow = Color(0xFF4A3608);

  // ── Crimson family ───────────────────────────────────────────────────────
  static const Color crimson       = Color(0xFFB21F2E);
  static const Color crimsonDeep   = Color(0xFF6E1218);
  static const Color crimsonBtnTop = Color(0xFFC43242);
  static const Color crimsonBtnBot = Color(0xFF871620);

  // ── Bulb colors ──────────────────────────────────────────────────────────
  static const Color bulbOn        = Color(0xFFF5CD55);
  static const Color bulbOnEdge    = Color(0xFFB78618);
  static const Color bulbOnBright  = Color(0xFFFFF7C2);
  static const Color bulbOff       = Color(0xFF4A3C2A);

  // ── Text / UI ────────────────────────────────────────────────────────────
  static const Color paper         = Color(0xFFF4ECD8);
  static const Color paperEdge     = Color(0xFFECE1C4);
  static const Color ink           = Color(0xFF1F1C18);
  static const Color inkSoft       = Color(0xFF5B554B);
  static const Color textLight     = Color(0xFFF5E8C1);
  static const Color textDim       = Color(0xFFD8C98F);
  static const Color textMuted     = Color(0xFF8A7240);

  // ── Buzzer state colors ──────────────────────────────────────────────────
  static const Color buzzerWaiting = Color(0xFF5A3A3A);
  static const Color buzzerReady   = Color(0xFF8A1A26);
  static const Color buzzerEnabled = Color(0xFFD92B3C);
  static const Color buzzerWinner  = Color(0xFFF5CD55);
  static const Color buzzerLate    = Color(0xFF4A1A1A);
  static const Color buzzerLocked  = Color(0xFF4A3014);

  // ── Gradients ────────────────────────────────────────────────────────────
  static const LinearGradient goldButton = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [goldBtnTop, goldBtnBot],
  );

  static const LinearGradient goldButtonDarker = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFD8B04E), Color(0xFF9C721A)],
  );

  static const LinearGradient crimsonButton = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [crimsonBtnTop, crimsonBtnBot],
  );

  static const RadialGradient velvetScreen = RadialGradient(
    center: Alignment(0, -1),
    radius: 1.4,
    colors: [velvetBg, velvetBgDeep],
  );

  static const RadialGradient darkVelvetScreen = RadialGradient(
    center: Alignment(0, -1),
    radius: 1.4,
    colors: [darkVelvet, darkVelvetDeep],
  );

  static const RadialGradient winnerBuzzer = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.2,
    colors: [bulbOnBright, bulbOn, Color(0xFFD97920), Color(0xFF8A3914)],
    stops: [0.0, 0.25, 0.65, 1.0],
  );

  static const RadialGradient enabledBuzzer = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.2,
    colors: [Color(0xFFFF5E6A), buzzerEnabled, Color(0xFF871620)],
    stops: [0.0, 0.4, 1.0],
  );

  static const RadialGradient waitingBuzzer = RadialGradient(
    center: Alignment.topLeft,
    radius: 1.2,
    colors: [Color(0xFF7A5A5A), Color(0xFF5A3A3A), Color(0xFF3A2020)],
    stops: [0.0, 0.4, 1.0],
  );
}
