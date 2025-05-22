import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../constants/apilist.dart';
import '../models/blog.dart';
import '../constants/pref_data.dart';

class UserRepository {
  UserRepository();
  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final token = await PrefData.getToken();
      print('Token lấy ra từ PrefData: $token');

      if (token == null || token.isEmpty) {
        throw Exception('Vui lòng đăng nhập để thực hiện chức năng này');
      }

      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('Error getting auth headers: $e'); // Debug log
      throw Exception('Lỗi xác thực: ${e.toString()}');
    }
  }

  Future<UserModel> fetchUserProfile(int userId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(api_profile_user(userId)),
      headers: headers,
    );

    print('API URL: ${api_profile_user(userId)}');
    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'];
      return UserModel.fromJson(data);
    } else {
      throw Exception('Lỗi khi lấy thông tin hồ sơ người dùng');
    }
  }
}
