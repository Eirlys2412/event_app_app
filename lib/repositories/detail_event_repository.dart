import 'dart:convert';

import 'package:event_app/constants/apilist.dart';
import 'package:http/http.dart' as http;
import 'package:event_app/models/event.dart' show Detailevent;
import 'package:event_app/constants/pref_data.dart'; // Import PrefData

class DetailEventRepository {
  final String baseUrl;

  DetailEventRepository({required this.baseUrl});

  Future<Detailevent> fetchDetailEvent(int id) async {
    final token = await PrefData.getToken(); // Lấy token
    final url = api_event_detail(id); // Lấy URL đầy đủ
    print('Fetching detail from URL: $url'); // In URL ra log
    final response = await http.get(
      Uri.parse(url), // Sử dụng biến url
      headers: {'Authorization': 'Bearer $token'}, // Thêm header xác thực
    );

    if (response.statusCode == 200) {
      print('Successfully loaded detail event.'); // Log thành công
      print(
          'Success response body: ${response.body}'); // In body response thành công
      final data = jsonDecode(response.body); // Giải mã JSON
      return Detailevent.fromJson(data['data']); // parse data -> Detailevent
    } else {
      print('Error loading detail event: ${response.statusCode}');
      print('Error response body: ${response.body}');
      throw Exception('Failed to load detail event');
    }
  }
}
