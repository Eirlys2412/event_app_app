import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../constants/pref_data.dart';
import 'dart:io' show Platform;

class LikeRepository {
  Future<bool> toggleLike(String type, int id) async {
    final token = await PrefData.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token không tồn tại. Vui lòng đăng nhập lại.');
    }

    // Determine host for different platforms
    final host = kIsWeb
        ? 'localhost:8000'
        : (Platform.isAndroid ? '10.0.2.2:8000' : '127.0.0.1:8000');
    final url = Uri.http(host, '/api/v1/likes/toggle');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'type': type, // Đây là chuẩn backend đang yêu cầu
        'object_id': id, // id của blog hoặc event
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['liked'] ?? false; // Trả về true/false trạng thái
    } else {
      throw Exception('Lỗi toggle like: ${response.statusCode}');
    }
  }

  Future<bool> toggleCommentLike(int commentId) async {
    final token = await PrefData.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Token không tồn tại. Vui lòng đăng nhập lại.');
    }

    // Determine host for different platforms
    final host = kIsWeb
        ? 'localhost:8000'
        : (Platform.isAndroid ? '10.0.2.2:8000' : '127.0.0.1:8000');
    final url = Uri.http(host, '/api/v1/comments/$commentId/toggle-like');

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['is_liked'] ?? false;
    } else {
      throw Exception('Lỗi toggle like comment: ${response.statusCode}');
    }
  }
}
