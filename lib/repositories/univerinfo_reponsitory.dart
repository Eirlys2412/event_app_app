import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:event_app/constants/apilist.dart';

class UniverInfoRepository {

  // Hàm lấy danh sách ngành
  Future<List<Map<String, dynamic>>> fetchNganhs() async {
    final url = Uri.parse(api_nganhs);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']); // Chuyển đổi về List<Map<String, dynamic>>
        } else {
          throw Exception(data['message'] ?? 'Lỗi khi lấy danh sách ngành.');
        }
      } else {
        throw Exception('Lỗi HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  // Hàm lấy danh sách đơn vị
  Future<List<Map<String, dynamic>>> fetchDonVis() async {
    final url = Uri.parse(api_donvi);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']); // Chuyển đổi về List<Map<String, dynamic>>
        } else {
          throw Exception(data['message'] ?? 'Lỗi khi lấy danh sách đơn vị.');
        }
      } else {
        throw Exception('Lỗi HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }

  // Hàm lấy danh sách chuyen nganh
  Future<List<Map<String, dynamic>>> fetchChuyenNganh() async {
    final url = Uri.parse(api_chuyenNganh);

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return List<Map<String, dynamic>>.from(data['data']); // Chuyển đổi về List<Map<String, dynamic>>
        } else {
          throw Exception(data['message'] ?? 'Lỗi khi lấy danh sách chuyên ngành.');
        }
      } else {
        throw Exception('Lỗi HTTP: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Lỗi khi gọi API: $e');
    }
  }
}
