// TODO Implement this library.import 'dart:convert';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:event_app/models/event.dart'; // Import Event model
import 'package:event_app/constants/apilist.dart';
class EventRepository {
  Future<List<Event>> fetchEvents() async {
    final url = Uri.parse(api_event);
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Chuyển đổi dữ liệu từ Map sang List<Event>
          List<Event> events = (data['data'] as List)
              .map((eventJson) => Event.fromJson(eventJson))
              .toList();
          return events;
        } else {
          throw Exception(data['message'] ?? 'Lỗi khi lấy danh sách sự kiện.');
        }
      } else {
        throw Exception('Lỗi HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }
}
