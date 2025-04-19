import 'dart:convert';

import 'package:event_app/constants/apilist.dart';
import 'package:http/http.dart' as http;
import 'package:event_app/models/detail_event.dart';
import 'package:event_app/models/event.dart';

class DetailEventRepository {
  final String baseUrl;

  DetailEventRepository({required this.baseUrl});

  Future<Detailevent> fetchDetailEvent(int id) async {
  final response = await http.get(Uri.parse('$baseUrl/events/$id'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body); // Giải mã JSON
    return Detailevent.fromjson(data['data']); // parse data -> Detailevent
  } else {
    throw Exception('Failed to load detail event');
  }
}

}
