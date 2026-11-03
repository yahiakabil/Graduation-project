import 'package:flutter/material.dart';

@immutable
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // Backgrounds & Surfaces
  final Color bgCanvas;
  final Color bgCard;
  final Color bgCardSubtle;
  final Color borderSubtle;
  final Color borderActive;

  // Brand / Actions
  final Color primary;
  final Color primaryLight;
  final Color accent;
  final Color accentLight;

  // Text
  final Color textMain;
  final Color textMuted;
  final Color textDim;

  // Status
  final Color statusSuccess;
  final Color statusWarning;
  final Color statusDanger;

  const AppColorsExtension({
    required this.bgCanvas,
    required this.bgCard,
    required this.bgCardSubtle,
    required this.borderSubtle,
    required this.borderActive,
    required this.primary,
    required this.primaryLight,
    required this.accent,
    required this.accentLight,
    required this.textMain,
    required this.textMuted,
    required this.textDim,
    required this.statusSuccess,
    required this.statusWarning,
    required this.statusDanger,
  });

  // Light Preset: Nordic Pro Light (from your HTML designs)
  static const light = AppColorsExtension(
    bgCanvas: Color(0xFFF1F5F9),        // --bg-canvas: #f1f5f9
    bgCard: Color(0xFFFFFFFF),          // --bg-card: #ffffff
    bgCardSubtle: Color(0xFFF8FAFC),    // --bg-card-subtle: #f8fafc
    borderSubtle: Color(0xFFE2E8F0),    // --border-subtle: #e2e8f0
    borderActive: Color(0xFF4F46E5),    // --border-active: #4f46e5
    primary: Color(0xFF4F46E5),         // --color-primary: #4f46e5 (Indigo)
    primaryLight: Color(0xFFEEF2FF),    // rgba(79, 70, 229, 0.1)
    accent: Color(0xFF059669),          // --color-accent: #059669 (Emerald)
    accentLight: Color(0xFFECFDF5),     // rgba(5, 150, 105, 0.1)
    textMain: Color(0xFF0F172A),        // --text-main: #0f172a
    textMuted: Color(0xFF475569),       // --text-muted: #475569
    textDim: Color(0xFF94A3B8),         // --text-dim: #94a3b8
    statusSuccess: Color(0xFF10B981),
    statusWarning: Color(0xFFF59E0B),
    statusDanger: Color(0xFFF43F5E),
  );

  // Dark Preset: Cyber Neon (from your HTML designs)
  static const dark = AppColorsExtension(
    bgCanvas: Color(0xFF0A0A0A),        // --bg-canvas: #0a0a0a (Jet Black)
    bgCard: Color(0xFF18181B),          // --bg-card: #18181b (Card zinc-900)
    bgCardSubtle: Color(0xFF222226),    // --bg-card-subtle: #222226
    borderSubtle: Color(0xFF2E2E33),    // --border-subtle: #2e2e33
    borderActive: Color(0xFF007BA7),    // --border-active: #007ba7 (Cerulean)
    primary: Color(0xFF007BA7),         // --color-primary: #007ba7 (Electric Blue)
    primaryLight: Color(0x26007BA7),    // rgba(0, 123, 167, 0.15)
    accent: Color(0xFFFF2D95),          // --color-accent: #ff2d95 (Cyber Rose)
    accentLight: Color(0x26FF2D95),     // rgba(255, 45, 149, 0.15)
    textMain: Color(0xFFFFFFFF),        // --text-main: #ffffff
    textMuted: Color(0xFFA1A1AA),       // --text-muted: #a1a1aa
    textDim: Color(0xFF71717A),         // --text-dim: #71717a
    statusSuccess: Color(0xFF10B981),
    statusWarning: Color(0xFFF59E0B),
    statusDanger: Color(0xFFFF2D95),
  );

  @override
  AppColorsExtension copyWith({
    Color? bgCanvas,
    Color? bgCard,
    Color? bgCardSubtle,
    Color? borderSubtle,
    Color? borderActive,
    Color? primary,
    Color? primaryLight,
    Color? accent,
    Color? accentLight,
    Color? textMain,
    Color? textMuted,
    Color? textDim,
    Color? statusSuccess,
    Color? statusWarning,
    Color? statusDanger,
  }) {
    return AppColorsExtension(
      bgCanvas: bgCanvas ?? this.bgCanvas,
      bgCard: bgCard ?? this.bgCard,
      bgCardSubtle: bgCardSubtle ?? this.bgCardSubtle,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderActive: borderActive ?? this.borderActive,
      primary: primary ?? this.primary,
      primaryLight: primaryLight ?? this.primaryLight,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      textMain: textMain ?? this.textMain,
      textMuted: textMuted ?? this.textMuted,
      textDim: textDim ?? this.textDim,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusWarning: statusWarning ?? this.statusWarning,
      statusDanger: statusDanger ?? this.statusDanger,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      bgCanvas: Color.lerp(bgCanvas, other.bgCanvas, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgCardSubtle: Color.lerp(bgCardSubtle, other.bgCardSubtle, t)!,
      borderSubtle: Color.lerp(borderSubtle, other.borderSubtle, t)!,
      borderActive: Color.lerp(borderActive, other.borderActive, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentLight: Color.lerp(accentLight, other.accentLight, t)!,
      textMain: Color.lerp(textMain, other.textMain, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      textDim: Color.lerp(textDim, other.textDim, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusDanger: Color.lerp(statusDanger, other.statusDanger, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColorsExtension get colors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.light;
}
