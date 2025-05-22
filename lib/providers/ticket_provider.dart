import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ticket.dart';

final ticketsProvider = Provider.family<List<Ticket>, int>((ref, eventId) {
  return [];
});

final selectedTicketsProvider =
    StateNotifierProvider<SelectedTicketsNotifier, Map<int, int>>((ref) {
  return SelectedTicketsNotifier();
});

class SelectedTicketsNotifier extends StateNotifier<Map<int, int>> {
  SelectedTicketsNotifier() : super({});

  void updateQuantity(int ticketId, int quantity) {
    if (quantity <= 0) {
      state = Map.from(state)..remove(ticketId);
    } else {
      state = Map.from(state)..[ticketId] = quantity;
    }
  }

  void clearSelection() {
    state = {};
  }

  double getTotalAmount(List<Ticket> tickets) {
    double total = 0;
    state.forEach((ticketId, quantity) {
      final ticket = tickets.firstWhere((t) => t.id == ticketId);
      total += ticket.price * quantity;
    });
    return total;
  }
}
