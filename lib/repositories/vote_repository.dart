import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/apilist.dart';
import '../constants/pref_data.dart';

class VoteRepository {
  Future<void> vote(String type, int id, int score) async {
    final token = await PrefData.getToken();
    await http.post(
      Uri.parse(api_vote),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'votable_type': type,
        'votable_id': id,
        'score': score,
      }),
    );
  }

  Future<double> fetchAverageVote(String type, int id) async {
    final response = await http.get(Uri.parse('$api_vote_average/$type/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['average'] ?? 0.0).toDouble();
    } else {
      throw Exception('Không lấy được điểm trung bình');
    }
  }
}
