import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _themePrefKey = 'app_theme_mode';

  ThemeCubit() : super(ThemeMode.light) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_themePrefKey) ?? false;
      AppColors.isDarkNotifier.value = isDark;
      emit(isDark ? ThemeMode.dark : ThemeMode.light);
    } catch (_) {}
  }

  Future<void> toggleTheme(bool isDark) async {
    AppColors.isDarkNotifier.value = isDark;
    emit(isDark ? ThemeMode.dark : ThemeMode.light);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePrefKey, isDark);
    } catch (_) {}
  }
}
