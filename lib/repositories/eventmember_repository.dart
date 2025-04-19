import 'dart:convert'; // Để xử lý JSON
import 'package:http/http.dart' as http;
import '../models/eventmember.dart';
import '../constants/apilist.dart';
import '../constants/pref_data.dart';

class EventMemberRepository {
 Future<EventMember?> createEventMember({
  required int userId,
  required int eventId,
}) async {
  try {
    final token = await PrefData.getToken();
    
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Log request body để kiểm tra
    final requestBody = {
      "user_id": userId,
      "event_id": eventId,
    };
    
    print('Request body: ${json.encode(requestBody)}');

    final response = await http.post(
      Uri.parse(api_eventmember),
      headers: headers,
      body: json.encode(requestBody),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    // Rest of your code...

    if (response.statusCode == 422) {
      // Parse validation errors
      final Map<String, dynamic> errorData = json.decode(response.body);
      final errorMessage = errorData['message'] ?? 'Validation failed';
      final errors = errorData['errors'];
      
      if (errors != null && errors is Map) {
        // Combine all error messages
        final List<String> errorMessages = [];
        errors.forEach((field, messages) {
          if (messages is List) {
            errorMessages.addAll(messages.cast<String>());
          }
        });
        throw Exception(errorMessages.join('\n'));
      }
      
      throw Exception(errorMessage);
    }

    if (response.statusCode == 201 || response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return EventMember.fromJson(responseData['data']);
    } else {
      throw Exception('Failed to create event member. Status: ${response.statusCode}');
    }
  } catch (e) {
      print('Error creating event member: $e');
    rethrow;
  }
}
}
