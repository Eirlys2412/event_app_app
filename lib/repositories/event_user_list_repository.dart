import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_user_list.dart';
import '../constants/apilist.dart';

class EventUserRepository {
  Future<List<EventUser>> fetchEventUsers(int eventId) async {
    final response = await http.get(Uri.parse(api_listuser(eventId)));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final dynamic eventUsersData = data['data'];

      // Nếu là List thì parse bình thường, nếu là Map thì bọc vào List
      List<dynamic> eventUsersJson;
      if (eventUsersData is List) {
        eventUsersJson = eventUsersData;
      } else if (eventUsersData is Map) {
        eventUsersJson = [eventUsersData];
      } else {
        eventUsersJson = [];
      }

      return eventUsersJson.map((json) => EventUser.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load event users');
    }
  }
}
