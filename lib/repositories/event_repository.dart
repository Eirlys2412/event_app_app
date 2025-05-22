// TODO Implement this library.import 'dart:convert';
import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/event.dart'; // Import Event model
import '../constants/apilist.dart';
import '../constants/pref_data.dart';

class EventRepository {
  Future<Map<String, String>> _getAuthHeaders() async {
    try {
      final token = await PrefData.getToken();
      print(
          'Auth token: ${token?.substring(0, 10)}...'); // Debug log - only show first 10 chars

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

  Future<List<Event>> fetchEvents() async {
    final response = await http.get(Uri.parse(api_event));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List eventsJson = data['data'] ?? [];
      return eventsJson.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi khi lấy danh sách sự kiện');
    }
  }

  Future<void> createEvent(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse(api_event),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Lỗi khi tạo sự kiện');
    }
  }

  Future<void> deleteEvent(int id) async {
    final response = await http.delete(Uri.parse('$api_event/$id'));
    if (response.statusCode != 200) {
      throw Exception('Lỗi khi xóa sự kiện');
    }
  }

  // Có thể thêm updateEvent nếu cần
}
