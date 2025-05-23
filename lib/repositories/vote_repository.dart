import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/apilist.dart';
import '../constants/pref_data.dart';
import '../providers/vote_provider.dart';

class VoteRepository {
  Future<http.Response> vote(String type, int id, int score) async {
    final token = await PrefData.getToken();
    final response = await http.post(
      Uri.parse(api_rating_event(id)),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'votable_type': type,
        'votable_id': id,
        'rating': score,
      }),
    );
    return response;
  }
}
