import 'package:flutter/material.dart';

class AppColors {
  // Global active theme state (updated by ThemeCubit)
  static ValueNotifier<bool> isDarkNotifier = ValueNotifier<bool>(false);
  static bool get isDark => isDarkNotifier.value;

  // Preset 1: Cyber Neon Tokens (#0A0A0A + #007BA7 + #FF2D95)
  static const Color cyberCanvas = Color(0xFF0A0A0A);      // Pure Jet Canvas
  static const Color cyberCard = Color(0xFF18181B);        // Surface Card Zinc-900
  static const Color cyberCardSubtle = Color(0xFF222226);  // Sub-cards & Nested Tiles
  static const Color cyberBorder = Color(0xFF2E2E33);      // Subtle Borders
  static const Color cyberPrimary = Color(0xFF007BA7);     // Cerulean Blue
  static const Color cyberAccent = Color(0xFFFF2D95);      // Cyber Rose Pink
  static const Color cyberTextMain = Color(0xFFFFFFFF);    // Primary White Text
  static const Color cyberTextMuted = Color(0xFFB4B4BB);   // Secondary Text (Zinc-300 readable contrast)
  static const Color cyberTextDim = Color(0xFF71717A);     // Captions / Dim Text

  // Light Preset: Nordic Pro
  static const Color lightCanvas = Color(0xFFF1F5F9);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardSubtle = Color(0xFFF8FAFC);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightPrimary = Color(0xFF4F46E5);
  static const Color lightAccent = Color(0xFF059669);
  static const Color lightTextMain = Color(0xFF0F172A);
  static const Color lightTextMuted = Color(0xFF475569);
  static const Color lightTextDim = Color(0xFF94A3B8);

  // Dynamic Getters for Background & Surfaces
  static Color get background => isDark ? cyberCanvas : lightCanvas;
  static Color get surface => isDark ? cyberCard : lightCard;
  static Color get cardSubtle => isDark ? cyberCardSubtle : lightCardSubtle;
  static Color get cardBorder => isDark ? cyberBorder : lightBorder;

  // Dynamic Brand Colors
  static Color get primary => isDark ? cyberPrimary : lightPrimary;
  static Color get primaryDark => isDark ? const Color(0xFF005575) : const Color(0xFF3730A3);
  static Color get primaryLight => isDark ? const Color(0x26007BA7) : const Color(0xFFEEF2FF);
  static Color get accent => isDark ? cyberAccent : lightAccent;
  static Color get accentLight => isDark ? const Color(0x26FF2D95) : const Color(0xFFECFDF5);

  // Dynamic Text Colors
  static Color get textPrimary => isDark ? cyberTextMain : lightTextMain;
  static Color get textSecondary => isDark ? cyberTextMuted : lightTextMuted;
  static Color get textMuted => isDark ? cyberTextDim : lightTextDim;

  // Status Colors (Matching Phase 1 Contract)
  static const Color onTime = Color(0xFF10B981);        // Emerald 500
  static const Color late = Color(0xFFF59E0B);          // Amber 500
  static const Color absent = Color(0xFFF43F5E);        // Rose 500
  static const Color onLeave = Color(0xFF0EA5E9);       // Sky Blue 500
  static const Color weekend = Color(0xFF94A3B8);       // Slate 400

  // Dynamic Status Tints: In Dark Mode use dark tinted badges, in Light Mode use pastel 50-shades
  static Color get onTimeLight => isDark ? const Color(0x1F10B981) : const Color(0xFFECFDF5);
  static Color get lateLight => isDark ? const Color(0x24F59E0B) : const Color(0xFFFFFBEB);
  static Color get absentLight => isDark ? const Color(0x24FF2D95) : const Color(0xFFFFF1F2);
  static Color get onLeaveLight => isDark ? const Color(0x240EA5E9) : const Color(0xFFF0F9FF);
  static Color get weekendLight => isDark ? const Color(0x2494A3B8) : const Color(0xFFF1F5F9);

  // Explicit Dark Presets (if needed directly)
  static const Color darkBackground = cyberCanvas;
  static const Color darkSurface = cyberCard;
  static const Color darkCardBorder = cyberBorder;
  static const Color darkTextPrimary = cyberTextMain;
  static const Color darkTextSecondary = cyberTextMuted;
  static const Color darkTextMuted = cyberTextDim;
}
