import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/apilist.dart';
import '../constants/pref_data.dart';

class PostService {
  static Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final token = await PrefData.getToken();
      final response = await http.get(
        Uri.parse(api_getblogcat),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data'].map((item) => {
                'id': item['id']?.toString() ?? '',
                'name': item['name']?.toString() ?? '',
              }));
        }
        return [];
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      throw Exception('Error getting categories: $e');
    }
  }

  static Future<List<Map<String, dynamic>>> getTags() async {
    try {
      final token = await PrefData.getToken();
      final response = await http.get(
        Uri.parse(api_tag),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data'].map((item) => {
                'id': item['id']?.toString() ?? '',
                'name': item['name']?.toString() ?? '',
              }));
        }
        return [];
      }
      throw Exception('Failed to load tags');
    } catch (e) {
      throw Exception('Error getting tags: $e');
    }
  }

  static Future<Map<String, dynamic>> createPost({
    required String title,
    required String content,
    required String categoryId,
    String? summary,
    List<String>? tagIds,
    String? status,
    String? imageBase64,
  }) async {
    try {
      final token = await PrefData.getToken();
      final response = await http.post(
        Uri.parse(api_postblog),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'title': title,
          'content': content,
          'category_id': categoryId,
          'summary': summary,
          'tag_ids': tagIds,
          'status': status,
          'image': imageBase64,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw Exception('Failed to create post');
    } catch (e) {
      throw Exception('Error creating post: $e');
    }
  }
}
