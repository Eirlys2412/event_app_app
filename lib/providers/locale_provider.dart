import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// StateNotifier để quản lý Locale
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('vi', '')) {
    _loadLocaleFromPreferences(); // Tải ngôn ngữ đã lưu khi khởi tạo
  }

  Future<void> setLocale(Locale locale) async {
    state = locale; // Cập nhật trạng thái ngôn ngữ
    await _saveLocaleToPreferences(locale); // Lưu vào SharedPreferences
  }

  // Hàm lưu ngôn ngữ vào SharedPreferences
  Future<void> _saveLocaleToPreferences(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('localeLanguageCode', locale.languageCode);
    await prefs.setString('localeCountryCode', locale.countryCode ?? '');
  }

  // Hàm tải ngôn ngữ từ SharedPreferences
  Future<void> _loadLocaleFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('localeLanguageCode') ?? 'vi';
    final countryCode = prefs.getString('localeCountryCode');

    state =
        Locale(languageCode, countryCode?.isEmpty == true ? null : countryCode);
  }
}

// Riverpod Provider để truy cập LocaleNotifier
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);
