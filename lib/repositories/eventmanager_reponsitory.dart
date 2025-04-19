import 'dart:convert'; // Để xử lý JSON
import 'package:dio/dio.dart';
import '../models/eventmanager.dart';
import '../constants/apilist.dart';
import '../constants/pref_data.dart';

class EventManagerRepository {
  final Dio _dio;

  EventManagerRepository() : _dio = Dio() {
    _dio.options.followRedirects = false; // Không tự động theo dõi redirect
    _dio.options.validateStatus = (status) {
      return status != null && status < 500; // Chỉ chấp nhận các mã trạng thái < 500
    };
  }

  Future<EventManager?> createEventManager({
    required String slug,
    required int userId,
  }) async {
    try {
      // Lấy token từ PrefData
      final token = await PrefData.getToken();
      
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // Log request body để kiểm tra
      final requestBody = {
        "slug": slug,
        "user_id": userId,
      };
      
      print('Request body: ${json.encode(requestBody)}');

      final response = await _dio.post(
        api_teacher,
        data: json.encode(requestBody),
        options: Options(headers: headers),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.data}');

      // Xử lý mã trạng thái 302 (phiên hết hạn)
      if (response.statusCode == 302) {
        await PrefData.clearUserData(); // Clear local data in both cases
        throw Exception('Session expired. Please login again.');
      }

      // Xử lý thành công
      if (response.statusCode == 201 || response.statusCode == 200) {
        return EventManager.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? "Failed to create event manager");
      }
    } on DioException catch (e) {
      // Xử lý lỗi mạng
      if (e.response?.statusCode == 302) {
        await PrefData.clearUserData(); // Clear local data in both cases
        throw Exception('Session expired. Please login again.');
      }
      throw Exception(e.message ?? 'Network error occurred');
    }
  }
}