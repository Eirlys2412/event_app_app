
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/pref_data.dart';
import '../constants/apilist.dart';
import '../models/user.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: base,
    headers: {'Content-Type': 'application/json'},
    connectTimeout: Duration(seconds: 10), // hoặc cao hơn
    receiveTimeout: Duration(seconds: 15), // 3 giây cho nhận phản hồi
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
        // Hỗ trợ lấy token nơi API có thể trả về String hoặc Map {token: String}
        final dynamic rawToken = response.data['token'];
        final String? token = rawToken is String
            ? rawToken
            : (rawToken is Map ? rawToken['token']?.toString() : null);
        final userData = response.data['user'];
        final userId = response.data['user']['id'];
        final role = response.data['user']['role'];

        print(userId);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', userId);
        // userId đã lưu trong saveLoginState()

        if (token != null && token.isNotEmpty) {
          await PrefData.saveLoginState(
              token, userData, userId); // Lưu thông tin đăng nhập
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
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      print("Register response: ${response.data}");

      if (_isSuccessful(response)) {
        final dynamic userRaw = response.data['user'];
        final dynamic tokenRaw = response.data['token'];

        if (userRaw is Map<String, dynamic>) {
          final int userId = userRaw['id'];
          final String role = userRaw['role'];
          final String token = tokenRaw.toString();

          // Lưu thông tin vào SharedPreferences
          await PrefData.saveLoginState(token, userRaw, userId);

          return {'userId': userId, 'token': token, 'role': role};
        } else {
          throw Exception("Phản hồi API không hợp lệ: user không phải Map.");
        }
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
