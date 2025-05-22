import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event_ticket.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/apilist.dart';

class MyTicketsNotifier extends StateNotifier<AsyncValue<List<EventTicket>>> {
  MyTicketsNotifier() : super(const AsyncValue.loading()) {
    fetchMyTickets();
  }

  Future<void> fetchMyTickets() async {
    try {
      state = const AsyncValue.loading();

      final response = await http.get(
        Uri.parse(api_get_my_tickets),
        headers: {
          'Content-Type': 'application/json',
          // Thêm authorization header nếu cần
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final tickets = data.map((json) => EventTicket.fromJson(json)).toList();
        state = AsyncValue.data(tickets);
      } else {
        throw Exception('Failed to load tickets');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void addTicket(EventTicket ticket) {
    state.whenData((tickets) {
      state = AsyncValue.data([...tickets, ticket]);
    });
  }

  void removeTicket(int ticketId) {
    state.whenData((tickets) {
      state = AsyncValue.data(
        tickets.where((ticket) => ticket.id != ticketId).toList(),
      );
    });
  }
}

final myTicketsProvider =
    StateNotifierProvider<MyTicketsNotifier, AsyncValue<List<EventTicket>>>(
  (ref) => MyTicketsNotifier(),
);
