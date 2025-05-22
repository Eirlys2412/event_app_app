import 'dart:convert';
import 'package:event_app/constants/apilist.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = api_event_register; 

  static Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse("$baseUrl/$endpoint");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(data),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception("Lỗi khi gọi API: ${response.statusCode}");
    }
  }
}
