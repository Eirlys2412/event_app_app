import 'dart:convert';
import 'package:event_app/constants/apilist.dart';
import 'package:http/http.dart' as http;
import '../models/event_register.dart';
import '../models/my_event.dart';
import '../constants/pref_data.dart';

class EventRegistrationRepository {
  final String baseUrl;

  EventRegistrationRepository({required this.baseUrl});

  Future<EventRegistration> register({
    required int eventId,
    String? reason,
    required String token,
  }) async {
    final url = Uri.parse(api_event_register);

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'event_id': eventId,
        'reason': reason,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body)['data'];
      return EventRegistration.fromJson(data);
    } else {
      throw Exception('Đăng ký thất bại: ${response.body}');
    }
  }

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

  Future<List<MyEventRegistration>> fetchMyRegistrations() async {
    // Lấy token từ PrefData
    final headers = await _getAuthHeaders();

    // In log headers để debug
    print('Headers gửi lên: $headers');

    // Đảm bảo endpoint đúng (nên dùng api_join hoặc api_event_registrations_my_registrations tùy backend)
    final url = Uri.parse(
        api_join); // hoặc Uri.parse(api_event_registrations_my_registrations);

    print('Gọi API: $url');

    final response = await http.get(
      url,
      headers: headers,
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      try {
        return data.map((e) => MyEventRegistration.fromJson(e)).toList();
      } catch (e) {
        print('Lỗi parse danh sách sự kiện: $e');
        throw Exception('Lỗi parse model: $e');
      }
    } else if (response.statusCode == 401) {
      // Nếu bị lỗi xác thực, thông báo rõ ràng
      throw Exception('Bạn chưa đăng nhập hoặc token đã hết hạn!');
    } else {
      throw Exception(
          'Lỗi khi lấy danh sách sự kiện đã đăng ký: ${response.body}');
    }
  }
}
