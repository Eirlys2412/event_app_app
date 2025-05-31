import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/apilist.dart';
import '../constants/pref_data.dart';
import '../models/statistics.dart';

class StatisticsRepository {
  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final token = await PrefData.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Vui lòng đăng nhập để thực hiện chức năng này');
      }
      return {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };
    } catch (e) {
      print('Error getting auth headers: $e');
      throw Exception('Lỗi xác thực: ${e.toString()}');
    }
  }

  Future<StatisticsResponse> getStatisticsTop() async {
    final url = Uri.parse(api_statistics_top);
    final headers = await _getAuthHeaders();

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      print('Statistics API Response: $body');
      return StatisticsResponse.fromJson(body);
    } else {
      throw Exception(
          'Lỗi lấy dữ liệu thống kê: ${response.statusCode} ${response.body}');
    }
  }
}
