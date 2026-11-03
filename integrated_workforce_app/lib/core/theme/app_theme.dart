import 'package:flutter/material.dart';
import 'app_colors_extension.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColorsExtension.light.primary,
      cardColor: AppColorsExtension.light.bgCard,
      scaffoldBackgroundColor: AppColorsExtension.light.bgCanvas,
      fontFamily: 'Roboto',
      extensions: const [
        AppColorsExtension.light,
      ],
      colorScheme: ColorScheme.light(
        primary: AppColorsExtension.light.primary,
        secondary: AppColorsExtension.light.accent,
        surface: AppColorsExtension.light.bgCard,
        error: AppColorsExtension.light.statusDanger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsExtension.light.bgCard,
        elevation: 0.0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColorsExtension.light.textMain),
        titleTextStyle: TextStyle(
          color: AppColorsExtension.light.textMain,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColorsExtension.light.bgCard,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColorsExtension.light.borderSubtle),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColorsExtension.light.bgCard,
        selectedItemColor: AppColorsExtension.light.primary,
        unselectedItemColor: AppColorsExtension.light.textMuted,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsExtension.light.primary,
          foregroundColor: Colors.white,
          elevation: 2.0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsExtension.light.bgCardSubtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorsExtension.light.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorsExtension.light.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorsExtension.light.primary, width: 2),
        ),
        hintStyle: TextStyle(
          color: AppColorsExtension.light.textDim,
          fontSize: 13,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColorsExtension.dark.primary,
      cardColor: AppColorsExtension.dark.bgCard,
      scaffoldBackgroundColor: AppColorsExtension.dark.bgCanvas,
      fontFamily: 'Roboto',
      extensions: const [
        AppColorsExtension.dark,
      ],
      colorScheme: ColorScheme.dark(
        primary: AppColorsExtension.dark.primary,
        secondary: AppColorsExtension.dark.accent,
        surface: AppColorsExtension.dark.bgCard,
        error: AppColorsExtension.dark.statusDanger,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsExtension.dark.bgCard,
        elevation: 0.0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColorsExtension.dark.textMain),
        titleTextStyle: TextStyle(
          color: AppColorsExtension.dark.textMain,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardTheme(
        color: AppColorsExtension.dark.bgCard,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColorsExtension.dark.borderSubtle),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColorsExtension.dark.bgCard,
        selectedItemColor: AppColorsExtension.dark.accent,
        unselectedItemColor: AppColorsExtension.dark.textDim,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsExtension.dark.primary,
          foregroundColor: Colors.white,
          elevation: 2.0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsExtension.dark.bgCardSubtle,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorsExtension.dark.borderSubtle),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorsExtension.dark.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColorsExtension.dark.accent, width: 2),
        ),
        hintStyle: TextStyle(
          color: AppColorsExtension.dark.textDim,
          fontSize: 13,
        ),
      ),
    );
  }
}
