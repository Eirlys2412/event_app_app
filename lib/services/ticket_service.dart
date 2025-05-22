import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/apilist.dart';
import '../models/event_ticket.dart';

class TicketService {
  static Future<List<EventTicket>> getMyTickets() async {
    try {
      final response = await http.get(
        Uri.parse(api_get_my_tickets),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $g_token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => EventTicket.fromJson(json)).toList();
      } else {
        throw Exception('Lỗi lấy danh sách vé');
      }
    } catch (e) {
      throw Exception('Lỗi kết nối: $e');
    }
  }
}
