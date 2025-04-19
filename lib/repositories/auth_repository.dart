import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/pref_data.dart';
import '../constants/apilist.dart';
import '../models/user.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api/v1',
    headers: {'Content-Type': 'application/json'},
    connectTimeout: const Duration(seconds: 5), // 5 giây cho kết nối
    receiveTimeout: const Duration(seconds: 3), // 3 giây cho nhận phản hồi
  ));

  /// LOGIN
  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post(
        api_login,
        data: {
          'email': username,
          'password': password,
        },
      );

      print('Login status: ${response.statusCode}');
      print('Login response: ${response.data}');

      if (_isSuccessful(response)) {
        final token = response.data['token']?['token'];
        final userData = response.data['user'];
        final role = response.data['user']['role'];

        if (token != null && token.isNotEmpty) {
          await PrefData.saveLoginState(
              token, userData); // Lưu thông tin đăng nhập
          return true;
        } else {
          print('Token missing or empty');
        }
      }

      return false;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  /// REGISTER
  Future<Map<String, dynamic>> register(User user) async {
    try {
      final response = await _dio.post(
        api_register,
        data: user.toJson(), // Chuyển đối tượng User thành JSON
      );

      if (response.statusCode == 200) {
        final userId = response.data['user']['id'];
        final token = response.data['token'];
        final role = response.data['user']['role'];

        // Lưu thông tin người dùng vào SharedPreferences
        await PrefData.saveLoginState(token, response.data['user']);

        return {'userId': userId, 'token': token, 'role': role};
      } else {
        throw Exception(response.data['message'] ?? 'Đăng ký thất bại.');
      }
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  /// LOGOUT
  Future<bool> logout() async {
    try {
      final token = await PrefData.getToken();

      if (token == null || token.isEmpty) {
        await PrefData.clearUserData();
        return true;
      }

      final response = await _dio.post(
        api_logout,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 401) {
        await PrefData.clearUserData(); // Xóa dữ liệu khi logout
        return true;
      } else {
        print('Logout failed: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await PrefData.clearUserData();
        return true;
      }
      _handleError(e);
      return false;
    }
  }

  /// Check login status
  Future<bool> isLoggedIn() async {
    final token = await PrefData.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Utility: handle errors
  void _handleError(dynamic error) {
    if (error is DioException) {
      print('DioException: ${error.message}');
      if (error.response != null) {
        print('Response data: ${error.response?.data}');
      }
      // Có thể thêm thông báo lỗi cho người dùng hoặc thực hiện retry ở đây
    } else {
      print('Unexpected error: $error');
      // Thông báo lỗi chung cho người dùng
    }
  }

  /// Utility: check success
  bool _isSuccessful(Response response) {
    return response.statusCode == 200 && response.data['success'] == true;
  }

  /// Get configured Dio client (if needed outside)
  Future<Dio> getDioClient() async {
    return _dio;
  }
}
