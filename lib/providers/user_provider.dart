import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider lưu role của người dùng
final userRoleProvider = StateProvider<String?>((ref) => null);

/// Hàm lưu userId
Future<void> saveUserId(int userId) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setInt('userId', userId);
}

/// Hàm lấy userId
Future<int?> getUserId() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getInt('userId');
}

/// Hàm lưu role
Future<void> saveUserRole(String role) async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  await pref.setString('role', role); // key phải khớp
}

/// Hàm lấy role
Future<String?> getUserRole() async {
  SharedPreferences pref = await SharedPreferences.getInstance();
  return pref.getString('role');
}

/// Hàm load role và cập nhật provider
Future<void> loadUserRole(WidgetRef ref) async {
  final role = await getUserRole();
  ref.read(userRoleProvider.notifier).state = role;
}
