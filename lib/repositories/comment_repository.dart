import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_app/constants/apilist.dart'; // Import apilist.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:event_app/models/comment.dart'; // Giả định bạn có model Comment
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:event_app/constants/pref_data.dart';

class CommentRepository {
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await PrefData.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Comment>> fetchComments(
      {required int itemId, required String itemCode}) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse('$api_getComment?item_id=$itemId&item_type=$itemCode'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Fetched data from API: $data');
      final List commentsJson = data['data'] ?? [];
      return commentsJson.map((e) => Comment.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi khi lấy bình luận');
    }
  }

  Future<void> createComment(Map<String, dynamic> data) async {
    final headers = await _getAuthHeaders();
    final response = await http.post(
      Uri.parse(api_createComment),
      body: json.encode(data),
      headers: headers,
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Lỗi khi tạo bình luận');
    }
  }

  Future<void> deleteComment(int id) async {
    final headers = await _getAuthHeaders();
    final response = await http.delete(
      Uri.parse(api_deleteComment(id)),
      headers: headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Lỗi khi xóa bình luận');
    }
  }

  void _handleError(http.Response response) {
    print('Error: ${response.statusCode} - ${response.body}');
  }

  void _printException(dynamic e) {
    print('Exception: $e');
  }

  // Cập nhật bình luận
  Future<Comment> updateComment({
    required int id,
    required String content,
  }) async {
    final headers = await _getAuthHeaders();
    try {
      final response = await http.put(
        Uri.parse(api_updateComment(id)),
        headers: headers,
        body: jsonEncode({'content': content}),
      );

      print(
          'Update comment response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        return Comment.fromJson(jsonDecode(response.body));
      } else {
        _handleError(response);
      }
    } catch (e) {
      _printException(e);
      throw Exception('Failed to update comment');
    }
    throw Exception('Failed to update comment');
  }

  Future<void> saveLikedComment(int userId, int commentId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> likedComments =
        prefs.getStringList('liked_comments_$userId') ?? [];
    if (!likedComments.contains(commentId.toString())) {
      likedComments.add(commentId.toString());
      await prefs.setStringList('liked_comments_$userId', likedComments);
    }
  }

  Future<void> removeLikedComment(int userId, int commentId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> likedComments =
        prefs.getStringList('liked_comments_$userId') ?? [];
    likedComments.remove(commentId.toString());
    await prefs.setStringList('liked_comments_$userId', likedComments);
  }

  // Trong comment_repository.dart
  Future<List<int>> getLikedCommentIds(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> likedComments =
        prefs.getStringList('liked_comments_$userId') ?? [];
    return likedComments.map((id) => int.parse(id)).toList();
  }
}

// Provider cho repository
final commentRepositoryProvider = Provider((ref) => CommentRepository());
