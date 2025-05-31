import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends StateNotifier<ThemeState> {
  ThemeNotifier() : super(ThemeState()) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('selected_theme');
    final savedThemeMode = prefs.getString('theme_mode');

    if (savedTheme != null && state.themePresets.containsKey(savedTheme)) {
      state = ThemeState(
        selectedTheme: savedTheme,
        themeMode: ThemeMode.values.firstWhere(
          (e) => e.toString() == savedThemeMode,
          orElse: () => ThemeMode.system,
        ),
      );
    } else {
      // Nếu không có theme đã lưu, lưu theme mặc định
      await prefs.setString('selected_theme', state.selectedTheme);
      await prefs.setString('theme_mode', state.themeMode.toString());
    }
  }

  Future<void> changeTheme(String themeName) async {
    if (state.themePresets.containsKey(themeName)) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_theme', themeName);
      state = ThemeState(
        selectedTheme: themeName,
        themeMode: state.themeMode,
      );
    }
  }

  Future<void> toggleTheme() async {
    final newMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', newMode.toString());
    state = ThemeState(
      selectedTheme: state.selectedTheme,
      themeMode: newMode,
    );
  }
}

class ThemeState {
  final Map<String, List<Color>> themePresets = {
    '🌊 Xanh Biển': [Color(0xFF2196F3), Color(0xFF03A9F4)],
    '💜 Tím Tối Giản': [Color(0xFF6A5AE0), Color(0xFF9575CD)],
    '🍀 Thiên Nhiên': [Color(0xFF4CAF50), Color(0xFF81C784)],
    '🖤 Tối Sang': [Color(0xFF121212), Color(0xFF1F1F1F)],
    '🎯 Đỏ Năng Lượng': [Color(0xFFE53935), Color(0xFFEF5350)],
    '☁️ Sáng Nhẹ': [Color(0xFFFFFFFF), Color(0xFFF0F0F0)],
    '🌅 Cam Dịu': [Color(0xFFFF7043), Color(0xFFFFAB91)],
    '🪵 Gỗ Nâu Nhẹ': [Color(0xFF8D6E63), Color(0xFFBCAAA4)],
    '🟦 Xanh Công Nghệ': [Color(0xFF1976D2), Color(0xFF64B5F6)],
    '⚙️ Xám Công Nghiệp': [Color(0xFF607D8B), Color(0xFFCFD8DC)],
  };

  final String selectedTheme;
  final ThemeMode themeMode;

  ThemeState({
    this.selectedTheme = '💜 Tím Tối Giản',
    this.themeMode = ThemeMode.system,
  });

  Color get primaryColor => themePresets[selectedTheme]![0];
  Color get accentColor => themePresets[selectedTheme]![1];
  Color get backgroundColor => themeMode == ThemeMode.dark
      ? const Color(0xFF121212)
      : const Color(0xFFF4F3FD);
  Color get surfaceColor =>
      themeMode == ThemeMode.dark ? const Color(0xFF1F1F1F) : Colors.white;

  // Text colors
  Color get primaryTextColor =>
      themeMode == ThemeMode.dark ? Colors.white : const Color(0xFF212121);
  Color get secondaryTextColor => themeMode == ThemeMode.dark
      ? const Color(0xFFEEEEEE)
      : const Color(0xFF424242);
  Color get bodyTextColor => themeMode == ThemeMode.dark
      ? const Color(0xFFDDDDDD)
      : const Color(0xFF333333);
  Color get captionTextColor => themeMode == ThemeMode.dark
      ? const Color(0xFFAAAAAA)
      : const Color(0xFF888888);

  // Button colors
  Color get buttonColor => primaryColor;
  Color get buttonTextColor => Colors.white;

  // AppBar colors
  Color get appBarColor =>
      themeMode == ThemeMode.dark ? const Color(0xFF1F1F1F) : primaryColor;
  Color get appBarTextColor => Colors.white;

  // Navigation bar colors
  Color get navBarColor =>
      themeMode == ThemeMode.dark ? const Color(0xFF1F1F1F) : Colors.white;
  Color get navBarSelectedColor => primaryColor;
  Color get navBarUnselectedColor => const Color(0xFF9E9E9E);

  // Gradient colors
  Color get gradientStart => primaryColor;
  Color get gradientEnd => accentColor;

  Color get valueTextColor => themeMode == ThemeMode.dark
      ? const Color(0xFF4CAF50)
      : const Color(0xFFF44336);

  // Error color
  Color get errorColor => themeMode == ThemeMode.dark
      ? const Color(0xFFCF6679)
      : const Color(0xFFB00020);

  // Card and Dialog colors
  Color get cardColor =>
      themeMode == ThemeMode.dark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get dialogBackgroundColor =>
      cardColor; // Use card color for dialog background
  Color get dialogTextColor =>
      themeMode == ThemeMode.dark ? Colors.white : Colors.black;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeState>((ref) {
  return ThemeNotifier();
});
