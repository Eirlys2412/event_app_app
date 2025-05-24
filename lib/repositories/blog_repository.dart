import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/blog.dart';
import '../constants/pref_data.dart';
import '../constants/apilist.dart';
import '../models/blog_detail.dart';
import '../models/blog_approved.dart';

class BlogRepository {
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

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final url = Uri.parse(api_getblogcat);
      final headers = await _getAuthHeaders();

      print('Fetching categories from: $url'); // Debug log
      final response = await http.get(url, headers: headers);
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        print('Decoded response: $decoded'); // Debug log

        List<dynamic> data = [];

        if (decoded is Map<String, dynamic> && decoded.containsKey('data')) {
          data = List<dynamic>.from(decoded['data'] ?? []);
        } else if (decoded is List) {
          data = List<dynamic>.from(decoded);
        }

        print('Extracted data: $data'); // Debug log

        final result = data
            .map((item) {
              final id = item['id']?.toString() ?? '';
              final title =
                  item['title']?.toString() ?? item['name']?.toString() ?? '';
              print(
                  'Processing category - id: $id, title: $title'); // Debug log
              return {
                'id': id,
                'title': title,
              };
            })
            .where(
                (item) => item['id']!.isNotEmpty && item['title']!.isNotEmpty)
            .toList();

        print('Final processed categories: $result'); // Debug log
        return result;
      }
      throw Exception('Failed to load categories');
    } catch (e) {
      print('Error in getCategories: $e'); // Debug log
      throw Exception('Error getting categories: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTags() async {
    try {
      final url = Uri.parse(api_tag);
      final headers = await _getAuthHeaders();

      print('Fetching tags from URL: $url'); // Debug log
      final response = await http.get(url, headers: headers);
      print('Tag response status: ${response.statusCode}'); // Debug log
      print('Tag response body: ${response.body}'); // Debug log

      if (response.statusCode == 200) {
        final dynamic decoded = json.decode(response.body);
        print('Decoded tag response: $decoded'); // Debug log

        List<dynamic> data = [];

        if (decoded is Map<String, dynamic>) {
          // If the response is wrapped in a data field
          data = List<dynamic>.from(decoded['data'] ?? []);
        } else if (decoded is List) {
          // If the response is a direct array
          data = List<dynamic>.from(decoded);
        }

        print('Extracted tag data before processing: $data'); // Debug log

        final result = data
            .map((item) {
              // Convert the entire item to string for debugging
              print('Processing tag item: $item'); // Debug log

              final id = item['id']?.toString() ?? '';
              final title =
                  item['title']?.toString() ?? item['name']?.toString() ?? '';

              print('Processed tag - id: $id, title: $title'); // Debug log

              return {
                'id': id,
                'title': title,
              };
            })
            .where(
                (item) => item['id']!.isNotEmpty && item['title']!.isNotEmpty)
            .toList();

        print('Final processed tags: $result'); // Debug log
        return result;
      }
      throw Exception('Failed to load tags');
    } catch (e) {
      print('Error in getTags: $e'); // Debug log
      throw Exception('Error getting tags: $e');
    }
  }

  Future<List<Blog>> getPosts() async {
    final url = Uri.parse(api_getblog);
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      final List<dynamic> blogsJson = body['data'] ?? [];
      return blogsJson.map((json) => Blog.fromJson(json)).toList();
    } else {
      throw Exception("Lỗi API: ${response.statusCode} ${response.body}");
    }
  } // lấy danh sách bài viết

// tạo bài viết
  Future<void> createPost(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse(api_postblog);
      final headers = await _getAuthHeaders();

      // Prepare the request data
      final requestData = Map<String, dynamic>.from(data);

      // Remove image field if it's null or empty to avoid default image processing
      if (requestData['image'] == null ||
          requestData['image'].toString().isEmpty) {
        requestData.remove('image');
      }

      print('Creating post with URL: $url'); // Debug log
      print('Request data: $requestData'); // Debug log
      print('Headers: $headers'); // Debug log

      final response = await http.post(
        url,
        headers: {
          ...headers,
          'Accept': 'application/json',
        },
        body: json.encode(requestData),
      );

      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log

      if (response.statusCode == 302) {
        throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
      }

      if (response.statusCode != 200 && response.statusCode != 201) {
        try {
          final errorBody = json.decode(response.body);
          final errorMessage = errorBody['message'] ?? 'Lỗi không xác định';
          throw Exception('Lỗi tạo bài viết: $errorMessage');
        } catch (e) {
          throw Exception('Lỗi tạo bài viết: ${response.body}');
        }
      }

      // Check if response is JSON
      try {
        final responseData = json.decode(response.body);
        print('Response data: $responseData'); // Debug log
      } catch (e) {
        print('Response is not JSON: $e'); // Debug log
      }
    } catch (e) {
      print('Error in createPost: $e'); // Debug log
      throw Exception('Lỗi tạo bài viết: ${e.toString()}');
    }
  }

// xóa bài viết
  Future<void> deletePost(int id) async {
    final url = Uri.parse(api_deleteblog(id));
    final headers = await _getAuthHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode != 200) {
      throw Exception(
          "Lỗi xóa bài viết: ${response.statusCode} ${response.body}");
    }
  }

// logcj bài viết theo id/0r slug
  Future<BlogDetail> getBlogDetail({int? id, String? slug}) async {
    final uri = Uri.parse(api_getblogidslug);
    final response = await http.post(uri, body: {
      if (id != null) 'id': id.toString(),
      if (slug != null) 'slug': slug,
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return BlogDetail.fromJson(
          data['blog']..addAll({'tuongtac': data['tuongtac']}));
    } else {
      throw Exception('Không thể tải bài viết');
    }
  }

// cập nhật bài viết
  Future<void> updatePost(int id, Map<String, dynamic> data) async {
    final url = Uri.parse(api_putblog(id));
    final headers = await _getAuthHeaders();

    final response = await http.put(
      url,
      headers: {
        ...headers,
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      throw Exception(
          "Lỗi cập nhật bài viết: ${response.statusCode} ${response.body}");
    }
  }

  Future<BlogApprovedPagination> getApprovedBlogs() async {
    final url = Uri.parse(api_getblog);
    final headers = await _getAuthHeaders();
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      return BlogApprovedPagination.fromJson(body['blogs']);
    } else {
      throw Exception("Lỗi API: ${response.statusCode} ${response.body}");
    }
  }

  Future<List<BlogApproved>> fetchMyBlogs() async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(api_myblog),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body)['data'] as List;
      return data.map((e) => BlogApproved.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi khi lấy danh sách bài viết');
    }
  }

  Future<List<BlogApproved>> fetchUserBlogs(int userId) async {
    final headers = await _getAuthHeaders();
    final response = await http.get(
      Uri.parse(api_dsblog(userId)),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = json.decode(response.body)['data'];
      return data.map((json) => BlogApproved.fromJson(json)).toList();
    } else {
      throw Exception('Lỗi khi lấy bài viết của người dùng');
    }
  }

  // Thêm phương thức toggleLikeBlog
  Future<http.Response> toggleLikeBlog(int blogId) async {
    final url = Uri.parse(api_like_blog(blogId));
    final headers = await _getAuthHeaders();

    final response = await http.post(
      url,
      headers: headers,
    );
    return response;
  }
}
